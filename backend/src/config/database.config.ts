import { registerAs } from '@nestjs/config';

export const databaseConfig = registerAs('database', () => ({
    uri: process.env.MONGODB_URI || 'mongodb://localhost:27017/tras_phone',
    user: process.env.MONGODB_USER,
    password: process.env.MONGODB_PASSWORD,
    authSource: process.env.MONGODB_AUTH_SOURCE || 'admin',
    replicaSet: process.env.MONGODB_REPLICA_SET,
    ssl: process.env.MONGODB_SSL === 'true',
}));
