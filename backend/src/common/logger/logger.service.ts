import { Injectable, LoggerService as NestLoggerService, Scope } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Professional Logger Service
 * ═══════════════════════════════════════════════════════════════
 * Winston-based logger with daily rotation and multiple transports
 */
@Injectable({ scope: Scope.TRANSIENT })
export class Logger implements NestLoggerService {
    private logger: winston.Logger;
    private context?: string;

    constructor(private readonly configService: ConfigService) {
        this.initializeLogger();
    }

    /**
     * Initialize Winston logger
     */
    private initializeLogger() {
        const logLevel = this.configService.get('LOG_LEVEL', 'info');
        const logPath = this.configService.get('LOG_FILE_PATH', './logs');
        const maxFiles = this.configService.get('LOG_MAX_FILES', '14d');

        // Custom log format
        const logFormat = winston.format.combine(
            winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
            winston.format.errors({ stack: true }),
            winston.format.splat(),
            winston.format.json(),
        );

        // Console format for development
        const consoleFormat = winston.format.combine(
            winston.format.colorize(),
            winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
            winston.format.printf(({ timestamp, level, message, context, ...meta }) => {
                const contextStr = context ? `[${context}]` : '';
                const metaStr = Object.keys(meta).length ? JSON.stringify(meta) : '';
                return `${timestamp} ${level} ${contextStr} ${message} ${metaStr}`;
            }),
        );

        // Transports array
        const transports: winston.transport[] = [
            // Console transport
            new winston.transports.Console({
                format: consoleFormat,
            }),

            // Error log file
            new DailyRotateFile({
                filename: `${logPath}/error-%DATE%.log`,
                datePattern: 'YYYY-MM-DD',
                zippedArchive: true,
                maxFiles,
                level: 'error',
                format: logFormat,
            }),

            // Combined log file
            new DailyRotateFile({
                filename: `${logPath}/combined-%DATE%.log`,
                datePattern: 'YYYY-MM-DD',
                zippedArchive: true,
                maxFiles,
                format: logFormat,
            }),

            // HTTP log file
            new DailyRotateFile({
                filename: `${logPath}/http-%DATE%.log`,
                datePattern: 'YYYY-MM-DD',
                zippedArchive: true,
                maxFiles,
                level: 'http',
                format: logFormat,
            }),
        ];

        this.logger = winston.createLogger({
            level: logLevel,
            format: logFormat,
            transports,
            exceptionHandlers: [
                new DailyRotateFile({
                    filename: `${logPath}/exceptions-%DATE%.log`,
                    datePattern: 'YYYY-MM-DD',
                    zippedArchive: true,
                    maxFiles,
                }),
            ],
            rejectionHandlers: [
                new DailyRotateFile({
                    filename: `${logPath}/rejections-%DATE%.log`,
                    datePattern: 'YYYY-MM-DD',
                    zippedArchive: true,
                    maxFiles,
                }),
            ],
        });
    }

    /**
     * Set logger context
     */
    setContext(context: string) {
        this.context = context;
    }

    /**
     * Log info level message
     */
    log(message: string, context?: string) {
        this.logger.info(message, { context: context || this.context });
    }

    /**
     * Log error level message
     */
    error(message: string, trace?: string, context?: string) {
        this.logger.error(message, {
            context: context || this.context,
            trace,
        });
    }

    /**
     * Log warn level message
     */
    warn(message: string, context?: string) {
        this.logger.warn(message, { context: context || this.context });
    }

    /**
     * Log debug level message
     */
    debug(message: string, context?: string) {
        this.logger.debug(message, { context: context || this.context });
    }

    /**
     * Log verbose level message
     */
    verbose(message: string, context?: string) {
        this.logger.verbose(message, { context: context || this.context });
    }

    /**
     * Log HTTP requests
     */
    http(message: string, meta?: any) {
        this.logger.http(message, meta);
    }
}
