import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AppVersion, AppVersionDocument } from './schemas/app-version.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 App Version Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class AppVersionService {
  constructor(
    @InjectModel(AppVersion.name)
    private appVersionModel: Model<AppVersionDocument>,
  ) {}

  /**
   * Create new app version
   */
  async create(
    data: Partial<AppVersion>,
    createdBy?: string,
  ): Promise<AppVersionDocument> {
    const version = await this.appVersionModel.create({
      ...data,
      createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
    });

    // If marked as current, unset other current versions
    if (data.isCurrent) {
      await this.appVersionModel.updateMany(
        { platform: data.platform, _id: { $ne: version._id } },
        { isCurrent: false },
      );
    }

    return version;
  }

  /**
   * Get all versions
   */
  async findAll(platform?: 'ios' | 'android'): Promise<AppVersion[]> {
    const query = platform ? { platform } : {};
    return this.appVersionModel.find(query).sort({ createdAt: -1 }).lean();
  }

  /**
   * Get current version for platform
   */
  async getCurrentVersion(
    platform: 'ios' | 'android',
  ): Promise<AppVersionDocument> {
    const version = await this.appVersionModel.findOne({
      platform,
      isCurrent: true,
      isActive: true,
    });

    if (!version) {
      throw new NotFoundException(`No current version found for ${platform}`);
    }

    return version;
  }

  /**
   * Check app version (for client apps)
   */
  async checkVersion(
    platform: 'ios' | 'android',
    currentVersion: string,
  ): Promise<{
    isLatest: boolean;
    isSupported: boolean;
    forceUpdate: boolean;
    latestVersion: AppVersionDocument;
  }> {
    const latest = await this.getCurrentVersion(platform);

    const isLatest = this.compareVersions(currentVersion, latest.version) >= 0;
    const isSupported = latest.minSupportedVersion
      ? this.compareVersions(currentVersion, latest.minSupportedVersion) >= 0
      : true;
    const forceUpdate = latest.isForceUpdate && !isLatest;

    return {
      isLatest,
      isSupported,
      forceUpdate,
      latestVersion: latest,
    };
  }

  /**
   * Update version
   */
  async update(
    id: string,
    data: Partial<AppVersion>,
  ): Promise<AppVersionDocument> {
    const version = await this.appVersionModel.findByIdAndUpdate(id, data, {
      new: true,
    });
    if (!version) throw new NotFoundException('App version not found');

    // If marked as current, unset other current versions
    if (data.isCurrent) {
      await this.appVersionModel.updateMany(
        { platform: version.platform, _id: { $ne: version._id } },
        { isCurrent: false },
      );
    }

    return version;
  }

  /**
   * Set current version
   */
  async setCurrent(id: string): Promise<AppVersionDocument> {
    const version = await this.appVersionModel.findById(id);
    if (!version) throw new NotFoundException('App version not found');

    // Unset other current versions
    await this.appVersionModel.updateMany(
      { platform: version.platform },
      { isCurrent: false },
    );

    version.isCurrent = true;
    return version.save();
  }

  /**
   * Delete version
   */
  async delete(id: string): Promise<void> {
    const version = await this.appVersionModel.findById(id);
    if (!version) throw new NotFoundException('App version not found');

    if (version.isCurrent) {
      throw new BadRequestException('Cannot delete current version');
    }

    await this.appVersionModel.findByIdAndDelete(id);
  }

  /**
   * Compare version strings
   * Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
   */
  private compareVersions(v1: string, v2: string): number {
    const parts1 = v1.split('.').map(Number);
    const parts2 = v2.split('.').map(Number);

    const maxLen = Math.max(parts1.length, parts2.length);

    for (let i = 0; i < maxLen; i++) {
      const p1 = parts1[i] || 0;
      const p2 = parts2[i] || 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }

    return 0;
  }
}
