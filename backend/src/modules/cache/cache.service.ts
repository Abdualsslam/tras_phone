import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class CacheService implements OnModuleInit {
    private readonly logger = new Logger(CacheService.name);
    private client: Redis;
    private isConnected = false;
    private readonly defaultTtl: number;
    private readonly prefix: string;

    constructor(private readonly configService: ConfigService) {
        this.defaultTtl = this.configService.get('CACHE_TTL', 3600); // 1 hour
        this.prefix = this.configService.get('CACHE_PREFIX', 'tras:');
    }

    async onModuleInit(): Promise<void> {
        try {
            this.client = new Redis({
                host: this.configService.get('REDIS_HOST', 'localhost'),
                port: this.configService.get('REDIS_PORT', 6379),
                password: this.configService.get('REDIS_PASSWORD'),
                db: this.configService.get('REDIS_DB', 0),
                maxRetriesPerRequest: 3,
                retryStrategy: (times) => {
                    // Retry with exponential backoff, max 3 retries
                    if (times > 3) return null;
                    return Math.min(times * 100, 2000);
                },
            });

            this.client.on('connect', () => {
                this.isConnected = true;
                this.logger.log('Redis connected');
            });

            this.client.on('error', (err) => {
                this.logger.error(`Redis error: ${err.message}`);
                this.isConnected = false;
            });
        } catch (error) {
            this.logger.error(`Redis initialization failed: ${error.message}`);
        }
    }

    // ==================== Basic Operations ====================

    async get<T>(key: string): Promise<T | null> {
        if (!this.isConnected) return null;

        try {
            const data = await this.client.get(this.prefix + key);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            this.logger.error(`Cache get error: ${error.message}`);
            return null;
        }
    }

    async set(key: string, value: any, ttl?: number): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            const serialized = JSON.stringify(value);
            if (ttl) {
                await this.client.setex(this.prefix + key, ttl, serialized);
            } else {
                await this.client.setex(this.prefix + key, this.defaultTtl, serialized);
            }
            return true;
        } catch (error) {
            this.logger.error(`Cache set error: ${error.message}`);
            return false;
        }
    }

    async del(key: string): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            await this.client.del(this.prefix + key);
            return true;
        } catch (error) {
            this.logger.error(`Cache del error: ${error.message}`);
            return false;
        }
    }

    async deletePattern(pattern: string): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            const keys = await this.client.keys(this.prefix + pattern);
            if (keys.length > 0) {
                await this.client.del(...keys);
            }
            return keys.length;
        } catch (error) {
            this.logger.error(`Cache deletePattern error: ${error.message}`);
            return 0;
        }
    }

    async exists(key: string): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            return (await this.client.exists(this.prefix + key)) === 1;
        } catch (error) {
            return false;
        }
    }

    async ttl(key: string): Promise<number> {
        if (!this.isConnected) return -1;

        try {
            return this.client.ttl(this.prefix + key);
        } catch (error) {
            return -1;
        }
    }

    // ==================== Cache-Aside Pattern ====================

    async getOrSet<T>(key: string, factory: () => Promise<T>, ttl?: number): Promise<T> {
        const cached = await this.get<T>(key);
        if (cached !== null) {
            return cached;
        }

        const value = await factory();
        await this.set(key, value, ttl);
        return value;
    }

    // ==================== Hash Operations ====================

    async hget<T>(key: string, field: string): Promise<T | null> {
        if (!this.isConnected) return null;

        try {
            const data = await this.client.hget(this.prefix + key, field);
            return data ? JSON.parse(data) : null;
        } catch (error) {
            return null;
        }
    }

    async hset(key: string, field: string, value: any): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            await this.client.hset(this.prefix + key, field, JSON.stringify(value));
            return true;
        } catch (error) {
            return false;
        }
    }

    async hgetall<T>(key: string): Promise<Record<string, T> | null> {
        if (!this.isConnected) return null;

        try {
            const data = await this.client.hgetall(this.prefix + key);
            if (!data || Object.keys(data).length === 0) return null;

            const result: Record<string, T> = {};
            for (const [k, v] of Object.entries(data)) {
                result[k] = JSON.parse(v as string);
            }
            return result;
        } catch (error) {
            return null;
        }
    }

    async hdel(key: string, field: string): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            await this.client.hdel(this.prefix + key, field);
            return true;
        } catch (error) {
            return false;
        }
    }

    // ==================== Counter Operations ====================

    async increment(key: string, delta: number = 1): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            return this.client.incrby(this.prefix + key, delta);
        } catch (error) {
            return 0;
        }
    }

    async decrement(key: string, delta: number = 1): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            return this.client.decrby(this.prefix + key, delta);
        } catch (error) {
            return 0;
        }
    }

    // ==================== List Operations ====================

    async lpush(key: string, ...values: any[]): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            const serialized = values.map(v => JSON.stringify(v));
            return this.client.lpush(this.prefix + key, ...serialized);
        } catch (error) {
            return 0;
        }
    }

    async rpush(key: string, ...values: any[]): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            const serialized = values.map(v => JSON.stringify(v));
            return this.client.rpush(this.prefix + key, ...serialized);
        } catch (error) {
            return 0;
        }
    }

    async lrange<T>(key: string, start: number, stop: number): Promise<T[]> {
        if (!this.isConnected) return [];

        try {
            const data = await this.client.lrange(this.prefix + key, start, stop);
            return data.map(d => JSON.parse(d));
        } catch (error) {
            return [];
        }
    }

    // ==================== Set Operations ====================

    async sadd(key: string, ...members: any[]): Promise<number> {
        if (!this.isConnected) return 0;

        try {
            const serialized = members.map(m => JSON.stringify(m));
            return this.client.sadd(this.prefix + key, ...serialized);
        } catch (error) {
            return 0;
        }
    }

    async smembers<T>(key: string): Promise<T[]> {
        if (!this.isConnected) return [];

        try {
            const data = await this.client.smembers(this.prefix + key);
            return data.map(d => JSON.parse(d));
        } catch (error) {
            return [];
        }
    }

    async sismember(key: string, member: any): Promise<boolean> {
        if (!this.isConnected) return false;

        try {
            return (await this.client.sismember(this.prefix + key, JSON.stringify(member))) === 1;
        } catch (error) {
            return false;
        }
    }

    // ==================== Rate Limiting ====================

    async isRateLimited(key: string, limit: number, windowSeconds: number): Promise<boolean> {
        if (!this.isConnected) return false;

        const fullKey = `ratelimit:${key}`;
        const current = await this.increment(fullKey);

        if (current === 1) {
            await this.client.expire(this.prefix + fullKey, windowSeconds);
        }

        return current > limit;
    }

    async getRateLimitRemaining(key: string, limit: number): Promise<number> {
        const current = await this.get<number>(`ratelimit:${key}`);
        return Math.max(0, limit - (current || 0));
    }

    // ==================== Cache Keys ====================

    static keys = {
        // Products
        product: (id: string) => `product:${id}`,
        productList: (page: number, filters: string) => `products:${page}:${filters}`,
        productsByCategory: (categoryId: string) => `products:category:${categoryId}`,

        // Categories
        categories: () => 'categories:all',
        categoryTree: () => 'categories:tree',

        // Settings
        settings: () => 'settings:all',
        setting: (key: string) => `setting:${key}`,

        // Countries/Cities
        countries: () => 'countries:all',
        citiesByCountry: (countryId: string) => `cities:${countryId}`,

        // User sessions
        userSession: (userId: string) => `session:${userId}`,
        userCart: (userId: string) => `cart:${userId}`,

        // Home page
        homeSliders: () => 'home:sliders',
        homeBanners: () => 'home:banners',
        featuredProducts: () => 'home:featured',

        // Search
        searchResults: (query: string) => `search:${query}`,
        searchSuggestions: (prefix: string) => `suggestions:${prefix}`,
    };

    // ==================== Flush ====================

    async flushAll(): Promise<void> {
        if (!this.isConnected) return;

        try {
            const keys = await this.client.keys(this.prefix + '*');
            if (keys.length > 0) {
                await this.client.del(...keys);
            }
            this.logger.warn('Cache flushed');
        } catch (error) {
            this.logger.error(`Cache flush error: ${error.message}`);
        }
    }

    // ==================== Stats ====================

    async getStats(): Promise<any> {
        if (!this.isConnected) return { connected: false };

        try {
            const info = await this.client.info();
            const dbSize = await this.client.dbsize();

            return {
                connected: true,
                dbSize,
                info: this.parseRedisInfo(info),
            };
        } catch (error) {
            return { connected: false, error: error.message };
        }
    }

    private parseRedisInfo(info: string): Record<string, string> {
        const result: Record<string, string> = {};
        const lines = info.split('\n');

        for (const line of lines) {
            if (line.includes(':')) {
                const [key, value] = line.split(':');
                result[key.trim()] = value?.trim();
            }
        }

        return result;
    }
}
