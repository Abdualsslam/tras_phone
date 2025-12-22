import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as path from 'path';
import * as crypto from 'crypto';

export interface UploadOptions {
    file: Buffer;
    filename: string;
    mimetype: string;
    folder?: string;
    isPublic?: boolean;
}

export interface UploadResult {
    success: boolean;
    url?: string;
    key?: string;
    bucket?: string;
    size?: number;
    error?: string;
}

@Injectable()
export class StorageService {
    private readonly logger = new Logger(StorageService.name);
    private readonly provider: string;
    private s3Client: S3Client;
    private readonly bucketName: string;
    private readonly region: string;
    private readonly cdnUrl: string;

    constructor(private readonly configService: ConfigService) {
        this.provider = this.configService.get('STORAGE_PROVIDER', 's3');
        this.bucketName = this.configService.get('AWS_S3_BUCKET', '');
        this.region = this.configService.get('AWS_REGION', 'me-south-1');
        this.cdnUrl = this.configService.get('CDN_URL', '');

        if (this.provider === 's3') {
            this.initializeS3();
        }
    }

    private initializeS3(): void {
        this.s3Client = new S3Client({
            region: this.region,
            credentials: {
                accessKeyId: this.configService.get('AWS_ACCESS_KEY_ID', ''),
                secretAccessKey: this.configService.get('AWS_SECRET_ACCESS_KEY', ''),
            },
        });
    }

    async upload(options: UploadOptions): Promise<UploadResult> {
        const key = this.generateKey(options.filename, options.folder);

        this.logger.log(`Uploading file: ${key}`);

        try {
            switch (this.provider) {
                case 's3':
                    return await this.uploadToS3(options.file, key, options.mimetype, options.isPublic);
                default:
                    return this.saveLocally(options.file, key);
            }
        } catch (error) {
            this.logger.error(`Upload failed: ${error.message}`, error.stack);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    async delete(key: string): Promise<boolean> {
        this.logger.log(`Deleting file: ${key}`);

        try {
            switch (this.provider) {
                case 's3':
                    return await this.deleteFromS3(key);
                default:
                    return true;
            }
        } catch (error) {
            this.logger.error(`Delete failed: ${error.message}`, error.stack);
            return false;
        }
    }

    async getSignedDownloadUrl(key: string, expiresIn: number = 3600): Promise<string> {
        if (this.provider !== 's3') {
            return this.getPublicUrl(key);
        }

        const command = new GetObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        return getSignedUrl(this.s3Client, command, { expiresIn });
    }

    getPublicUrl(key: string): string {
        if (this.cdnUrl) {
            return `${this.cdnUrl}/${key}`;
        }
        return `https://${this.bucketName}.s3.${this.region}.amazonaws.com/${key}`;
    }

    // ==================== S3 Operations ====================

    private async uploadToS3(
        file: Buffer,
        key: string,
        contentType: string,
        isPublic: boolean = true
    ): Promise<UploadResult> {
        const command = new PutObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            Body: file,
            ContentType: contentType,
            ACL: isPublic ? 'public-read' : 'private',
            CacheControl: 'max-age=31536000', // 1 year cache
        });

        await this.s3Client.send(command);

        return {
            success: true,
            url: this.getPublicUrl(key),
            key,
            bucket: this.bucketName,
            size: file.length,
        };
    }

    private async deleteFromS3(key: string): Promise<boolean> {
        const command = new DeleteObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        await this.s3Client.send(command);
        return true;
    }

    // ==================== Local Storage (Fallback) ====================

    private saveLocally(file: Buffer, key: string): UploadResult {
        // In production, you would save to local filesystem
        // This is a placeholder for development
        this.logger.warn(`[LOCAL STORAGE] Would save file: ${key}`);

        return {
            success: true,
            url: `/uploads/${key}`,
            key,
            size: file.length,
        };
    }

    // ==================== Helpers ====================

    private generateKey(originalFilename: string, folder?: string): string {
        const ext = path.extname(originalFilename);
        const hash = crypto.randomBytes(16).toString('hex');
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');

        const baseFolder = folder || 'uploads';
        return `${baseFolder}/${year}/${month}/${hash}${ext}`;
    }

    generateThumbnailKey(originalKey: string, size: string): string {
        const ext = path.extname(originalKey);
        const base = originalKey.replace(ext, '');
        return `${base}_${size}${ext}`;
    }

    getMimeType(filename: string): string {
        const ext = path.extname(filename).toLowerCase();
        const mimeTypes: Record<string, string> = {
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.png': 'image/png',
            '.gif': 'image/gif',
            '.webp': 'image/webp',
            '.svg': 'image/svg+xml',
            '.pdf': 'application/pdf',
            '.doc': 'application/msword',
            '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            '.xls': 'application/vnd.ms-excel',
            '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            '.mp4': 'video/mp4',
            '.webm': 'video/webm',
            '.mp3': 'audio/mpeg',
        };
        return mimeTypes[ext] || 'application/octet-stream';
    }

    isImage(mimetype: string): boolean {
        return mimetype.startsWith('image/');
    }

    isVideo(mimetype: string): boolean {
        return mimetype.startsWith('video/');
    }

    isPdf(mimetype: string): boolean {
        return mimetype === 'application/pdf';
    }
}
