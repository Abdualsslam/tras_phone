# ═══════════════════════════════════════════════════════════════
# 🐳 Docker Configuration for TRAS Phone Backend
# ═══════════════════════════════════════════════════════════════

# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies like rimraf and nest-cli)
# التعديل هنا: حذفنا --only=production
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
# هنا نبقيها كما هي لتقليل حجم الصورة النهائية
RUN npm ci --only=production && npm cache clean --force

# Copy built application
COPY --from=builder /app/dist ./dist
# لا نحتاج لنسخ node_modules من البيلدر لأننا قمنا بتثبيت الإنتاج فقط في الخطوة السابقة

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE 3000

# Health check (تعديل بسيط ليتناسب مع الكود)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "try { require('http').get('http://localhost:3000/api', (r) => process.exit(r.statusCode === 200 ? 0 : 1)) } catch (e) { process.exit(1) }"

# Start application
CMD ["node", "dist/main"]