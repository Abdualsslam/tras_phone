import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { StorageService } from '../integrations/storage.service';

export interface UploadedFile {
    url: string;
    key: string;
    filename: string;
    mimetype: string;
    size: number;
}

@Injectable()
export class UploadsService {
    private readonly logger = new Logger(UploadsService.name);
    
    // 10MB max file size for images, 50MB for videos
    private readonly MAX_IMAGE_SIZE = 10 * 1024 * 1024;
    private readonly MAX_VIDEO_SIZE = 50 * 1024 * 1024;
    
    // Allowed MIME types
    private readonly ALLOWED_IMAGE_TYPES = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/svg+xml',
    ];
    
    private readonly ALLOWED_VIDEO_TYPES = [
        'video/mp4',
        'video/webm',
        'video/quicktime',
    ];

    constructor(private readonly storageService: StorageService) {}

    /**
     * Upload a single file from base64
     */
    async uploadBase64(
        base64Data: string,
        filename: string,
        folder: string = 'products',
    ): Promise<UploadedFile> {
        // Extract MIME type and data from base64
        const matches = base64Data.match(/^data:(.+);base64,(.+)$/);
        
        if (!matches) {
            throw new BadRequestException('Invalid base64 format. Expected: data:{mime};base64,{data}');
        }

        const mimetype = matches[1];
        const data = matches[2];
        const buffer = Buffer.from(data, 'base64');

        // Validate MIME type
        const isImage = this.ALLOWED_IMAGE_TYPES.includes(mimetype);
        const isVideo = this.ALLOWED_VIDEO_TYPES.includes(mimetype);
        
        if (!isImage && !isVideo) {
            throw new BadRequestException(`Invalid file type: ${mimetype}. Allowed: images and videos`);
        }

        // Validate file size based on type
        const maxSize = isVideo ? this.MAX_VIDEO_SIZE : this.MAX_IMAGE_SIZE;
        if (buffer.length > maxSize) {
            throw new BadRequestException(`File too large. Maximum size is ${maxSize / 1024 / 1024}MB`);
        }

        // Generate proper filename with extension
        const ext = this.getExtensionFromMime(mimetype);
        const safeFilename = this.sanitizeFilename(filename) + ext;

        // Upload to storage
        const result = await this.storageService.upload({
            file: buffer,
            filename: safeFilename,
            mimetype,
            folder,
            isPublic: true,
        });

        if (!result.success) {
            this.logger.error(`Upload failed: ${result.error}`);
            throw new BadRequestException(`Upload failed: ${result.error}`);
        }

        return {
            url: result.url!,
            key: result.key!,
            filename: safeFilename,
            mimetype,
            size: buffer.length,
        };
    }

    /**
     * Upload multiple files
     */
    async uploadMultiple(
        files: Array<{ base64: string; filename: string }>,
        folder: string = 'products',
    ): Promise<UploadedFile[]> {
        const results: UploadedFile[] = [];
        
        for (const file of files) {
            const uploaded = await this.uploadBase64(file.base64, file.filename, folder);
            results.push(uploaded);
        }
        
        return results;
    }

    /**
     * Delete a file by key
     */
    async deleteFile(key: string): Promise<boolean> {
        return this.storageService.delete(key);
    }

    /**
     * Delete multiple files
     */
    async deleteMultiple(keys: string[]): Promise<void> {
        for (const key of keys) {
            await this.storageService.delete(key);
        }
    }

    private getExtensionFromMime(mimetype: string): string {
        const mimeToExt: Record<string, string> = {
            'image/jpeg': '.jpg',
            'image/png': '.png',
            'image/gif': '.gif',
            'image/webp': '.webp',
            'image/svg+xml': '.svg',
            'video/mp4': '.mp4',
            'video/webm': '.webm',
            'video/quicktime': '.mov',
        };
        return mimeToExt[mimetype] || '';
    }

    private sanitizeFilename(filename: string): string {
        // Remove extension if present
        const nameWithoutExt = filename.replace(/\.[^/.]+$/, '');
        // Replace spaces and special chars
        return nameWithoutExt
            .toLowerCase()
            .replace(/[^a-z0-9]/g, '-')
            .replace(/-+/g, '-')
            .substring(0, 50);
    }
}
