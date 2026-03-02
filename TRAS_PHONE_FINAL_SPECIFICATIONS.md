# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 TRAS Phone - المواصفات النهائية الشاملة والمتكاملة
# ═══════════════════════════════════════════════════════════════════════════════
# Version: 5.0 FINAL COMPLETE
# Date: December 2024
# Status: Ready for Implementation
# ═══════════════════════════════════════════════════════════════════════════════

---

# 📑 الفهرس الشامل

1. [نظرة عامة على المشروع](#section-1)
2. [قاعدة البيانات الكاملة (95 جدول)](#section-2)
3. [API Endpoints الكاملة (~262 endpoint)](#section-3)
4. [هيكل تطبيق Flutter (~66 شاشة)](#section-4)
5. [هيكل لوحة التحكم React (~66 صفحة)](#section-5)
6. [نظام الأمان والحماية](#section-6)
7. [تحسينات الأداء](#section-7)
8. [التكاملات الخارجية](#section-8)
9. [خارطة الطريق](#section-9)
10. [الملخص النهائي](#section-10)

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 1: نظرة عامة على المشروع
# ═══════════════════════════════════════════════════════════════════════════════

## 1.1 وصف المشروع

**TRAS Phone** هي منصة B2B متكاملة للتجارة الإلكترونية متخصصة في بيع قطع غيار الهواتف المحمولة لمحلات الصيانة والفنيين في المملكة العربية السعودية والخليج.

## 1.2 المكونات التقنية

```yaml
Backend:
  Framework: PHP 8.2+ (Laravel/Custom)
  Database: MySQL 8.0+
  Cache: Redis 7.x
  Search: Meilisearch
  Queue: Redis Queue
  Storage: S3-Compatible (Hostinger/AWS)

Mobile App:
  Framework: Flutter 3.x
  State Management: Riverpod 2.x
  Architecture: Clean Architecture
  Local Storage: Hive + Secure Storage

Web Admin:
  Framework: React 18.x / Next.js 14
  Language: TypeScript 5.x
  UI Library: Shadcn UI + Tailwind CSS
  State: Zustand / React Query

Infrastructure:
  Hosting: Hostinger VPS / AWS
  CDN: Cloudflare
  SSL: Let's Encrypt
  Monitoring: Sentry + Custom Logs
```

## 1.3 الإحصائيات الشاملة

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         إحصائيات المشروع الكاملة                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📊 قاعدة البيانات                                                          │
│  ─────────────────                                                          │
│  • إجمالي الجداول: 95 جدول                                                  │
│  • جداول المصادقة والمستخدمين: 9 جداول                                      │
│  • جداول العملاء: 4 جداول                                                   │
│  • جداول الإدارة والصلاحيات: 5 جداول                                        │
│  • جداول المواقع: 4 جداول                                                   │
│  • جداول الكتالوج: 4 جداول                                                  │
│  • جداول المنتجات: 8 جداول                                                  │
│  • جداول التسعير: 4 جداول                                                   │
│  • جداول العروض والكوبونات: 7 جداول                                         │
│  • جداول المخزون: 8 جداول                                                   │
│  • جداول الموردين: 5 جداول                                                  │
│  • جداول السلة: 3 جداول                                                     │
│  • جداول الطلبات والفواتير: 6 جداول                                         │
│  • جداول المرتجعات: 5 جداول                                                 │
│  • جداول المحفظة والولاء: 3 جداول                                           │
│  • جداول الإشعارات: 3 جداول                                                 │
│  • جداول الدعم والدردشة: 6 جداول                                            │
│  • جداول المحتوى: 5 جداول                                                   │
│  • جداول النظام والأمان: 8 جداول                                            │
│  • جداول التكاملات: 2 جداول                                                 │
│                                                                              │
│  🔌 API Endpoints                                                            │
│  ─────────────────                                                          │
│  • Customer APIs: ~138 endpoint                                              │
│  • Admin APIs: ~124 endpoint                                                 │
│  • الإجمالي: ~262 endpoint                                                  │
│                                                                              │
│  📱 Flutter App                                                              │
│  ─────────────────                                                          │
│  • إجمالي الشاشات: ~66 شاشة                                                 │
│                                                                              │
│  💻 React Admin                                                              │
│  ─────────────────                                                          │
│  • إجمالي الصفحات: ~66 صفحة                                                 │
│                                                                              │
│  🔐 الصلاحيات                                                               │
│  ─────────────────                                                          │
│  • إجمالي الصلاحيات: 95 صلاحية                                              │
│                                                                              │
│  ⏱️ الوقت المقدر                                                            │
│  ─────────────────                                                          │
│  • إجمالي: 7 أشهر (29 أسبوع)                                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 2: قاعدة البيانات الكاملة (95 جدول)
# ═══════════════════════════════════════════════════════════════════════════════

## 2.1 إعدادات قاعدة البيانات

```sql
-- ============================================
-- DATABASE CONFIGURATION
-- ============================================
CREATE DATABASE IF NOT EXISTS tras_phone
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE tras_phone;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
```

---

## 2.2 جداول المصادقة والمستخدمين (9 جداول)

```sql
-- ============================================
-- 1. USERS TABLE (Base for all user types)
-- ============================================
CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('customer', 'admin') NOT NULL,
    status ENUM('pending', 'active', 'suspended', 'deleted') DEFAULT 'pending',
    
    -- Profile
    avatar VARCHAR(255) NULL,
    
    -- Verification
    phone_verified_at TIMESTAMP NULL,
    email_verified_at TIMESTAMP NULL,
    
    -- Two Factor
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255) NULL,
    
    -- Social Login
    google_id VARCHAR(100) NULL,
    apple_id VARCHAR(100) NULL,
    
    -- Login Tracking
    last_login_at TIMESTAMP NULL,
    last_login_ip VARCHAR(45) NULL,
    failed_login_attempts TINYINT UNSIGNED DEFAULT 0,
    locked_until TIMESTAMP NULL,
    
    -- Device
    fcm_token TEXT NULL,
    device_info JSON NULL,
    
    -- Preferences
    language VARCHAR(5) DEFAULT 'ar',
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    notification_preferences JSON NULL,
    
    -- Marketing
    accepts_marketing BOOLEAN DEFAULT TRUE,
    marketing_consent_at TIMESTAMP NULL,
    
    -- Referral
    referral_code VARCHAR(20) UNIQUE NULL,
    referred_by BIGINT UNSIGNED NULL,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_phone (phone),
    INDEX idx_email (email),
    INDEX idx_uuid (uuid),
    INDEX idx_user_type_status (user_type, status),
    INDEX idx_referral_code (referral_code),
    INDEX idx_google_id (google_id),
    INDEX idx_apple_id (apple_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. USER SESSIONS
-- ============================================
CREATE TABLE user_sessions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    token_id VARCHAR(100) UNIQUE NOT NULL,
    
    -- Device Info
    device_type VARCHAR(20) NULL,
    device_name VARCHAR(100) NULL,
    device_id VARCHAR(255) NULL,
    app_version VARCHAR(20) NULL,
    
    -- Location
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    
    -- Activity
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token_id),
    INDEX idx_user_expires (user_id, expires_at),
    INDEX idx_device (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 3. PASSWORD RESETS
-- ============================================
CREATE TABLE password_resets (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    token VARCHAR(255) NOT NULL,
    otp VARCHAR(6) NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. OTP VERIFICATIONS
-- ============================================
CREATE TABLE otp_verifications (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    phone VARCHAR(20) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    purpose ENUM('registration', 'login', 'password_reset', 'phone_change') NOT NULL,
    attempts TINYINT UNSIGNED DEFAULT 0,
    max_attempts TINYINT UNSIGNED DEFAULT 3,
    verified_at TIMESTAMP NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_phone_purpose (phone, purpose),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 5. API TOKENS (للتكاملات الخارجية)
-- ============================================
CREATE TABLE api_tokens (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    token VARCHAR(100) UNIQUE NOT NULL,
    
    -- Permissions
    abilities JSON NULL,
    
    -- Limits
    rate_limit INT UNSIGNED DEFAULT 1000,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 6. RATE LIMITS
-- ============================================
CREATE TABLE rate_limits (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    key_type ENUM('ip', 'user', 'api_token') NOT NULL,
    key_value VARCHAR(255) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    hits INT UNSIGNED DEFAULT 1,
    reset_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_rate_limit (key_type, key_value, endpoint),
    INDEX idx_reset (reset_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 7. LOGIN ATTEMPTS
-- ============================================
CREATE TABLE login_attempts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    identifier VARCHAR(255) NOT NULL,
    identifier_type ENUM('phone', 'email', 'ip') NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NULL,
    status ENUM('success', 'failed', 'blocked') NOT NULL,
    failure_reason VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_identifier (identifier, identifier_type),
    INDEX idx_ip (ip_address),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 8. IP BLACKLIST
-- ============================================
CREATE TABLE ip_blacklist (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ip_address VARCHAR(45) NOT NULL,
    reason VARCHAR(255) NULL,
    blocked_until TIMESTAMP NULL,
    is_permanent BOOLEAN DEFAULT FALSE,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_ip (ip_address),
    INDEX idx_blocked_until (blocked_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 9. SECURITY EVENTS
-- ============================================
CREATE TABLE security_events (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    event_type VARCHAR(50) NOT NULL,
    severity ENUM('low', 'medium', 'high', 'critical') NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    description TEXT NOT NULL,
    metadata JSON NULL,
    resolved_at TIMESTAMP NULL,
    resolved_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_event_type (event_type),
    INDEX idx_severity (severity),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.3 جداول العملاء (4 جداول)

```sql
-- ============================================
-- 10. CUSTOMERS
-- ============================================
CREATE TABLE customers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED UNIQUE NOT NULL,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    
    -- Business Info
    responsible_person_name VARCHAR(100) NOT NULL,
    shop_name VARCHAR(150) NOT NULL,
    shop_name_ar VARCHAR(150) NULL,
    business_type ENUM('shop', 'technician', 'distributor', 'other') DEFAULT 'shop',
    
    -- Location
    city_id BIGINT UNSIGNED NOT NULL,
    market_id BIGINT UNSIGNED NULL,
    address TEXT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    
    -- Documents
    commercial_license_file VARCHAR(255) NULL,
    commercial_license_number VARCHAR(50) NULL,
    commercial_license_expiry DATE NULL,
    tax_number VARCHAR(50) NULL,
    national_id VARCHAR(20) NULL,
    
    -- Pricing & Credit
    price_level_id BIGINT UNSIGNED NOT NULL,
    credit_limit DECIMAL(14, 2) DEFAULT 0.00,
    credit_used DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Wallet
    wallet_balance DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Loyalty
    loyalty_points INT UNSIGNED DEFAULT 0,
    loyalty_tier ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze',
    
    -- Preferences
    preferred_payment_method ENUM('cod', 'bank_transfer', 'wallet') NULL,
    preferred_shipping_time VARCHAR(50) NULL,
    preferred_contact_method ENUM('phone', 'whatsapp', 'email') DEFAULT 'whatsapp',
    
    -- Social Media
    instagram_handle VARCHAR(100) NULL,
    twitter_handle VARCHAR(100) NULL,
    
    -- Risk Assessment
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT NULL,
    
    -- Sales Rep
    assigned_sales_rep_id BIGINT UNSIGNED NULL,
    
    -- Birthday
    birth_date DATE NULL,
    
    -- Stats
    total_orders INT UNSIGNED DEFAULT 0,
    total_spent DECIMAL(14, 2) DEFAULT 0.00,
    average_order_value DECIMAL(12, 2) DEFAULT 0.00,
    last_order_at TIMESTAMP NULL,
    
    -- Admin Notes
    internal_notes TEXT NULL,
    
    -- Approval
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    rejection_reason TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_customer_code (customer_code),
    INDEX idx_city (city_id),
    INDEX idx_price_level (price_level_id),
    INDEX idx_loyalty_tier (loyalty_tier),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 11. CUSTOMER ADDRESSES
-- ============================================
CREATE TABLE customer_addresses (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    label VARCHAR(50) NOT NULL,
    recipient_name VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    city_id BIGINT UNSIGNED NOT NULL,
    market_id BIGINT UNSIGNED NULL,
    address_line TEXT NOT NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_default (customer_id, is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 12. CUSTOMER PRICE LEVEL HISTORY
-- ============================================
CREATE TABLE customer_price_level_history (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    from_price_level_id BIGINT UNSIGNED NULL,
    to_price_level_id BIGINT UNSIGNED NOT NULL,
    reason VARCHAR(255) NULL,
    changed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 13. REFERRALS
-- ============================================
CREATE TABLE referrals (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    referrer_id BIGINT UNSIGNED NOT NULL,
    referred_id BIGINT UNSIGNED NOT NULL,
    referral_code VARCHAR(20) NOT NULL,
    status ENUM('pending', 'completed', 'expired', 'cancelled') DEFAULT 'pending',
    
    -- Rewards
    referrer_reward_amount DECIMAL(12, 2) NULL,
    referred_reward_amount DECIMAL(12, 2) NULL,
    referrer_rewarded_at TIMESTAMP NULL,
    referred_rewarded_at TIMESTAMP NULL,
    
    -- Conditions
    min_order_amount DECIMAL(12, 2) NULL,
    qualifying_order_id BIGINT UNSIGNED NULL,
    
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (referrer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (referred_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_referrer (referrer_id),
    INDEX idx_referred (referred_id),
    INDEX idx_code (referral_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.4 جداول الإدارة والصلاحيات (5 جداول)

```sql
-- ============================================
-- 14. ADMIN USERS
-- ============================================
CREATE TABLE admin_users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED UNIQUE NOT NULL,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    full_name_ar VARCHAR(100) NULL,
    department VARCHAR(50) NULL,
    position VARCHAR(50) NULL,
    avatar VARCHAR(255) NULL,
    is_super_admin BOOLEAN DEFAULT FALSE,
    can_access_mobile BOOLEAN DEFAULT TRUE,
    can_access_web BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_employee_code (employee_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 15. ROLES
-- ============================================
CREATE TABLE roles (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    display_name_ar VARCHAR(100) NULL,
    description TEXT NULL,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 16. PERMISSIONS
-- ============================================
CREATE TABLE permissions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    module VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(150) NOT NULL,
    display_name_ar VARCHAR(150) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_module_action (module, action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 17. ROLE PERMISSIONS
-- ============================================
CREATE TABLE role_permissions (
    role_id BIGINT UNSIGNED NOT NULL,
    permission_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 18. ADMIN USER ROLES
-- ============================================
CREATE TABLE admin_user_roles (
    admin_user_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (admin_user_id, role_id),
    FOREIGN KEY (admin_user_id) REFERENCES admin_users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.5 جداول المواقع (4 جداول)

```sql
-- ============================================
-- 19. COUNTRIES
-- ============================================
CREATE TABLE countries (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    phone_code VARCHAR(10) NULL,
    currency_code VARCHAR(3) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 20. SHIPPING ZONES
-- ============================================
CREATE TABLE shipping_zones (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    
    -- Shipping Settings
    base_shipping_cost DECIMAL(10, 2) DEFAULT 0.00,
    free_shipping_threshold DECIMAL(12, 2) NULL,
    cost_per_kg DECIMAL(10, 2) NULL,
    
    -- Delivery Time
    estimated_days_min INT UNSIGNED DEFAULT 1,
    estimated_days_max INT UNSIGNED DEFAULT 3,
    
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 21. CITIES
-- ============================================
CREATE TABLE cities (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    country_id BIGINT UNSIGNED NOT NULL,
    shipping_zone_id BIGINT UNSIGNED NULL,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    
    FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_zone_id) REFERENCES shipping_zones(id) ON DELETE SET NULL,
    INDEX idx_country (country_id),
    INDEX idx_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 22. MARKETS
-- ============================================
CREATE TABLE markets (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    city_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE,
    INDEX idx_city (city_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.6 جداول الكتالوج (4 جداول)

```sql
-- ============================================
-- 23. BRANDS
-- ============================================
CREATE TABLE brands (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo VARCHAR(255) NULL,
    banner VARCHAR(255) NULL,
    description TEXT NULL,
    description_ar TEXT NULL,
    website VARCHAR(255) NULL,
    
    -- Contact
    contact_email VARCHAR(255) NULL,
    contact_phone VARCHAR(20) NULL,
    
    -- Social
    facebook_url VARCHAR(255) NULL,
    instagram_url VARCHAR(255) NULL,
    
    -- Country
    country_of_origin VARCHAR(100) NULL,
    
    -- Warranty
    default_warranty_months INT UNSIGNED NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    products_count INT UNSIGNED DEFAULT 0,
    
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_slug (slug),
    INDEX idx_active_sort (is_active, sort_order),
    INDEX idx_featured (is_featured)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 24. CATEGORIES (Hierarchical)
-- ============================================
CREATE TABLE categories (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    parent_id BIGINT UNSIGNED NULL,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(255) NULL,
    image VARCHAR(255) NULL,
    description TEXT NULL,
    description_ar TEXT NULL,
    
    -- Display
    display_mode ENUM('products', 'subcategories', 'both') DEFAULT 'products',
    
    -- Banner
    banner_image VARCHAR(255) NULL,
    banner_link VARCHAR(255) NULL,
    
    -- Filters
    available_filters JSON NULL,
    
    -- Commission (if marketplace)
    commission_rate DECIMAL(5, 2) NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    level TINYINT UNSIGNED DEFAULT 0,
    path VARCHAR(255) NULL,
    products_count INT UNSIGNED DEFAULT 0,
    
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_parent (parent_id),
    INDEX idx_slug (slug),
    INDEX idx_path (path),
    INDEX idx_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 25. DEVICES (Phone Models)
-- ============================================
CREATE TABLE devices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    brand_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(150) NOT NULL,
    name_ar VARCHAR(150) NULL,
    model_number VARCHAR(100) NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,
    image VARCHAR(255) NULL,
    release_year SMALLINT UNSIGNED NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    products_count INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE,
    INDEX idx_brand (brand_id),
    INDEX idx_slug (slug),
    INDEX idx_active (is_active),
    FULLTEXT INDEX ft_search (name, model_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 26. QUALITY TYPES
-- ============================================
CREATE TABLE quality_types (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT NULL,
    color_code VARCHAR(7) NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.7 جداول المنتجات (8 جداول)

```sql
-- ============================================
-- 27. PRODUCTS
-- ============================================
CREATE TABLE products (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Identifiers
    sku VARCHAR(50) UNIQUE NOT NULL,
    barcode VARCHAR(50) UNIQUE NULL,
    
    -- Names
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255) NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    
    -- Relations
    brand_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    quality_type_id BIGINT UNSIGNED NULL,
    supplier_id BIGINT UNSIGNED NULL,
    
    -- Variants Support
    has_variants BOOLEAN DEFAULT FALSE,
    parent_product_id BIGINT UNSIGNED NULL,
    variant_attributes JSON NULL,
    
    -- Pricing
    cost_price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    base_price DECIMAL(12, 2) NOT NULL,
    compare_at_price DECIMAL(12, 2) NULL,
    
    -- Inventory
    track_inventory BOOLEAN DEFAULT TRUE,
    stock_quantity INT DEFAULT 0,
    reserved_quantity INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 5,
    allow_backorder BOOLEAN DEFAULT FALSE,
    
    -- Physical Attributes
    weight DECIMAL(8, 3) NULL,
    weight_unit ENUM('kg', 'g') DEFAULT 'g',
    dimensions_length DECIMAL(8, 2) NULL,
    dimensions_width DECIMAL(8, 2) NULL,
    dimensions_height DECIMAL(8, 2) NULL,
    
    -- Shipping
    is_fragile BOOLEAN DEFAULT FALSE,
    requires_special_handling BOOLEAN DEFAULT FALSE,
    shipping_class VARCHAR(50) NULL,
    
    -- Availability
    available_from DATE NULL,
    available_until DATE NULL,
    
    -- Pre-order
    is_preorder BOOLEAN DEFAULT FALSE,
    preorder_release_date DATE NULL,
    preorder_limit INT UNSIGNED NULL,
    
    -- Bundle
    is_bundle BOOLEAN DEFAULT FALSE,
    bundle_products JSON NULL,
    
    -- Digital
    is_digital BOOLEAN DEFAULT FALSE,
    digital_file_path VARCHAR(255) NULL,
    
    -- Order Quantity
    min_order_quantity INT UNSIGNED DEFAULT 1,
    max_order_quantity INT UNSIGNED NULL,
    quantity_increment INT UNSIGNED DEFAULT 1,
    
    -- Content
    short_description TEXT NULL,
    short_description_ar TEXT NULL,
    description LONGTEXT NULL,
    description_ar LONGTEXT NULL,
    specifications JSON NULL,
    
    -- Related Products
    upsell_product_ids JSON NULL,
    cross_sell_product_ids JSON NULL,
    
    -- Country of Origin
    country_of_origin VARCHAR(100) NULL,
    
    -- Custom Fields
    custom_fields JSON NULL,
    
    -- SEO
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    
    -- Status & Visibility
    status ENUM('draft', 'active', 'inactive', 'discontinued') DEFAULT 'draft',
    visibility ENUM('visible', 'catalog', 'search', 'hidden') DEFAULT 'visible',
    is_featured BOOLEAN DEFAULT FALSE,
    is_new_arrival BOOLEAN DEFAULT FALSE,
    new_arrival_until DATE NULL,
    
    -- Warranty
    warranty_duration INT NULL,
    warranty_description TEXT NULL,
    
    -- Stats
    view_count INT UNSIGNED DEFAULT 0,
    order_count INT UNSIGNED DEFAULT 0,
    rating_average DECIMAL(2, 1) DEFAULT 0.0,
    rating_count INT UNSIGNED DEFAULT 0,
    
    -- Timestamps
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (brand_id) REFERENCES brands(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (quality_type_id) REFERENCES quality_types(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_product_id) REFERENCES products(id) ON DELETE SET NULL,
    
    INDEX idx_sku (sku),
    INDEX idx_barcode (barcode),
    INDEX idx_brand (brand_id),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_stock (stock_quantity, low_stock_threshold),
    INDEX idx_featured (is_featured),
    INDEX idx_new_arrival (is_new_arrival, new_arrival_until),
    INDEX idx_products_listing (status, is_featured, created_at DESC),
    INDEX idx_products_price_range (status, base_price),
    FULLTEXT INDEX ft_search (name, name_ar, sku, barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 28. PRODUCT IMAGES
-- ============================================
CREATE TABLE product_images (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    thumbnail_path VARCHAR(255) NULL,
    alt_text VARCHAR(255) NULL,
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product_sort (product_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 29. PRODUCT DEVICE COMPATIBILITY
-- ============================================
CREATE TABLE product_device_compatibility (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NOT NULL,
    compatibility_notes TEXT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_device (product_id, device_id),
    INDEX idx_device (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 30. TAGS
-- ============================================
CREATE TABLE tags (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 31. PRODUCT TAGS
-- ============================================
CREATE TABLE product_tags (
    product_id BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 32. PRODUCT REVIEWS
-- ============================================
CREATE TABLE product_reviews (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NULL,
    order_item_id BIGINT UNSIGNED NULL,
    
    -- Rating
    rating TINYINT UNSIGNED NOT NULL CHECK (rating >= 1 AND rating <= 5),
    
    -- Content
    title VARCHAR(255) NULL,
    review TEXT NULL,
    
    -- Pros & Cons
    pros JSON NULL,
    cons JSON NULL,
    
    -- Media
    images JSON NULL,
    
    -- Status
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    rejection_reason TEXT NULL,
    
    -- Helpful votes
    helpful_count INT UNSIGNED DEFAULT 0,
    not_helpful_count INT UNSIGNED DEFAULT 0,
    
    -- Verification
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    
    -- Admin
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_product_status (product_id, status),
    INDEX idx_rating (rating),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 33. REVIEW VOTES
-- ============================================
CREATE TABLE review_votes (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    review_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (review_id) REFERENCES product_reviews(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    UNIQUE KEY unique_review_customer (review_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 34. WISHLISTS
-- ============================================
CREATE TABLE wishlists (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    notes TEXT NULL,
    notify_on_price_drop BOOLEAN DEFAULT FALSE,
    notify_on_stock BOOLEAN DEFAULT FALSE,
    price_at_add DECIMAL(12, 2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_customer (customer_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.8 جداول التسعير (4 جداول)

```sql
-- ============================================
-- 35. PRICE LEVELS
-- ============================================
CREATE TABLE price_levels (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    description TEXT NULL,
    min_order_amount DECIMAL(12, 2) NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 36. PRODUCT PRICES
-- ============================================
CREATE TABLE product_prices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    price_level_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    min_quantity INT UNSIGNED DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (price_level_id) REFERENCES price_levels(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_level_qty (product_id, price_level_id, min_quantity),
    INDEX idx_price_level (price_level_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 37. PRICE HISTORY
-- ============================================
CREATE TABLE price_history (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    price_level_id BIGINT UNSIGNED NULL,
    price_type ENUM('cost', 'base', 'level') NOT NULL,
    old_price DECIMAL(12, 2) NULL,
    new_price DECIMAL(12, 2) NOT NULL,
    change_reason VARCHAR(255) NULL,
    changed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_product_date (product_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 38. STOCK ALERTS
-- ============================================
CREATE TABLE stock_alerts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    
    -- Alert Type
    alert_type ENUM('back_in_stock', 'low_stock', 'price_drop') NOT NULL,
    
    -- For price drop
    target_price DECIMAL(12, 2) NULL,
    original_price DECIMAL(12, 2) NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    notified_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product_type (customer_id, product_id, alert_type),
    INDEX idx_product_active (product_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.9 جداول العروض والكوبونات (7 جداول)

```sql
-- ============================================
-- 39. PROMOTIONS
-- ============================================
CREATE TABLE promotions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Basic Info
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    code VARCHAR(50) UNIQUE NULL,
    description TEXT NULL,
    
    -- Type & Value
    type ENUM('percentage', 'fixed_amount', 'buy_x_get_y', 'free_shipping') NOT NULL,
    value DECIMAL(12, 2) NOT NULL,
    buy_quantity INT NULL,
    get_quantity INT NULL,
    
    -- Conditions
    min_order_amount DECIMAL(12, 2) NULL,
    min_quantity INT NULL,
    max_discount_amount DECIMAL(12, 2) NULL,
    
    -- Applicability
    applies_to ENUM('all', 'specific_products', 'specific_categories', 'specific_brands') DEFAULT 'all',
    
    -- Usage Limits
    usage_limit_total INT UNSIGNED NULL,
    usage_limit_per_customer INT UNSIGNED NULL,
    usage_count INT UNSIGNED DEFAULT 0,
    
    -- Validity Period
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NULL,
    
    -- Targeting
    target_price_levels JSON NULL,
    target_cities JSON NULL,
    target_customer_ids JSON NULL,
    
    -- Flags
    is_active BOOLEAN DEFAULT TRUE,
    is_stackable BOOLEAN DEFAULT FALSE,
    is_auto_apply BOOLEAN DEFAULT FALSE,
    show_on_storefront BOOLEAN DEFAULT TRUE,
    
    -- Admin
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_code (code),
    INDEX idx_dates (starts_at, ends_at),
    INDEX idx_active (is_active),
    INDEX idx_auto_apply (is_auto_apply, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 40. PROMOTION PRODUCTS
-- ============================================
CREATE TABLE promotion_products (
    promotion_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (promotion_id, product_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 41. PROMOTION CATEGORIES
-- ============================================
CREATE TABLE promotion_categories (
    promotion_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (promotion_id, category_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 42. PROMOTION BRANDS
-- ============================================
CREATE TABLE promotion_brands (
    promotion_id BIGINT UNSIGNED NOT NULL,
    brand_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (promotion_id, brand_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 43. PROMOTION USAGE
-- ============================================
CREATE TABLE promotion_usage (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    promotion_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    discount_amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_promotion_customer (promotion_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 44. COUPONS
-- ============================================
CREATE TABLE coupons (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Type
    type ENUM('percentage', 'fixed_amount', 'free_shipping') NOT NULL,
    value DECIMAL(12, 2) NOT NULL,
    
    -- Limits
    min_order_amount DECIMAL(12, 2) NULL,
    max_discount_amount DECIMAL(12, 2) NULL,
    
    -- Usage
    usage_limit_total INT UNSIGNED NULL,
    usage_limit_per_customer INT UNSIGNED DEFAULT 1,
    usage_count INT UNSIGNED DEFAULT 0,
    
    -- Validity
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NULL,
    
    -- Restrictions
    first_order_only BOOLEAN DEFAULT FALSE,
    specific_customers JSON NULL,
    excluded_products JSON NULL,
    excluded_categories JSON NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_code (code),
    INDEX idx_active_dates (is_active, starts_at, ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 45. COUPON USAGE
-- ============================================
CREATE TABLE coupon_usage (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    coupon_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    discount_amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_coupon_customer (coupon_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.10 جداول المخزون (8 جداول)

```sql
-- ============================================
-- 46. WAREHOUSES
-- ============================================
CREATE TABLE warehouses (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    address TEXT NULL,
    city_id BIGINT UNSIGNED NULL,
    phone VARCHAR(20) NULL,
    manager_name VARCHAR(100) NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 47. STOCK LOCATIONS
-- ============================================
CREATE TABLE stock_locations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    reserved_quantity INT DEFAULT 0,
    bin_location VARCHAR(50) NULL,
    last_counted_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_warehouse_product (warehouse_id, product_id),
    INDEX idx_product (product_id),
    INDEX idx_quantity (quantity),
    INDEX idx_stock_warehouse_qty (warehouse_id, quantity),
    INDEX idx_stock_low (quantity, reserved_quantity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 48. STOCK MOVEMENTS
-- ============================================
CREATE TABLE stock_movements (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    movement_type ENUM(
        'purchase_received',
        'sale',
        'sale_cancelled',
        'return_from_customer',
        'return_to_supplier',
        'adjustment_add',
        'adjustment_subtract',
        'transfer_in',
        'transfer_out',
        'damage',
        'initial_stock',
        'inventory_count'
    ) NOT NULL,
    quantity INT NOT NULL,
    quantity_before INT NOT NULL,
    quantity_after INT NOT NULL,
    unit_cost DECIMAL(12, 2) NULL,
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    notes TEXT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_product_date (product_id, created_at),
    INDEX idx_warehouse_date (warehouse_id, created_at),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_type (movement_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 49. STOCK RESERVATIONS
-- ============================================
CREATE TABLE stock_reservations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    status ENUM('reserved', 'fulfilled', 'released') DEFAULT 'reserved',
    reserved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    fulfilled_at TIMESTAMP NULL,
    released_at TIMESTAMP NULL,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 50. STOCK TRANSFERS
-- ============================================
CREATE TABLE stock_transfers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    transfer_number VARCHAR(30) UNIQUE NOT NULL,
    from_warehouse_id BIGINT UNSIGNED NOT NULL,
    to_warehouse_id BIGINT UNSIGNED NOT NULL,
    status ENUM('draft', 'pending', 'in_transit', 'completed', 'cancelled') DEFAULT 'draft',
    notes TEXT NULL,
    created_by BIGINT UNSIGNED NULL,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 51. STOCK TRANSFER ITEMS
-- ============================================
CREATE TABLE stock_transfer_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    transfer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity_requested INT NOT NULL,
    quantity_sent INT NULL,
    quantity_received INT NULL,
    notes TEXT NULL,
    
    FOREIGN KEY (transfer_id) REFERENCES stock_transfers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 52. INVENTORY COUNTS
-- ============================================
CREATE TABLE inventory_counts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    count_number VARCHAR(30) UNIQUE NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    
    -- Type
    count_type ENUM('full', 'partial', 'cycle') NOT NULL,
    
    -- Status
    status ENUM('draft', 'in_progress', 'completed', 'cancelled') DEFAULT 'draft',
    
    -- Scope (for partial counts)
    category_ids JSON NULL,
    brand_ids JSON NULL,
    location_filter VARCHAR(100) NULL,
    
    -- Stats
    total_products INT UNSIGNED DEFAULT 0,
    counted_products INT UNSIGNED DEFAULT 0,
    variance_products INT UNSIGNED DEFAULT 0,
    
    -- Dates
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    
    -- Admin
    created_by BIGINT UNSIGNED NULL,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    
    notes TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 53. INVENTORY COUNT ITEMS
-- ============================================
CREATE TABLE inventory_count_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    count_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    
    -- Quantities
    system_quantity INT NOT NULL,
    counted_quantity INT NULL,
    variance INT NULL,
    
    -- Status
    status ENUM('pending', 'counted', 'verified') DEFAULT 'pending',
    
    -- Details
    bin_location VARCHAR(50) NULL,
    notes TEXT NULL,
    
    counted_by BIGINT UNSIGNED NULL,
    counted_at TIMESTAMP NULL,
    
    FOREIGN KEY (count_id) REFERENCES inventory_counts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (counted_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.11 جداول الموردين والمشتريات (5 جداول)

```sql
-- ============================================
-- 54. SUPPLIERS
-- ============================================
CREATE TABLE suppliers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    name_ar VARCHAR(150) NULL,
    contact_person VARCHAR(100) NULL,
    email VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    mobile VARCHAR(20) NULL,
    address TEXT NULL,
    city VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    tax_number VARCHAR(50) NULL,
    
    -- Payment Terms
    payment_terms_days INT DEFAULT 30,
    credit_limit DECIMAL(14, 2) NULL,
    currency_code VARCHAR(3) DEFAULT 'SAR',
    
    -- Bank Details
    bank_name VARCHAR(100) NULL,
    bank_account_name VARCHAR(100) NULL,
    bank_account_number VARCHAR(50) NULL,
    bank_iban VARCHAR(50) NULL,
    
    -- Stats
    total_purchases DECIMAL(14, 2) DEFAULT 0.00,
    outstanding_balance DECIMAL(14, 2) DEFAULT 0.00,
    
    notes TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add FK to products
ALTER TABLE products ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL;

-- ============================================
-- 55. PURCHASE ORDERS
-- ============================================
CREATE TABLE purchase_orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    po_number VARCHAR(30) UNIQUE NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    status ENUM(
        'draft',
        'pending_approval',
        'approved',
        'sent_to_supplier',
        'confirmed',
        'partial_received',
        'received',
        'cancelled'
    ) DEFAULT 'draft',
    
    -- Amounts
    subtotal DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    shipping_cost DECIMAL(12, 2) DEFAULT 0.00,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    
    -- Currency
    currency_code VARCHAR(3) DEFAULT 'SAR',
    exchange_rate DECIMAL(10, 4) DEFAULT 1.0000,
    
    -- Dates
    order_date DATE NOT NULL,
    expected_date DATE NULL,
    received_date DATE NULL,
    
    -- Payment
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    payment_due_date DATE NULL,
    amount_paid DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Notes
    notes TEXT NULL,
    internal_notes TEXT NULL,
    supplier_reference VARCHAR(100) NULL,
    
    -- Workflow
    created_by BIGINT UNSIGNED NULL,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_po_number (po_number),
    INDEX idx_supplier (supplier_id),
    INDEX idx_status (status),
    INDEX idx_dates (order_date, expected_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 56. PURCHASE ORDER ITEMS
-- ============================================
CREATE TABLE purchase_order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity_ordered INT NOT NULL,
    quantity_received INT DEFAULT 0,
    unit_cost DECIMAL(12, 2) NOT NULL,
    total_cost DECIMAL(14, 2) NOT NULL,
    notes TEXT NULL,
    
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 57. GOODS RECEIVED NOTES
-- ============================================
CREATE TABLE goods_received_notes (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    grn_number VARCHAR(30) UNIQUE NOT NULL,
    purchase_order_id BIGINT UNSIGNED NOT NULL,
    warehouse_id BIGINT UNSIGNED NOT NULL,
    received_date DATE NOT NULL,
    notes TEXT NULL,
    received_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (received_by) REFERENCES admin_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 58. GOODS RECEIVED NOTE ITEMS
-- ============================================
CREATE TABLE goods_received_note_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    grn_id BIGINT UNSIGNED NOT NULL,
    purchase_order_item_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity_received INT NOT NULL,
    quantity_accepted INT NOT NULL,
    quantity_rejected INT DEFAULT 0,
    rejection_reason TEXT NULL,
    
    FOREIGN KEY (grn_id) REFERENCES goods_received_notes(id) ON DELETE CASCADE,
    FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.12 جداول السلة (3 جداول)

```sql
-- ============================================
-- 59. CARTS
-- ============================================
CREATE TABLE carts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NULL,
    session_id VARCHAR(100) NULL,
    status ENUM('active', 'converted', 'abandoned', 'expired') DEFAULT 'active',
    
    -- Totals
    items_count INT UNSIGNED DEFAULT 0,
    subtotal DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Promotion
    promotion_id BIGINT UNSIGNED NULL,
    coupon_id BIGINT UNSIGNED NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    
    -- Timestamps
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    abandoned_at TIMESTAMP NULL,
    converted_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE SET NULL,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE SET NULL,
    INDEX idx_customer (customer_id),
    INDEX idx_session (session_id),
    INDEX idx_status (status),
    INDEX idx_abandoned (status, abandoned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 60. CART ITEMS
-- ============================================
CREATE TABLE cart_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    cart_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_product (cart_id, product_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 61. ABANDONED CART NOTIFICATIONS
-- ============================================
CREATE TABLE abandoned_cart_notifications (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    cart_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    notification_type ENUM('push', 'sms', 'email') NOT NULL,
    notification_number TINYINT UNSIGNED DEFAULT 1,
    sent_at TIMESTAMP NULL,
    opened_at TIMESTAMP NULL,
    clicked_at TIMESTAMP NULL,
    converted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_cart (cart_id),
    INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.13 جداول الطلبات والفواتير (6 جداول)

```sql
-- ============================================
-- 62. BANK ACCOUNTS
-- ============================================
CREATE TABLE bank_accounts (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Bank Info
    bank_name VARCHAR(100) NOT NULL,
    bank_name_ar VARCHAR(100) NULL,
    bank_code VARCHAR(20) NULL,
    
    -- Account Info
    account_name VARCHAR(150) NOT NULL,
    account_name_ar VARCHAR(150) NULL,
    account_number VARCHAR(50) NOT NULL,
    iban VARCHAR(50) NULL,
    
    -- Display
    display_name VARCHAR(100) NOT NULL,
    display_name_ar VARCHAR(100) NULL,
    logo VARCHAR(255) NULL,
    
    -- Instructions
    instructions TEXT NULL,
    instructions_ar TEXT NULL,
    
    -- Settings
    currency_code VARCHAR(3) DEFAULT 'SAR',
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    
    -- Stats
    total_received DECIMAL(14, 2) DEFAULT 0.00,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_active (is_active),
    INDEX idx_default (is_default)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 63. ORDERS
-- ============================================
CREATE TABLE orders (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(30) UNIQUE NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    cart_id BIGINT UNSIGNED NULL,
    
    -- Status
    status ENUM(
        'pending',
        'confirmed',
        'processing',
        'ready_for_shipping',
        'shipped',
        'out_for_delivery',
        'delivered',
        'cancelled',
        'refunded'
    ) DEFAULT 'pending',
    
    -- Priority
    priority ENUM('normal', 'high', 'urgent') DEFAULT 'normal',
    
    -- Shipping Address (Snapshot)
    shipping_address JSON NOT NULL,
    
    -- Amounts
    subtotal DECIMAL(14, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    shipping_amount DECIMAL(12, 2) DEFAULT 0.00,
    gift_wrap_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(14, 2) NOT NULL,
    
    -- Items Count
    items_count INT UNSIGNED NOT NULL,
    items_quantity INT UNSIGNED NOT NULL,
    
    -- Payment
    payment_method ENUM('cod', 'bank_transfer', 'wallet', 'mixed', 'online') NOT NULL,
    payment_status ENUM('pending', 'partial', 'paid', 'refunded') DEFAULT 'pending',
    
    -- Wallet Payment
    wallet_amount_used DECIMAL(12, 2) DEFAULT 0.00,
    
    -- Bank Transfer
    bank_account_id BIGINT UNSIGNED NULL,
    transfer_receipt_image VARCHAR(255) NULL,
    transfer_verified_at TIMESTAMP NULL,
    transfer_verified_by BIGINT UNSIGNED NULL,
    
    -- COD
    cod_amount DECIMAL(12, 2) DEFAULT 0.00,
    cod_collected_at TIMESTAMP NULL,
    
    -- Coupon
    coupon_id BIGINT UNSIGNED NULL,
    coupon_code VARCHAR(50) NULL,
    
    -- Promotion
    promotion_id BIGINT UNSIGNED NULL,
    promotion_code VARCHAR(50) NULL,
    
    -- Gift
    is_gift BOOLEAN DEFAULT FALSE,
    gift_message TEXT NULL,
    
    -- Delivery
    delivery_instructions TEXT NULL,
    preferred_delivery_date DATE NULL,
    preferred_delivery_time VARCHAR(50) NULL,
    allow_partial_delivery BOOLEAN DEFAULT FALSE,
    
    -- Shipping
    shipping_method VARCHAR(50) NULL,
    shipping_company VARCHAR(100) NULL,
    tracking_number VARCHAR(100) NULL,
    estimated_delivery_date DATE NULL,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    
    -- Delivery Proof
    delivery_signature VARCHAR(255) NULL,
    delivery_photo VARCHAR(255) NULL,
    
    -- Fraud
    fraud_score TINYINT UNSIGNED NULL,
    fraud_check_status ENUM('pending', 'passed', 'failed', 'manual_review') NULL,
    
    -- Attribution
    utm_source VARCHAR(100) NULL,
    utm_medium VARCHAR(100) NULL,
    utm_campaign VARCHAR(100) NULL,
    
    -- Sales Rep
    sales_rep_id BIGINT UNSIGNED NULL,
    
    -- Notes
    customer_notes TEXT NULL,
    admin_notes TEXT NULL,
    public_notes TEXT NULL,
    cancellation_reason TEXT NULL,
    
    -- Workflow
    confirmed_at TIMESTAMP NULL,
    confirmed_by BIGINT UNSIGNED NULL,
    cancelled_at TIMESTAMP NULL,
    cancelled_by BIGINT UNSIGNED NULL,
    
    -- Invoice
    invoice_id BIGINT UNSIGNED NULL,
    
    -- Source
    source ENUM('app', 'web', 'admin') DEFAULT 'app',
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE SET NULL,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE SET NULL,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE SET NULL,
    FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE SET NULL,
    FOREIGN KEY (confirmed_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (cancelled_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (transfer_verified_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (sales_rep_id) REFERENCES admin_users(id) ON DELETE SET NULL,
    
    INDEX idx_order_number (order_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_created (created_at),
    INDEX idx_orders_customer_status (customer_id, status, created_at DESC),
    INDEX idx_orders_date_status (created_at, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 64. ORDER ITEMS
-- ============================================
CREATE TABLE order_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    
    -- Product Snapshot
    product_snapshot JSON NOT NULL,
    
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    unit_cost DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_price DECIMAL(14, 2) NOT NULL,
    
    -- Customer Notes
    notes TEXT NULL,
    
    -- Return Tracking
    quantity_returned INT UNSIGNED DEFAULT 0,
    quantity_refunded INT UNSIGNED DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 65. ORDER STATUS HISTORY
-- ============================================
CREATE TABLE order_status_history (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    notes TEXT NULL,
    changed_by BIGINT UNSIGNED NULL,
    changed_by_type ENUM('customer', 'admin', 'system') DEFAULT 'system',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 66. ORDER PAYMENTS
-- ============================================
CREATE TABLE order_payments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    payment_method ENUM('cod', 'bank_transfer', 'wallet', 'online') NOT NULL,
    amount DECIMAL(14, 2) NOT NULL,
    status ENUM('pending', 'verified', 'rejected', 'refunded') DEFAULT 'pending',
    
    -- Bank Transfer Details
    bank_account_id BIGINT UNSIGNED NULL,
    transfer_reference VARCHAR(100) NULL,
    transfer_receipt_image VARCHAR(255) NULL,
    transfer_date DATE NULL,
    
    -- Online Payment Details
    gateway VARCHAR(50) NULL,
    transaction_id VARCHAR(100) NULL,
    gateway_response JSON NULL,
    
    -- Verification
    verified_at TIMESTAMP NULL,
    verified_by BIGINT UNSIGNED NULL,
    rejection_reason TEXT NULL,
    
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE SET NULL,
    FOREIGN KEY (verified_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_order (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 67. INVOICES
-- ============================================
CREATE TABLE invoices (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(30) UNIQUE NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Invoice Type
    type ENUM('sales', 'credit_note', 'debit_note') DEFAULT 'sales',
    
    -- Amounts
    subtotal DECIMAL(14, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_rate DECIMAL(5, 2) DEFAULT 15.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    shipping_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(14, 2) NOT NULL,
    
    -- Tax Info
    tax_number VARCHAR(50) NULL,
    
    -- Billing Address (Snapshot)
    billing_address JSON NOT NULL,
    
    -- Status
    status ENUM('draft', 'issued', 'paid', 'cancelled', 'refunded') DEFAULT 'draft',
    
    -- Dates
    issue_date DATE NOT NULL,
    due_date DATE NULL,
    paid_date DATE NULL,
    
    -- PDF
    pdf_path VARCHAR(255) NULL,
    
    -- Notes
    notes TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_order (order_id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_dates (issue_date, due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update orders FK
ALTER TABLE orders ADD FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL;
```

---

## 2.14 جداول المرتجعات (5 جداول)

```sql
-- ============================================
-- 68. RETURN REASONS
-- ============================================
CREATE TABLE return_reasons (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    type ENUM('defective', 'wrong_item', 'not_as_described', 'changed_mind', 'other') NOT NULL,
    requires_evidence BOOLEAN DEFAULT FALSE,
    auto_approve BOOLEAN DEFAULT FALSE,
    refund_percentage DECIMAL(5, 2) DEFAULT 100.00,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_type (type),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 69. RETURNS
-- ============================================
CREATE TABLE returns (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    return_number VARCHAR(30) UNIQUE NOT NULL,
    order_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Type
    return_type ENUM('refund', 'replacement') NOT NULL,
    
    -- Status
    status ENUM(
        'pending',
        'approved_initial',
        'rejected_initial',
        'waiting_warehouse',
        'received_warehouse',
        'inspecting',
        'inspected',
        'approved_final',
        'rejected_final',
        'refunded',
        'replaced',
        'closed'
    ) DEFAULT 'pending',
    
    -- Reason
    reason_id BIGINT UNSIGNED NULL,
    reason_text TEXT NULL,
    customer_notes TEXT NULL,
    
    -- Amounts
    total_amount DECIMAL(14, 2) NOT NULL,
    refund_amount DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Shipping
    return_shipping_method VARCHAR(50) NULL,
    return_tracking_number VARCHAR(100) NULL,
    
    -- Admin Notes
    admin_notes TEXT NULL,
    rejection_reason TEXT NULL,
    
    -- Workflow
    approved_initial_by BIGINT UNSIGNED NULL,
    approved_initial_at TIMESTAMP NULL,
    received_warehouse_at TIMESTAMP NULL,
    received_warehouse_by BIGINT UNSIGNED NULL,
    inspected_at TIMESTAMP NULL,
    inspected_by BIGINT UNSIGNED NULL,
    final_decision_by BIGINT UNSIGNED NULL,
    final_decision_at TIMESTAMP NULL,
    refunded_at TIMESTAMP NULL,
    replaced_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (reason_id) REFERENCES return_reasons(id) ON DELETE SET NULL,
    INDEX idx_return_number (return_number),
    INDEX idx_order (order_id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 70. RETURN ITEMS
-- ============================================
CREATE TABLE return_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    return_id BIGINT UNSIGNED NOT NULL,
    order_item_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price_at_order DECIMAL(12, 2) NOT NULL,
    current_price DECIMAL(12, 2) NOT NULL,
    refund_unit_price DECIMAL(12, 2) NULL,
    refund_amount DECIMAL(14, 2) NULL,
    
    -- Inspection
    inspection_status ENUM('pending', 'passed', 'failed', 'partial') DEFAULT 'pending',
    inspection_notes TEXT NULL,
    quantity_accepted INT UNSIGNED DEFAULT 0,
    quantity_rejected INT UNSIGNED DEFAULT 0,
    
    -- Replacement
    replacement_product_id BIGINT UNSIGNED NULL,
    replacement_quantity INT UNSIGNED NULL,
    
    -- Supplier Return
    linked_to_supplier BOOLEAN DEFAULT FALSE,
    supplier_return_batch_id BIGINT UNSIGNED NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (return_id) REFERENCES returns(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (replacement_product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 71. SUPPLIER RETURN BATCHES
-- ============================================
CREATE TABLE supplier_return_batches (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    batch_number VARCHAR(30) UNIQUE NOT NULL,
    supplier_id BIGINT UNSIGNED NOT NULL,
    status ENUM(
        'draft',
        'pending_approval',
        'approved',
        'sent_to_supplier',
        'acknowledged',
        'partial_credit',
        'credited',
        'rejected',
        'closed'
    ) DEFAULT 'draft',
    
    -- Amounts
    total_items INT UNSIGNED DEFAULT 0,
    total_quantity INT UNSIGNED DEFAULT 0,
    expected_credit_amount DECIMAL(14, 2) DEFAULT 0.00,
    actual_credit_amount DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Dates
    sent_date DATE NULL,
    acknowledged_date DATE NULL,
    credit_date DATE NULL,
    
    -- References
    supplier_reference VARCHAR(100) NULL,
    credit_note_number VARCHAR(50) NULL,
    
    -- Notes
    notes TEXT NULL,
    supplier_notes TEXT NULL,
    
    -- Workflow
    created_by BIGINT UNSIGNED NULL,
    approved_by BIGINT UNSIGNED NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (approved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_batch_number (batch_number),
    INDEX idx_supplier (supplier_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update return_items FK
ALTER TABLE return_items ADD FOREIGN KEY (supplier_return_batch_id) 
    REFERENCES supplier_return_batches(id) ON DELETE SET NULL;

-- ============================================
-- 72. SUPPLIER RETURN BATCH ITEMS
-- ============================================
CREATE TABLE supplier_return_batch_items (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    batch_id BIGINT UNSIGNED NOT NULL,
    return_item_id BIGINT UNSIGNED NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_cost DECIMAL(12, 2) NOT NULL,
    total_cost DECIMAL(14, 2) NOT NULL,
    
    -- Supplier Response
    quantity_accepted INT UNSIGNED DEFAULT 0,
    quantity_rejected INT UNSIGNED DEFAULT 0,
    rejection_reason TEXT NULL,
    credit_amount DECIMAL(14, 2) DEFAULT 0.00,
    
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (batch_id) REFERENCES supplier_return_batches(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.15 جداول المحفظة والولاء (3 جداول)

```sql
-- ============================================
-- 73. WALLET TRANSACTIONS
-- ============================================
CREATE TABLE wallet_transactions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    transaction_number VARCHAR(30) UNIQUE NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Type
    type ENUM(
        'credit_admin',
        'credit_refund',
        'credit_cashback',
        'credit_compensation',
        'credit_referral',
        'credit_loyalty',
        'debit_order',
        'debit_admin',
        'debit_expired'
    ) NOT NULL,
    
    -- Amount
    amount DECIMAL(14, 2) NOT NULL,
    balance_before DECIMAL(14, 2) NOT NULL,
    balance_after DECIMAL(14, 2) NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    
    -- Details
    description VARCHAR(255) NULL,
    description_ar VARCHAR(255) NULL,
    notes TEXT NULL,
    
    -- Expiry
    expires_at TIMESTAMP NULL,
    expired_at TIMESTAMP NULL,
    
    -- Admin
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_transaction_number (transaction_number),
    INDEX idx_customer (customer_id),
    INDEX idx_type (type),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_created (created_at),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 74. LOYALTY TIERS
-- ============================================
CREATE TABLE loyalty_tiers (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    name_ar VARCHAR(50) NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    
    -- Requirements
    min_points INT UNSIGNED DEFAULT 0,
    min_orders INT UNSIGNED DEFAULT 0,
    min_spent DECIMAL(14, 2) DEFAULT 0.00,
    
    -- Benefits
    points_multiplier DECIMAL(3, 2) DEFAULT 1.00,
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    free_shipping BOOLEAN DEFAULT FALSE,
    priority_support BOOLEAN DEFAULT FALSE,
    
    -- Display
    icon VARCHAR(255) NULL,
    color_code VARCHAR(7) NULL,
    
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 75. LOYALTY POINTS TRANSACTIONS
-- ============================================
CREATE TABLE loyalty_points_transactions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Type
    type ENUM(
        'earned_purchase',
        'earned_review',
        'earned_referral',
        'earned_bonus',
        'redeemed',
        'expired',
        'adjusted'
    ) NOT NULL,
    
    -- Points
    points INT NOT NULL,
    points_before INT NOT NULL,
    points_after INT NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    
    -- Details
    description VARCHAR(255) NULL,
    
    -- Expiry
    expires_at TIMESTAMP NULL,
    
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_type (type),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.16 جداول الإشعارات (3 جداول)

```sql
-- ============================================
-- 76. NOTIFICATION TEMPLATES
-- ============================================
CREATE TABLE notification_templates (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255) NULL,
    body TEXT NOT NULL,
    body_ar TEXT NULL,
    
    -- Channels
    send_push BOOLEAN DEFAULT TRUE,
    send_sms BOOLEAN DEFAULT FALSE,
    send_email BOOLEAN DEFAULT FALSE,
    
    -- Variables
    available_variables JSON NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 77. NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Recipient
    user_id BIGINT UNSIGNED NOT NULL,
    user_type ENUM('customer', 'admin') NOT NULL,
    
    -- Type
    type VARCHAR(50) NOT NULL,
    template_id BIGINT UNSIGNED NULL,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    image_url VARCHAR(255) NULL,
    
    -- Action
    action_type VARCHAR(50) NULL,
    action_data JSON NULL,
    
    -- Reference
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    -- Delivery Status
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP NULL,
    push_delivered BOOLEAN DEFAULT FALSE,
    push_delivered_at TIMESTAMP NULL,
    sms_sent BOOLEAN DEFAULT FALSE,
    sms_sent_at TIMESTAMP NULL,
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMP NULL,
    
    -- Scheduling
    scheduled_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES notification_templates(id) ON DELETE SET NULL,
    INDEX idx_user (user_id, user_type),
    INDEX idx_type (type),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at),
    INDEX idx_scheduled (scheduled_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 78. NOTIFICATION CAMPAIGNS
-- ============================================
CREATE TABLE notification_campaigns (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255) NULL,
    body TEXT NOT NULL,
    body_ar TEXT NULL,
    image_url VARCHAR(255) NULL,
    
    -- Action
    action_type VARCHAR(50) NULL,
    action_data JSON NULL,
    
    -- Targeting
    target_type ENUM('all', 'specific', 'filter') DEFAULT 'all',
    target_customer_ids JSON NULL,
    target_filters JSON NULL,
    
    -- Channels
    send_push BOOLEAN DEFAULT TRUE,
    send_sms BOOLEAN DEFAULT FALSE,
    
    -- Scheduling
    scheduled_at TIMESTAMP NULL,
    
    -- Status
    status ENUM('draft', 'scheduled', 'sending', 'sent', 'cancelled') DEFAULT 'draft',
    
    -- Stats
    total_recipients INT UNSIGNED DEFAULT 0,
    sent_count INT UNSIGNED DEFAULT 0,
    delivered_count INT UNSIGNED DEFAULT 0,
    read_count INT UNSIGNED DEFAULT 0,
    
    -- Workflow
    created_by BIGINT UNSIGNED NULL,
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_scheduled (scheduled_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.17 جداول الدعم والدردشة (6 جداول)

```sql
-- ============================================
-- 79. SUPPORT TICKET CATEGORIES
-- ============================================
CREATE TABLE support_ticket_categories (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    auto_assign_to BIGINT UNSIGNED NULL,
    sla_response_hours INT UNSIGNED DEFAULT 24,
    sla_resolution_hours INT UNSIGNED DEFAULT 72,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (auto_assign_to) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 80. SUPPORT TICKETS
-- ============================================
CREATE TABLE support_tickets (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    
    -- Customer
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Category & Priority
    category_id BIGINT UNSIGNED NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    
    -- Content
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    
    -- Reference
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    
    -- Status
    status ENUM(
        'open',
        'pending_customer',
        'pending_admin',
        'in_progress',
        'resolved',
        'closed',
        'reopened'
    ) DEFAULT 'open',
    
    -- Assignment
    assigned_to BIGINT UNSIGNED NULL,
    assigned_at TIMESTAMP NULL,
    
    -- SLA
    sla_response_due_at TIMESTAMP NULL,
    sla_resolution_due_at TIMESTAMP NULL,
    first_response_at TIMESTAMP NULL,
    sla_breached BOOLEAN DEFAULT FALSE,
    
    -- Resolution
    resolution_notes TEXT NULL,
    resolved_at TIMESTAMP NULL,
    resolved_by BIGINT UNSIGNED NULL,
    
    -- Rating
    customer_rating TINYINT UNSIGNED NULL,
    customer_feedback TEXT NULL,
    
    -- Timestamps
    last_customer_reply_at TIMESTAMP NULL,
    last_admin_reply_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (category_id) REFERENCES support_ticket_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to) REFERENCES admin_users(id) ON DELETE SET NULL,
    FOREIGN KEY (resolved_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_ticket_number (ticket_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_assigned (assigned_to),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 81. SUPPORT TICKET REPLIES
-- ============================================
CREATE TABLE support_ticket_replies (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL,
    
    -- Author
    author_type ENUM('customer', 'admin', 'system') NOT NULL,
    author_id BIGINT UNSIGNED NULL,
    
    -- Content
    message TEXT NOT NULL,
    
    -- Internal note
    is_internal BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    INDEX idx_ticket (ticket_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 82. SUPPORT TICKET ATTACHMENTS
-- ============================================
CREATE TABLE support_ticket_attachments (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT UNSIGNED NOT NULL,
    reply_id BIGINT UNSIGNED NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NULL,
    file_size INT UNSIGNED NULL,
    uploaded_by_type ENUM('customer', 'admin') NOT NULL,
    uploaded_by_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_id) REFERENCES support_ticket_replies(id) ON DELETE CASCADE,
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 83. CHAT CONVERSATIONS
-- ============================================
CREATE TABLE chat_conversations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    
    -- Status
    status ENUM('active', 'waiting', 'closed') DEFAULT 'active',
    
    -- Assignment
    assigned_to BIGINT UNSIGNED NULL,
    assigned_at TIMESTAMP NULL,
    
    -- Reference
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT UNSIGNED NULL,
    
    -- Stats
    messages_count INT UNSIGNED DEFAULT 0,
    
    -- Rating
    rating TINYINT UNSIGNED NULL,
    feedback TEXT NULL,
    
    -- Conversion
    converted_to_ticket_id BIGINT UNSIGNED NULL,
    
    last_message_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_assigned (assigned_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 84. CHAT MESSAGES
-- ============================================
CREATE TABLE chat_messages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    conversation_id BIGINT UNSIGNED NOT NULL,
    
    -- Sender
    sender_type ENUM('customer', 'admin', 'bot') NOT NULL,
    sender_id BIGINT UNSIGNED NULL,
    
    -- Content
    message TEXT NOT NULL,
    
    -- Attachments
    attachments JSON NULL,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE,
    INDEX idx_conversation (conversation_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.18 جداول المحتوى (5 جداول)

```sql
-- ============================================
-- 85. EDUCATIONAL CATEGORIES
-- ============================================
CREATE TABLE educational_categories (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_slug (slug),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 86. EDUCATIONAL CONTENT
-- ============================================
CREATE TABLE educational_content (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category_id BIGINT UNSIGNED NULL,
    
    -- Basic Info
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255) NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    
    -- Content Type
    type ENUM('article', 'video', 'guide', 'faq') NOT NULL,
    
    -- Content
    excerpt TEXT NULL,
    excerpt_ar TEXT NULL,
    content LONGTEXT NULL,
    content_ar LONGTEXT NULL,
    
    -- Media
    featured_image VARCHAR(255) NULL,
    video_url VARCHAR(255) NULL,
    video_duration INT UNSIGNED NULL,
    
    -- Related
    related_product_ids JSON NULL,
    related_device_ids JSON NULL,
    related_category_ids JSON NULL,
    
    -- SEO
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    
    -- Status
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Stats
    view_count INT UNSIGNED DEFAULT 0,
    like_count INT UNSIGNED DEFAULT 0,
    
    -- Workflow
    author_id BIGINT UNSIGNED NULL,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES educational_categories(id) ON DELETE SET NULL,
    FOREIGN KEY (author_id) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_slug (slug),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_featured (is_featured),
    INDEX idx_published (published_at),
    FULLTEXT INDEX ft_search (title, title_ar, content, content_ar)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 87. BANNERS
-- ============================================
CREATE TABLE banners (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Basic Info
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255) NULL,
    subtitle VARCHAR(255) NULL,
    subtitle_ar VARCHAR(255) NULL,
    
    -- Media
    image_desktop VARCHAR(255) NOT NULL,
    image_mobile VARCHAR(255) NULL,
    
    -- Link
    link_type ENUM('none', 'url', 'product', 'category', 'brand', 'promotion') DEFAULT 'none',
    link_value VARCHAR(255) NULL,
    
    -- Placement
    placement ENUM('home_slider', 'home_banner', 'category_banner', 'popup') NOT NULL,
    
    -- Targeting
    target_cities JSON NULL,
    target_price_levels JSON NULL,
    
    -- Schedule
    starts_at TIMESTAMP NULL,
    ends_at TIMESTAMP NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    
    -- Stats
    view_count INT UNSIGNED DEFAULT 0,
    click_count INT UNSIGNED DEFAULT 0,
    
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_placement_active (placement, is_active),
    INDEX idx_dates (starts_at, ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 88. STATIC PAGES
-- ============================================
CREATE TABLE static_pages (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(100) UNIQUE NOT NULL,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255) NULL,
    content LONGTEXT NOT NULL,
    content_ar LONGTEXT NULL,
    
    -- SEO
    meta_title VARCHAR(255) NULL,
    meta_description TEXT NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES admin_users(id) ON DELETE SET NULL,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 89. FAQS
-- ============================================
CREATE TABLE faqs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50) NULL,
    
    -- Content
    question VARCHAR(500) NOT NULL,
    question_ar VARCHAR(500) NULL,
    answer TEXT NOT NULL,
    answer_ar TEXT NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    
    -- Stats
    helpful_count INT UNSIGNED DEFAULT 0,
    not_helpful_count INT UNSIGNED DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_active_sort (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.19 جداول النظام والأمان (8 جداول)

```sql
-- ============================================
-- 90. SETTINGS
-- ============================================
CREATE TABLE settings (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    `group` VARCHAR(50) NOT NULL,
    `key` VARCHAR(100) NOT NULL,
    value LONGTEXT NULL,
    type ENUM('string', 'integer', 'boolean', 'json', 'file') DEFAULT 'string',
    display_name VARCHAR(150) NULL,
    display_name_ar VARCHAR(150) NULL,
    description TEXT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    updated_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_group_key (`group`, `key`),
    INDEX idx_group (`group`),
    INDEX idx_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 91. ACTIVITY LOGS
-- ============================================
CREATE TABLE activity_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Actor
    user_id BIGINT UNSIGNED NULL,
    user_type ENUM('customer', 'admin', 'system') NOT NULL,
    
    -- Action
    action VARCHAR(50) NOT NULL,
    module VARCHAR(50) NOT NULL,
    
    -- Subject
    subject_type VARCHAR(100) NULL,
    subject_id BIGINT UNSIGNED NULL,
    
    -- Details
    description TEXT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    
    -- Context
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user (user_id, user_type),
    INDEX idx_action (action),
    INDEX idx_module (module),
    INDEX idx_subject (subject_type, subject_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 92. SEARCH LOGS
-- ============================================
CREATE TABLE search_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NULL,
    session_id VARCHAR(100) NULL,
    
    -- Search
    query VARCHAR(255) NOT NULL,
    filters JSON NULL,
    
    -- Results
    results_count INT UNSIGNED DEFAULT 0,
    
    -- Context
    source ENUM('app', 'web') DEFAULT 'app',
    ip_address VARCHAR(45) NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    INDEX idx_query (query),
    INDEX idx_customer (customer_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 93. POPULAR SEARCHES
-- ============================================
CREATE TABLE popular_searches (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    query VARCHAR(255) NOT NULL,
    search_count INT UNSIGNED DEFAULT 1,
    last_searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_query (query),
    INDEX idx_count (search_count DESC),
    INDEX idx_featured (is_featured)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 94. RECENTLY VIEWED PRODUCTS
-- ============================================
CREATE TABLE recently_viewed_products (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    view_count INT UNSIGNED DEFAULT 1,
    last_viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_customer_recent (customer_id, last_viewed_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 95. APP VERSIONS
-- ============================================
CREATE TABLE app_versions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    platform ENUM('android', 'ios') NOT NULL,
    version VARCHAR(20) NOT NULL,
    build_number INT UNSIGNED NOT NULL,
    
    -- Update Info
    is_force_update BOOLEAN DEFAULT FALSE,
    min_supported_version VARCHAR(20) NULL,
    
    -- Release Notes
    release_notes TEXT NULL,
    release_notes_ar TEXT NULL,
    
    -- URLs
    download_url VARCHAR(255) NULL,
    store_url VARCHAR(255) NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    released_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_platform_version (platform, version),
    INDEX idx_platform_active (platform, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 2.20 جداول التكاملات (2 جدول)

```sql
-- ============================================
-- 96. INTEGRATIONS
-- ============================================
CREATE TABLE integrations (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    type ENUM('payment', 'shipping', 'sms', 'email', 'analytics', 'storage', 'other') NOT NULL,
    
    -- Configuration
    config JSON NOT NULL,
    
    -- Credentials (encrypted)
    credentials JSON NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT FALSE,
    is_sandbox BOOLEAN DEFAULT TRUE,
    
    -- Webhook
    webhook_url VARCHAR(255) NULL,
    webhook_secret VARCHAR(255) NULL,
    
    -- Stats
    last_used_at TIMESTAMP NULL,
    error_count INT UNSIGNED DEFAULT 0,
    last_error TEXT NULL,
    last_error_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_type (type),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 97. INTEGRATION LOGS
-- ============================================
CREATE TABLE integration_logs (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    integration_id BIGINT UNSIGNED NOT NULL,
    
    -- Request
    direction ENUM('outgoing', 'incoming') NOT NULL,
    endpoint VARCHAR(255) NULL,
    method VARCHAR(10) NULL,
    request_headers JSON NULL,
    request_body JSON NULL,
    
    -- Response
    response_status INT NULL,
    response_headers JSON NULL,
    response_body JSON NULL,
    
    -- Timing
    duration_ms INT UNSIGNED NULL,
    
    -- Status
    status ENUM('success', 'failed') NOT NULL,
    error_message TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (integration_id) REFERENCES integrations(id) ON DELETE CASCADE,
    INDEX idx_integration (integration_id),
    INDEX idx_created (created_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- إعادة تفعيل Foreign Keys
-- ============================================
SET FOREIGN_KEY_CHECKS = 1;
```

---

## 2.21 ملخص الجداول (97 جدول)

| # | القسم | عدد الجداول |
|---|-------|-------------|
| 1 | المصادقة والمستخدمين | 9 |
| 2 | العملاء | 4 |
| 3 | الإدارة والصلاحيات | 5 |
| 4 | المواقع | 4 |
| 5 | الكتالوج | 4 |
| 6 | المنتجات | 8 |
| 7 | التسعير | 4 |
| 8 | العروض والكوبونات | 7 |
| 9 | المخزون | 8 |
| 10 | الموردين | 5 |
| 11 | السلة | 3 |
| 12 | الطلبات والفواتير | 6 |
| 13 | المرتجعات | 5 |
| 14 | المحفظة والولاء | 3 |
| 15 | الإشعارات | 3 |
| 16 | الدعم والدردشة | 6 |
| 17 | المحتوى | 5 |
| 18 | النظام والأمان | 8 |
| 19 | التكاملات | 2 |
| **الإجمالي** | | **97 جدول** |

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 3: API Endpoints الكاملة (~262 endpoint)
# ═══════════════════════════════════════════════════════════════════════════════

## 3.1 Customer APIs (~138 endpoint)

### 3.1.1 Authentication APIs (15 endpoints)

```yaml
POST   /api/v1/auth/register              # تسجيل عميل جديد
POST   /api/v1/auth/login                 # تسجيل الدخول
POST   /api/v1/auth/logout                # تسجيل الخروج
POST   /api/v1/auth/refresh               # تجديد التوكن
POST   /api/v1/auth/send-otp              # إرسال OTP
POST   /api/v1/auth/verify-otp            # التحقق من OTP
POST   /api/v1/auth/forgot-password       # نسيت كلمة المرور
POST   /api/v1/auth/reset-password        # إعادة تعيين كلمة المرور
POST   /api/v1/auth/change-password       # تغيير كلمة المرور
GET    /api/v1/auth/me                    # بيانات المستخدم الحالي
PUT    /api/v1/auth/profile               # تحديث الملف الشخصي
POST   /api/v1/auth/fcm-token             # تحديث FCM Token
GET    /api/v1/auth/sessions              # قائمة الجلسات
DELETE /api/v1/auth/sessions/{id}         # إنهاء جلسة معينة
POST   /api/v1/auth/social/{provider}     # تسجيل دخول اجتماعي
```

### 3.1.2 Customer Profile APIs (10 endpoints)

```yaml
GET    /api/v1/customer/profile           # بيانات العميل
PUT    /api/v1/customer/profile           # تحديث البيانات
POST   /api/v1/customer/profile/avatar    # رفع صورة
DELETE /api/v1/customer/profile/avatar    # حذف الصورة
GET    /api/v1/customer/addresses         # قائمة العناوين
POST   /api/v1/customer/addresses         # إضافة عنوان
GET    /api/v1/customer/addresses/{id}    # تفاصيل عنوان
PUT    /api/v1/customer/addresses/{id}    # تحديث عنوان
DELETE /api/v1/customer/addresses/{id}    # حذف عنوان
PUT    /api/v1/customer/addresses/{id}/default  # تعيين كافتراضي
```

### 3.1.3 Wallet & Loyalty APIs (8 endpoints)

```yaml
GET    /api/v1/customer/wallet            # رصيد المحفظة
GET    /api/v1/customer/wallet/transactions  # سجل المعاملات
GET    /api/v1/customer/loyalty           # نقاط الولاء
GET    /api/v1/customer/loyalty/transactions  # سجل النقاط
GET    /api/v1/customer/loyalty/tiers     # مستويات الولاء
POST   /api/v1/customer/loyalty/redeem    # استبدال النقاط
GET    /api/v1/customer/referral          # كود الإحالة
GET    /api/v1/customer/referral/stats    # إحصائيات الإحالات
```

### 3.1.4 Catalog APIs (25 endpoints)

```yaml
# BRANDS
GET    /api/v1/brands                     # قائمة العلامات
GET    /api/v1/brands/{slug}              # تفاصيل علامة
GET    /api/v1/brands/{slug}/devices      # أجهزة العلامة
GET    /api/v1/brands/{slug}/products     # منتجات العلامة

# CATEGORIES
GET    /api/v1/categories                 # قائمة التصنيفات
GET    /api/v1/categories/tree            # شجرة التصنيفات
GET    /api/v1/categories/{slug}          # تفاصيل تصنيف
GET    /api/v1/categories/{slug}/products # منتجات التصنيف

# DEVICES
GET    /api/v1/devices                    # قائمة الأجهزة
GET    /api/v1/devices/{slug}             # تفاصيل جهاز
GET    /api/v1/devices/{slug}/products    # منتجات متوافقة

# PRODUCTS
GET    /api/v1/products                   # قائمة المنتجات
GET    /api/v1/products/search            # بحث المنتجات
GET    /api/v1/products/featured          # المنتجات المميزة
GET    /api/v1/products/new-arrivals      # الوصول الجديد
GET    /api/v1/products/best-sellers      # الأكثر مبيعاً
GET    /api/v1/products/{slug}            # تفاصيل منتج
GET    /api/v1/products/{slug}/related    # منتجات مشابهة
GET    /api/v1/products/{slug}/reviews    # تقييمات المنتج
GET    /api/v1/products/barcode/{code}    # بحث بالباركود

# SEARCH
GET    /api/v1/search/suggestions         # اقتراحات البحث
GET    /api/v1/search/popular             # عمليات البحث الشائعة
GET    /api/v1/search/history             # سجل البحث
DELETE /api/v1/search/history             # مسح سجل البحث
```

### 3.1.5 Wishlist APIs (6 endpoints)

```yaml
GET    /api/v1/wishlist                    # قائمة المفضلة
POST   /api/v1/wishlist                    # إضافة للمفضلة
DELETE /api/v1/wishlist/{product_id}       # إزالة من المفضلة
POST   /api/v1/wishlist/move-to-cart       # نقل للسلة
GET    /api/v1/wishlist/check/{product_id} # التحقق من وجود منتج
PUT    /api/v1/wishlist/{product_id}/notify # تفعيل/إلغاء التنبيهات
```

### 3.1.6 Reviews APIs (8 endpoints)

```yaml
POST   /api/v1/products/{slug}/reviews     # إضافة تقييم
PUT    /api/v1/reviews/{id}                # تعديل تقييم
DELETE /api/v1/reviews/{id}                # حذف تقييم
POST   /api/v1/reviews/{id}/vote           # تصويت (مفيد/غير مفيد)
GET    /api/v1/customer/reviews            # تقييماتي
GET    /api/v1/customer/pending-reviews    # منتجات بانتظار التقييم
GET    /api/v1/recently-viewed             # المنتجات المشاهدة مؤخراً
DELETE /api/v1/recently-viewed             # مسح السجل
```

### 3.1.7 Stock Alerts APIs (4 endpoints)

```yaml
GET    /api/v1/stock-alerts                # قائمة التنبيهات
POST   /api/v1/stock-alerts                # إنشاء تنبيه
DELETE /api/v1/stock-alerts/{id}           # حذف تنبيه
PUT    /api/v1/stock-alerts/{id}           # تعديل تنبيه
```

### 3.1.8 Cart & Checkout APIs (15 endpoints)

```yaml
# CART
GET    /api/v1/cart                       # محتويات السلة
POST   /api/v1/cart/items                 # إضافة منتج
PUT    /api/v1/cart/items/{id}            # تحديث الكمية
DELETE /api/v1/cart/items/{id}            # حذف منتج
DELETE /api/v1/cart/clear                 # تفريغ السلة
POST   /api/v1/cart/apply-coupon          # تطبيق كوبون
DELETE /api/v1/cart/remove-coupon         # إزالة كوبون

# CHECKOUT
GET    /api/v1/checkout/summary           # ملخص الطلب
POST   /api/v1/checkout/validate          # التحقق من السلة
POST   /api/v1/checkout/place-order       # إنشاء الطلب
GET    /api/v1/checkout/payment-methods   # طرق الدفع
GET    /api/v1/checkout/bank-accounts     # الحسابات البنكية

# COUPONS
POST   /api/v1/coupons/validate           # التحقق من صلاحية كوبون
GET    /api/v1/coupons/available          # الكوبونات المتاحة
GET    /api/v1/promotions/active          # العروض النشطة
```

### 3.1.9 Orders APIs (12 endpoints)

```yaml
GET    /api/v1/orders                     # قائمة الطلبات
GET    /api/v1/orders/{number}            # تفاصيل طلب
GET    /api/v1/orders/{number}/track      # تتبع الطلب
POST   /api/v1/orders/{number}/cancel     # إلغاء الطلب
POST   /api/v1/orders/{number}/reorder    # إعادة الطلب
POST   /api/v1/orders/{number}/upload-receipt  # رفع إيصال التحويل
GET    /api/v1/orders/{number}/invoice    # فاتورة PDF
GET    /api/v1/orders/{number}/items      # عناصر الطلب
POST   /api/v1/orders/{number}/rate       # تقييم الطلب
GET    /api/v1/orders/stats               # إحصائيات طلباتي
GET    /api/v1/orders/recent              # آخر الطلبات
GET    /api/v1/orders/pending-payment     # طلبات بانتظار الدفع
```

### 3.1.10 Returns APIs (8 endpoints)

```yaml
GET    /api/v1/returns                    # قائمة المرتجعات
POST   /api/v1/returns                    # طلب إرجاع جديد
GET    /api/v1/returns/{number}           # تفاصيل مرتجع
GET    /api/v1/returns/reasons            # أسباب الإرجاع
POST   /api/v1/returns/{number}/upload    # رفع صور/مستندات
GET    /api/v1/returns/{number}/track     # تتبع المرتجع
POST   /api/v1/returns/{number}/cancel    # إلغاء طلب الإرجاع
GET    /api/v1/orders/{number}/returnable-items  # العناصر القابلة للإرجاع
```

### 3.1.11 Support APIs (12 endpoints)

```yaml
# TICKETS
GET    /api/v1/support/tickets            # قائمة التذاكر
POST   /api/v1/support/tickets            # إنشاء تذكرة
GET    /api/v1/support/tickets/{number}   # تفاصيل تذكرة
POST   /api/v1/support/tickets/{number}/reply  # إضافة رد
POST   /api/v1/support/tickets/{number}/close  # إغلاق التذكرة
POST   /api/v1/support/tickets/{number}/reopen # إعادة فتح
POST   /api/v1/support/tickets/{number}/rate   # تقييم الدعم
GET    /api/v1/support/categories         # تصنيفات الدعم

# CHAT
GET    /api/v1/chat/conversations         # المحادثات
POST   /api/v1/chat/conversations         # بدء محادثة
GET    /api/v1/chat/conversations/{id}/messages  # رسائل المحادثة
POST   /api/v1/chat/conversations/{id}/messages  # إرسال رسالة
```

### 3.1.12 Notifications APIs (6 endpoints)

```yaml
GET    /api/v1/notifications              # قائمة الإشعارات
GET    /api/v1/notifications/unread-count # عدد غير المقروءة
PUT    /api/v1/notifications/{id}/read    # تحديد كمقروء
PUT    /api/v1/notifications/read-all     # تحديد الكل كمقروء
DELETE /api/v1/notifications/{id}         # حذف إشعار
PUT    /api/v1/notifications/preferences  # تحديث تفضيلات الإشعارات
```

### 3.1.13 Content APIs (9 endpoints)

```yaml
# EDUCATION
GET    /api/v1/education/categories       # تصنيفات المحتوى
GET    /api/v1/education/content          # قائمة المحتوى
GET    /api/v1/education/content/{slug}   # تفاصيل محتوى
GET    /api/v1/education/featured         # المحتوى المميز

# STATIC PAGES
GET    /api/v1/pages                      # قائمة الصفحات
GET    /api/v1/pages/{slug}               # محتوى صفحة

# FAQS
GET    /api/v1/faqs                       # قائمة الأسئلة
GET    /api/v1/faqs/categories            # تصنيفات الأسئلة
POST   /api/v1/faqs/{id}/feedback         # تقييم الإجابة
```

### 3.1.14 General APIs (10 endpoints)

```yaml
# LOCATIONS
GET    /api/v1/countries                  # قائمة الدول
GET    /api/v1/cities                     # قائمة المدن
GET    /api/v1/cities/{id}/markets        # أسواق المدينة

# BANNERS
GET    /api/v1/banners                    # البانرات النشطة
GET    /api/v1/banners/{placement}        # بانرات موقع معين
POST   /api/v1/banners/{id}/click         # تسجيل نقرة

# SETTINGS & APP
GET    /api/v1/settings/public            # الإعدادات العامة
GET    /api/v1/app/version                # التحقق من الإصدار
GET    /api/v1/app/config                 # إعدادات التطبيق
POST   /api/v1/app/feedback               # إرسال ملاحظات
```

---

## 3.2 Admin APIs (~124 endpoint)

### 3.2.1 Dashboard APIs (8 endpoints)

```yaml
GET    /api/v1/admin/dashboard/stats      # إحصائيات عامة
GET    /api/v1/admin/dashboard/sales      # إحصائيات المبيعات
GET    /api/v1/admin/dashboard/orders     # إحصائيات الطلبات
GET    /api/v1/admin/dashboard/top-products    # أكثر المنتجات مبيعاً
GET    /api/v1/admin/dashboard/top-customers   # أفضل العملاء
GET    /api/v1/admin/dashboard/low-stock       # منتجات قاربت على النفاد
GET    /api/v1/admin/dashboard/recent-orders   # آخر الطلبات
GET    /api/v1/admin/dashboard/pending-actions # الإجراءات المعلقة
```

### 3.2.2 Customers Management (15 endpoints)

```yaml
GET    /api/v1/admin/customers            # قائمة العملاء
POST   /api/v1/admin/customers            # إضافة عميل
GET    /api/v1/admin/customers/{id}       # تفاصيل عميل
PUT    /api/v1/admin/customers/{id}       # تحديث عميل
DELETE /api/v1/admin/customers/{id}       # حذف عميل
POST   /api/v1/admin/customers/{id}/approve    # الموافقة على عميل
POST   /api/v1/admin/customers/{id}/reject     # رفض عميل
POST   /api/v1/admin/customers/{id}/suspend    # تعليق عميل
POST   /api/v1/admin/customers/{id}/activate   # تفعيل عميل
POST   /api/v1/admin/customers/{id}/wallet/adjust  # تعديل المحفظة
GET    /api/v1/admin/customers/{id}/orders     # طلبات العميل
GET    /api/v1/admin/customers/{id}/wallet     # معاملات المحفظة
GET    /api/v1/admin/customers/export          # تصدير العملاء
GET    /api/v1/admin/customers/pending         # العملاء المعلقين
PUT    /api/v1/admin/customers/{id}/price-level # تغيير مستوى السعر
```

### 3.2.3 Products Management (18 endpoints)

```yaml
GET    /api/v1/admin/products             # قائمة المنتجات
POST   /api/v1/admin/products             # إضافة منتج
GET    /api/v1/admin/products/{id}        # تفاصيل منتج
PUT    /api/v1/admin/products/{id}        # تحديث منتج
DELETE /api/v1/admin/products/{id}        # حذف منتج
POST   /api/v1/admin/products/{id}/images # رفع صور
DELETE /api/v1/admin/products/{id}/images/{imageId}  # حذف صورة
PUT    /api/v1/admin/products/{id}/images/reorder    # ترتيب الصور
PUT    /api/v1/admin/products/{id}/stock  # تحديث المخزون
PUT    /api/v1/admin/products/{id}/prices # تحديث الأسعار
POST   /api/v1/admin/products/{id}/devices     # ربط بأجهزة
POST   /api/v1/admin/products/{id}/duplicate   # نسخ منتج
GET    /api/v1/admin/products/export      # تصدير المنتجات
POST   /api/v1/admin/products/import      # استيراد المنتجات
GET    /api/v1/admin/products/low-stock   # منتجات منخفضة المخزون
PUT    /api/v1/admin/products/bulk-update # تحديث جماعي
DELETE /api/v1/admin/products/bulk-delete # حذف جماعي
GET    /api/v1/admin/products/{id}/history # سجل التغييرات
```

### 3.2.4 Catalog Management (15 endpoints)

```yaml
# CATEGORIES
GET    /api/v1/admin/categories           # قائمة التصنيفات
POST   /api/v1/admin/categories           # إضافة تصنيف
GET    /api/v1/admin/categories/{id}      # تفاصيل تصنيف
PUT    /api/v1/admin/categories/{id}      # تحديث تصنيف
DELETE /api/v1/admin/categories/{id}      # حذف تصنيف
PUT    /api/v1/admin/categories/reorder   # إعادة ترتيب

# BRANDS
GET    /api/v1/admin/brands               # قائمة العلامات
POST   /api/v1/admin/brands               # إضافة علامة
PUT    /api/v1/admin/brands/{id}          # تحديث علامة
DELETE /api/v1/admin/brands/{id}          # حذف علامة

# DEVICES
GET    /api/v1/admin/devices              # قائمة الأجهزة
POST   /api/v1/admin/devices              # إضافة جهاز
PUT    /api/v1/admin/devices/{id}         # تحديث جهاز
DELETE /api/v1/admin/devices/{id}         # حذف جهاز
POST   /api/v1/admin/devices/import       # استيراد أجهزة
```

### 3.2.5 Orders Management (12 endpoints)

```yaml
GET    /api/v1/admin/orders               # قائمة الطلبات
POST   /api/v1/admin/orders               # إنشاء طلب (للعميل)
GET    /api/v1/admin/orders/{id}          # تفاصيل طلب
PUT    /api/v1/admin/orders/{id}          # تحديث طلب
PUT    /api/v1/admin/orders/{id}/status   # تغيير الحالة
POST   /api/v1/admin/orders/{id}/notes    # إضافة ملاحظة
POST   /api/v1/admin/orders/{id}/verify-payment  # التحقق من الدفع
GET    /api/v1/admin/orders/{id}/invoice  # طباعة الفاتورة
POST   /api/v1/admin/orders/{id}/ship     # شحن الطلب
POST   /api/v1/admin/orders/{id}/deliver  # تأكيد التوصيل
GET    /api/v1/admin/orders/export        # تصدير الطلبات
PUT    /api/v1/admin/orders/bulk-status   # تحديث حالة جماعي
```

### 3.2.6 Returns Management (12 endpoints)

```yaml
GET    /api/v1/admin/returns              # قائمة المرتجعات
GET    /api/v1/admin/returns/{id}         # تفاصيل مرتجع
PUT    /api/v1/admin/returns/{id}/status  # تغيير الحالة
POST   /api/v1/admin/returns/{id}/approve-initial   # موافقة مبدئية
POST   /api/v1/admin/returns/{id}/reject-initial    # رفض مبدئي
POST   /api/v1/admin/returns/{id}/receive-warehouse # استلام بالمستودع
POST   /api/v1/admin/returns/{id}/inspect           # فحص المرتجع
POST   /api/v1/admin/returns/{id}/approve-final     # موافقة نهائية
POST   /api/v1/admin/returns/{id}/reject-final      # رفض نهائي
POST   /api/v1/admin/returns/{id}/process-refund    # معالجة الاسترداد
POST   /api/v1/admin/returns/{id}/link-supplier     # ربط بدفعة مورد
GET    /api/v1/admin/return-reasons       # أسباب الإرجاع
```

### 3.2.7 Inventory Management (20 endpoints)

```yaml
# INVENTORY
GET    /api/v1/admin/inventory            # حالة المخزون
GET    /api/v1/admin/inventory/movements  # حركات المخزون
POST   /api/v1/admin/inventory/adjust     # تعديل المخزون
GET    /api/v1/admin/inventory/low-stock  # منتجات منخفضة

# WAREHOUSES
GET    /api/v1/admin/warehouses           # قائمة المستودعات
POST   /api/v1/admin/warehouses           # إضافة مستودع
GET    /api/v1/admin/warehouses/{id}      # تفاصيل مستودع
PUT    /api/v1/admin/warehouses/{id}      # تحديث مستودع
DELETE /api/v1/admin/warehouses/{id}      # حذف مستودع
GET    /api/v1/admin/warehouses/{id}/stock    # مخزون المستودع

# STOCK TRANSFERS
GET    /api/v1/admin/stock-transfers      # قائمة التحويلات
POST   /api/v1/admin/stock-transfers      # إنشاء تحويل
GET    /api/v1/admin/stock-transfers/{id} # تفاصيل تحويل
PUT    /api/v1/admin/stock-transfers/{id} # تحديث تحويل
POST   /api/v1/admin/stock-transfers/{id}/approve   # الموافقة
POST   /api/v1/admin/stock-transfers/{id}/ship      # شحن
POST   /api/v1/admin/stock-transfers/{id}/receive   # استلام

# INVENTORY COUNTS
GET    /api/v1/admin/inventory-counts     # قائمة الجرد
POST   /api/v1/admin/inventory-counts     # إنشاء جرد
PUT    /api/v1/admin/inventory-counts/{id}/complete # إتمام الجرد
```

### 3.2.8 Suppliers & Purchases (15 endpoints)

```yaml
# SUPPLIERS
GET    /api/v1/admin/suppliers            # قائمة الموردين
POST   /api/v1/admin/suppliers            # إضافة مورد
GET    /api/v1/admin/suppliers/{id}       # تفاصيل مورد
PUT    /api/v1/admin/suppliers/{id}       # تحديث مورد
DELETE /api/v1/admin/suppliers/{id}       # حذف مورد
GET    /api/v1/admin/suppliers/{id}/products       # منتجات المورد

# PURCHASE ORDERS
GET    /api/v1/admin/purchase-orders      # قائمة أوامر الشراء
POST   /api/v1/admin/purchase-orders      # إنشاء أمر شراء
GET    /api/v1/admin/purchase-orders/{id} # تفاصيل أمر شراء
PUT    /api/v1/admin/purchase-orders/{id} # تحديث أمر شراء
DELETE /api/v1/admin/purchase-orders/{id} # حذف أمر شراء
POST   /api/v1/admin/purchase-orders/{id}/approve  # الموافقة
POST   /api/v1/admin/purchase-orders/{id}/send     # إرسال للمورد
POST   /api/v1/admin/purchase-orders/{id}/receive  # استلام البضاعة

# SUPPLIER RETURNS
GET    /api/v1/admin/supplier-returns     # قائمة دفعات الإرجاع
```

### 3.2.9 Promotions & Coupons (14 endpoints)

```yaml
# PROMOTIONS
GET    /api/v1/admin/promotions           # قائمة العروض
POST   /api/v1/admin/promotions           # إنشاء عرض
GET    /api/v1/admin/promotions/{id}      # تفاصيل عرض
PUT    /api/v1/admin/promotions/{id}      # تحديث عرض
DELETE /api/v1/admin/promotions/{id}      # حذف عرض
GET    /api/v1/admin/promotions/{id}/usage    # استخدامات العرض

# COUPONS
GET    /api/v1/admin/coupons              # قائمة الكوبونات
POST   /api/v1/admin/coupons              # إضافة كوبون
GET    /api/v1/admin/coupons/{id}         # تفاصيل كوبون
PUT    /api/v1/admin/coupons/{id}         # تحديث كوبون
DELETE /api/v1/admin/coupons/{id}         # حذف كوبون
GET    /api/v1/admin/coupons/{id}/usage   # استخدامات الكوبون

# PRICE LEVELS
GET    /api/v1/admin/price-levels         # مستويات الأسعار
POST   /api/v1/admin/price-levels         # إضافة مستوى
```

### 3.2.10 Content Management (18 endpoints)

```yaml
# REVIEWS
GET    /api/v1/admin/reviews              # قائمة التقييمات
GET    /api/v1/admin/reviews/pending      # التقييمات المعلقة
PUT    /api/v1/admin/reviews/{id}/approve # الموافقة
PUT    /api/v1/admin/reviews/{id}/reject  # الرفض
DELETE /api/v1/admin/reviews/{id}         # حذف

# BANNERS
GET    /api/v1/admin/banners              # قائمة البانرات
POST   /api/v1/admin/banners              # إضافة بانر
PUT    /api/v1/admin/banners/{id}         # تحديث بانر
DELETE /api/v1/admin/banners/{id}         # حذف بانر

# STATIC PAGES
GET    /api/v1/admin/pages                # قائمة الصفحات
POST   /api/v1/admin/pages                # إضافة صفحة
PUT    /api/v1/admin/pages/{id}           # تحديث صفحة
DELETE /api/v1/admin/pages/{id}           # حذف صفحة

# FAQS
GET    /api/v1/admin/faqs                 # قائمة الأسئلة
POST   /api/v1/admin/faqs                 # إضافة سؤال
PUT    /api/v1/admin/faqs/{id}            # تحديث سؤال
DELETE /api/v1/admin/faqs/{id}            # حذف سؤال

# EDUCATION
GET    /api/v1/admin/education/content    # قائمة المحتوى
POST   /api/v1/admin/education/content    # إضافة محتوى
```

### 3.2.11 Notifications & Support (12 endpoints)

```yaml
# NOTIFICATIONS
GET    /api/v1/admin/notifications/templates  # قوالب الإشعارات
PUT    /api/v1/admin/notifications/templates/{id}  # تحديث قالب
GET    /api/v1/admin/notifications/campaigns  # الحملات
POST   /api/v1/admin/notifications/campaigns  # إنشاء حملة
POST   /api/v1/admin/notifications/campaigns/{id}/send  # إرسال حملة
POST   /api/v1/admin/notifications/send-single    # إرسال إشعار فردي

# SUPPORT
GET    /api/v1/admin/support/tickets      # قائمة التذاكر
GET    /api/v1/admin/support/tickets/{id} # تفاصيل تذكرة
POST   /api/v1/admin/support/tickets/{id}/reply     # إضافة رد
POST   /api/v1/admin/support/tickets/{id}/assign    # تعيين موظف
POST   /api/v1/admin/support/tickets/{id}/resolve   # حل التذكرة
POST   /api/v1/admin/support/tickets/{id}/close     # إغلاق التذكرة
```

### 3.2.12 Reports & Analytics (10 endpoints)

```yaml
GET    /api/v1/admin/reports/sales        # تقرير المبيعات
GET    /api/v1/admin/reports/orders       # تقرير الطلبات
GET    /api/v1/admin/reports/products     # تقرير المنتجات
GET    /api/v1/admin/reports/customers    # تقرير العملاء
GET    /api/v1/admin/reports/inventory    # تقرير المخزون
GET    /api/v1/admin/reports/returns      # تقرير المرتجعات
GET    /api/v1/admin/reports/financial    # التقرير المالي
GET    /api/v1/admin/search/analytics     # تحليلات البحث
GET    /api/v1/admin/search/popular       # الكلمات الشائعة
GET    /api/v1/admin/search/no-results    # بحث بدون نتائج
```

### 3.2.13 Settings & System (15 endpoints)

```yaml
# SETTINGS
GET    /api/v1/admin/settings             # جميع الإعدادات
GET    /api/v1/admin/settings/{group}     # إعدادات مجموعة
PUT    /api/v1/admin/settings             # تحديث الإعدادات

# LOCATIONS
GET    /api/v1/admin/countries            # الدول
POST   /api/v1/admin/countries            # إضافة دولة
GET    /api/v1/admin/cities               # المدن
POST   /api/v1/admin/cities               # إضافة مدينة
GET    /api/v1/admin/shipping-zones       # مناطق الشحن
POST   /api/v1/admin/shipping-zones       # إضافة منطقة

# BANK ACCOUNTS
GET    /api/v1/admin/bank-accounts        # الحسابات البنكية
POST   /api/v1/admin/bank-accounts        # إضافة حساب
PUT    /api/v1/admin/bank-accounts/{id}   # تحديث حساب

# APP VERSIONS
GET    /api/v1/admin/app-versions         # قائمة الإصدارات
POST   /api/v1/admin/app-versions         # إضافة إصدار
PUT    /api/v1/admin/app-versions/{id}    # تحديث إصدار
```

### 3.2.14 Users & Roles (12 endpoints)

```yaml
# ADMIN USERS
GET    /api/v1/admin/users                # قائمة المستخدمين
POST   /api/v1/admin/users                # إضافة مستخدم
GET    /api/v1/admin/users/{id}           # تفاصيل مستخدم
PUT    /api/v1/admin/users/{id}           # تحديث مستخدم
DELETE /api/v1/admin/users/{id}           # حذف مستخدم
PUT    /api/v1/admin/users/{id}/roles     # تحديث الأدوار

# ROLES
GET    /api/v1/admin/roles                # قائمة الأدوار
POST   /api/v1/admin/roles                # إضافة دور
GET    /api/v1/admin/roles/{id}           # تفاصيل دور
PUT    /api/v1/admin/roles/{id}           # تحديث دور
DELETE /api/v1/admin/roles/{id}           # حذف دور
GET    /api/v1/admin/permissions          # قائمة الصلاحيات
```

### 3.2.15 Activity Logs (3 endpoints)

```yaml
GET    /api/v1/admin/activity-logs        # سجل النشاطات
GET    /api/v1/admin/activity-logs/export # تصدير السجل
GET    /api/v1/admin/activity-logs/{id}   # تفاصيل نشاط
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 4: هيكل تطبيق Flutter (~66 شاشة)
# ═══════════════════════════════════════════════════════════════════════════════

## 4.1 بنية المجلدات

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── api_config.dart
│   │   └── theme_config.dart
│   │
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_endpoints.dart
│   │   └── storage_keys.dart
│   │
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_interceptor.dart
│   │   └── network_info.dart
│   │
│   ├── storage/
│   │   ├── local_storage.dart
│   │   └── secure_storage.dart
│   │
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── helpers.dart
│   │   └── extensions.dart
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_loading.dart
│       ├── app_error.dart
│       ├── app_image.dart
│       └── ...
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── catalog/
│   ├── cart/
│   ├── checkout/
│   ├── orders/
│   ├── returns/
│   ├── wallet/
│   ├── wishlist/
│   ├── reviews/
│   ├── profile/
│   ├── notifications/
│   ├── support/
│   ├── education/
│   └── admin/
│
├── l10n/
│   ├── app_ar.arb
│   └── app_en.arb
│
└── routes/
    ├── app_router.dart
    └── route_guards.dart
```

## 4.2 قائمة الشاشات الكاملة (66 شاشة)

```yaml
# ─────────────────────────────────────────────────────────────
# AUTH SCREENS (6 شاشات)
# ─────────────────────────────────────────────────────────────
- SplashScreen                    # شاشة البداية
- OnboardingScreen                # شاشة التعريف
- LoginScreen                     # تسجيل الدخول
- RegisterScreen                  # التسجيل
- OtpVerificationScreen           # التحقق من OTP
- ForgotPasswordScreen            # نسيت كلمة المرور

# ─────────────────────────────────────────────────────────────
# HOME & CATALOG (12 شاشة)
# ─────────────────────────────────────────────────────────────
- HomeScreen                      # الصفحة الرئيسية
- SearchScreen                    # البحث
- SearchHistoryScreen             # سجل البحث
- AdvancedSearchScreen            # بحث متقدم
- BrandsListScreen                # قائمة العلامات
- BrandDetailsScreen              # تفاصيل علامة
- CategoriesListScreen            # قائمة التصنيفات
- CategoryProductsScreen          # منتجات التصنيف
- DevicesListScreen               # قائمة الأجهزة
- DeviceProductsScreen            # منتجات الجهاز
- ProductDetailsScreen            # تفاصيل منتج
- ProductSearchResultsScreen      # نتائج البحث

# ─────────────────────────────────────────────────────────────
# WISHLIST & REVIEWS (7 شاشات)
# ─────────────────────────────────────────────────────────────
- WishlistScreen                  # قائمة المفضلة
- WishlistEmptyScreen             # المفضلة فارغة
- ProductReviewsScreen            # تقييمات المنتج
- WriteReviewScreen               # كتابة تقييم
- MyReviewsScreen                 # تقييماتي
- PendingReviewsScreen            # منتجات بانتظار التقييم
- StockAlertsScreen               # تنبيهات المخزون

# ─────────────────────────────────────────────────────────────
# CART & CHECKOUT (5 شاشات)
# ─────────────────────────────────────────────────────────────
- CartScreen                      # السلة
- CheckoutScreen                  # الدفع
- AddressSelectionScreen          # اختيار العنوان
- PaymentMethodScreen             # طريقة الدفع
- OrderConfirmationScreen         # تأكيد الطلب

# ─────────────────────────────────────────────────────────────
# ORDERS (5 شاشات)
# ─────────────────────────────────────────────────────────────
- OrdersListScreen                # قائمة الطلبات
- OrderDetailsScreen              # تفاصيل طلب
- OrderTrackingScreen             # تتبع الطلب
- UploadReceiptScreen             # رفع إيصال التحويل
- InvoiceViewScreen               # عرض الفاتورة

# ─────────────────────────────────────────────────────────────
# RETURNS (3 شاشات)
# ─────────────────────────────────────────────────────────────
- ReturnsListScreen               # قائمة المرتجعات
- ReturnDetailsScreen             # تفاصيل مرتجع
- CreateReturnScreen              # طلب إرجاع جديد

# ─────────────────────────────────────────────────────────────
# WALLET & LOYALTY (4 شاشات)
# ─────────────────────────────────────────────────────────────
- WalletScreen                    # المحفظة
- WalletTransactionsScreen        # سجل المعاملات
- LoyaltyPointsScreen             # نقاط الولاء

# ─────────────────────────────────────────────────────────────
# PROFILE (8 شاشات)
# ─────────────────────────────────────────────────────────────
- ProfileScreen                   # الملف الشخصي
- EditProfileScreen               # تعديل الملف
- AddressesListScreen             # قائمة العناوين
- AddEditAddressScreen            # إضافة/تعديل عنوان
- ChangePasswordScreen            # تغيير كلمة المرور
- SettingsScreen                  # الإعدادات
- NotificationSettingsScreen      # إعدادات الإشعارات
- LanguageSettingsScreen          # إعدادات اللغة

# ─────────────────────────────────────────────────────────────
# NOTIFICATIONS (2 شاشة)
# ─────────────────────────────────────────────────────────────
- NotificationsListScreen         # قائمة الإشعارات
- NotificationDetailsScreen       # تفاصيل إشعار

# ─────────────────────────────────────────────────────────────
# SUPPORT (5 شاشات)
# ─────────────────────────────────────────────────────────────
- SupportTicketsListScreen        # قائمة التذاكر
- TicketDetailsScreen             # تفاصيل تذكرة
- CreateTicketScreen              # إنشاء تذكرة
- TicketChatScreen                # محادثة التذكرة
- LiveChatScreen                  # الدردشة المباشرة

# ─────────────────────────────────────────────────────────────
# EDUCATION & CONTENT (5 شاشات)
# ─────────────────────────────────────────────────────────────
- EducationCategoriesScreen       # تصنيفات المحتوى
- EducationListScreen             # قائمة المحتوى
- EducationDetailsScreen          # تفاصيل محتوى
- FAQScreen                       # الأسئلة الشائعة
- StaticPageScreen                # صفحة ثابتة (عن، شروط، خصوصية)

# ─────────────────────────────────────────────────────────────
# ADMIN MODE (4 شاشات)
# ─────────────────────────────────────────────────────────────
- AdminDashboardScreen            # لوحة التحكم
- AdminOrdersScreen               # إدارة الطلبات
- AdminOrderDetailsScreen         # تفاصيل طلب
- AdminCustomersScreen            # إدارة العملاء
```

## 4.3 الحزم المطلوبة (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Routing
  go_router: ^13.0.1

  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.2

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive_flutter: ^1.1.0

  # UI
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9
  lottie: ^3.0.0

  # Forms
  flutter_form_builder: ^9.2.1
  form_builder_validators: ^9.1.0

  # Utils
  intl: ^0.18.1
  url_launcher: ^6.2.2
  share_plus: ^7.2.1
  image_picker: ^1.0.7
  file_picker: ^6.1.1
  permission_handler: ^11.2.0

  # Maps
  google_maps_flutter: ^2.5.3
  geolocator: ^10.1.0

  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0

  # Other
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  equatable: ^2.0.5
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
  mockito: ^5.4.4
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 5: هيكل لوحة التحكم React (~66 صفحة)
# ═══════════════════════════════════════════════════════════════════════════════

## 5.1 بنية المجلدات

```
src/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── providers.tsx
│   │
│   ├── (auth)/
│   │   ├── login/
│   │   └── forgot-password/
│   │
│   └── (dashboard)/
│       ├── layout.tsx
│       ├── page.tsx                    # Dashboard
│       │
│       ├── customers/
│       ├── products/
│       ├── categories/
│       ├── brands/
│       ├── devices/
│       ├── orders/
│       ├── returns/
│       ├── inventory/
│       ├── suppliers/
│       ├── promotions/
│       ├── coupons/
│       ├── reviews/
│       ├── banners/
│       ├── pages/
│       ├── faqs/
│       ├── notifications/
│       ├── support/
│       ├── education/
│       ├── reports/
│       ├── settings/
│       ├── users/
│       ├── invoices/
│       ├── app-versions/
│       ├── search-analytics/
│       └── activity-logs/
│
├── components/
│   ├── ui/                             # Shadcn components
│   ├── layout/
│   ├── forms/
│   ├── tables/
│   └── charts/
│
├── hooks/
├── lib/
├── stores/
├── types/
└── styles/
```

## 5.2 قائمة الصفحات الكاملة (66 صفحة)

```yaml
# ─────────────────────────────────────────────────────────────
# AUTH (2 صفحات)
# ─────────────────────────────────────────────────────────────
- LoginPage                       # تسجيل الدخول
- ForgotPasswordPage              # نسيت كلمة المرور

# ─────────────────────────────────────────────────────────────
# DASHBOARD (1 صفحة)
# ─────────────────────────────────────────────────────────────
- DashboardPage                   # لوحة التحكم الرئيسية

# ─────────────────────────────────────────────────────────────
# CUSTOMERS (4 صفحات)
# ─────────────────────────────────────────────────────────────
- CustomersListPage               # قائمة العملاء
- CustomerDetailsPage             # تفاصيل عميل
- PendingCustomersPage            # العملاء المعلقين
- CustomerFinancialPage           # الكشف المالي للعميل

# ─────────────────────────────────────────────────────────────
# PRODUCTS (5 صفحات)
# ─────────────────────────────────────────────────────────────
- ProductsListPage                # قائمة المنتجات
- ProductDetailsPage              # تفاصيل/تعديل منتج
- CreateProductPage               # إضافة منتج
- ImportProductsPage              # استيراد المنتجات
- LowStockProductsPage            # منتجات منخفضة المخزون

# ─────────────────────────────────────────────────────────────
# CATALOG (8 صفحات)
# ─────────────────────────────────────────────────────────────
- CategoriesListPage              # قائمة التصنيفات
- CategoryDetailsPage             # تفاصيل تصنيف
- BrandsListPage                  # قائمة العلامات
- BrandDetailsPage                # تفاصيل علامة
- DevicesListPage                 # قائمة الأجهزة
- DeviceDetailsPage               # تفاصيل جهاز
- QualityTypesPage                # أنواع الجودة
- TagsPage                        # الوسوم

# ─────────────────────────────────────────────────────────────
# ORDERS (4 صفحات)
# ─────────────────────────────────────────────────────────────
- OrdersListPage                  # قائمة الطلبات
- OrderDetailsPage                # تفاصيل طلب
- CreateOrderPage                 # إنشاء طلب
- PendingPaymentsPage             # طلبات بانتظار الدفع

# ─────────────────────────────────────────────────────────────
# RETURNS (3 صفحات)
# ─────────────────────────────────────────────────────────────
- ReturnsListPage                 # قائمة المرتجعات
- ReturnDetailsPage               # تفاصيل مرتجع
- ReturnReasonsPage               # أسباب الإرجاع

# ─────────────────────────────────────────────────────────────
# INVENTORY (6 صفحات)
# ─────────────────────────────────────────────────────────────
- InventoryOverviewPage           # نظرة عامة على المخزون
- WarehousesListPage              # قائمة المستودعات
- WarehouseDetailsPage            # تفاصيل مستودع
- StockMovementsPage              # حركات المخزون
- StockTransfersPage              # تحويلات المخزون
- InventoryCountsPage             # الجرد

# ─────────────────────────────────────────────────────────────
# SUPPLIERS (5 صفحات)
# ─────────────────────────────────────────────────────────────
- SuppliersListPage               # قائمة الموردين
- SupplierDetailsPage             # تفاصيل مورد
- PurchaseOrdersPage              # أوامر الشراء
- PurchaseOrderDetailsPage        # تفاصيل أمر شراء
- SupplierReturnsPage             # مرتجعات الموردين

# ─────────────────────────────────────────────────────────────
# PROMOTIONS & COUPONS (4 صفحات)
# ─────────────────────────────────────────────────────────────
- PromotionsListPage              # قائمة العروض
- PromotionDetailsPage            # تفاصيل عرض
- CouponsListPage                 # قائمة الكوبونات
- CouponDetailsPage               # تفاصيل كوبون

# ─────────────────────────────────────────────────────────────
# CONTENT (8 صفحات)
# ─────────────────────────────────────────────────────────────
- ReviewsListPage                 # قائمة التقييمات
- ReviewsModerationPage           # إدارة التقييمات المعلقة
- BannersListPage                 # قائمة البانرات
- BannerDetailsPage               # تفاصيل بانر
- StaticPagesListPage             # قائمة الصفحات
- StaticPageEditorPage            # محرر الصفحات
- FAQsPage                        # إدارة الأسئلة الشائعة
- EducationContentPage            # المحتوى التعليمي

# ─────────────────────────────────────────────────────────────
# NOTIFICATIONS (3 صفحات)
# ─────────────────────────────────────────────────────────────
- NotificationTemplatesPage       # قوالب الإشعارات
- NotificationCampaignsPage       # الحملات
- CampaignDetailsPage             # تفاصيل حملة

# ─────────────────────────────────────────────────────────────
# SUPPORT (3 صفحات)
# ─────────────────────────────────────────────────────────────
- SupportTicketsPage              # قائمة التذاكر
- TicketDetailsPage               # تفاصيل تذكرة
- SupportCategoriesPage           # تصنيفات الدعم

# ─────────────────────────────────────────────────────────────
# REPORTS (6 صفحات)
# ─────────────────────────────────────────────────────────────
- SalesReportPage                 # تقرير المبيعات
- OrdersReportPage                # تقرير الطلبات
- ProductsReportPage              # تقرير المنتجات
- CustomersReportPage             # تقرير العملاء
- InventoryReportPage             # تقرير المخزون
- FinancialReportPage             # التقرير المالي

# ─────────────────────────────────────────────────────────────
# SETTINGS (7 صفحات)
# ─────────────────────────────────────────────────────────────
- GeneralSettingsPage             # الإعدادات العامة
- LocationsSettingsPage           # إعدادات المواقع
- PaymentSettingsPage             # إعدادات الدفع
- ShippingSettingsPage            # إعدادات الشحن
- PricingSettingsPage             # إعدادات التسعير
- BankAccountsPage                # الحسابات البنكية
- IntegrationsPage                # التكاملات

# ─────────────────────────────────────────────────────────────
# USERS & ROLES (4 صفحات)
# ─────────────────────────────────────────────────────────────
- AdminUsersPage                  # المستخدمين الإداريين
- UserDetailsPage                 # تفاصيل مستخدم
- RolesPage                       # الأدوار
- PermissionsPage                 # الصلاحيات

# ─────────────────────────────────────────────────────────────
# SYSTEM (4 صفحات)
# ─────────────────────────────────────────────────────────────
- InvoicesPage                    # قائمة الفواتير
- AppVersionsPage                 # إدارة إصدارات التطبيق
- SearchAnalyticsPage             # تحليلات البحث
- ActivityLogsPage                # سجل النشاطات
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 6: نظام الأمان والحماية
# ═══════════════════════════════════════════════════════════════════════════════

## 6.1 المصادقة والتفويض

```yaml
Authentication:
  - JWT Tokens (Access + Refresh)
  - Access Token TTL: 60 minutes
  - Refresh Token TTL: 14 days
  - Token Blacklisting on logout
  - Device-based sessions
  - Two-Factor Authentication (optional for admins)
  - Social Login (Google, Apple)
  - Biometric Authentication (Fingerprint/Face ID)

Authorization:
  - Role-Based Access Control (RBAC)
  - Permission-based middleware
  - Resource ownership validation
  - API scope restrictions
```

## 6.2 حماية API

```yaml
Rate Limiting:
  - Global: 1000 requests/minute per IP
  - Auth endpoints: 10 requests/minute per IP
  - OTP endpoints: 5 requests/minute per phone
  - Search endpoints: 60 requests/minute per user

Input Validation:
  - Request body validation
  - Query parameter sanitization
  - File upload validation (type, size)
  - SQL injection prevention
  - XSS prevention

Headers:
  - CORS configuration
  - Content-Security-Policy
  - X-Frame-Options: DENY
  - X-Content-Type-Options: nosniff
  - Strict-Transport-Security
```

## 6.3 حماية البيانات

```yaml
Encryption:
  - Passwords: bcrypt (cost 12)
  - Sensitive data: AES-256
  - API communication: TLS 1.3

Data Protection:
  - Soft delete for important records
  - Audit logging for sensitive operations
  - PII data masking in logs
  - Database encryption at rest
```

## 6.4 قائمة الصلاحيات الكاملة (95 صلاحية)

```sql
INSERT INTO permissions (module, action, name, display_name, display_name_ar) VALUES
-- Dashboard
('dashboard', 'view', 'dashboard.view', 'View Dashboard', 'عرض لوحة التحكم'),

-- Orders
('orders', 'view', 'orders.view', 'View Orders', 'عرض الطلبات'),
('orders', 'create', 'orders.create', 'Create Orders', 'إنشاء الطلبات'),
('orders', 'edit', 'orders.edit', 'Edit Orders', 'تعديل الطلبات'),
('orders', 'delete', 'orders.delete', 'Delete Orders', 'حذف الطلبات'),
('orders', 'export', 'orders.export', 'Export Orders', 'تصدير الطلبات'),
('orders', 'change_status', 'orders.change_status', 'Change Order Status', 'تغيير حالة الطلب'),
('orders', 'verify_payment', 'orders.verify_payment', 'Verify Payment', 'التحقق من الدفع'),
('orders', 'print_invoice', 'orders.print_invoice', 'Print Invoice', 'طباعة الفاتورة'),

-- Products
('products', 'view', 'products.view', 'View Products', 'عرض المنتجات'),
('products', 'create', 'products.create', 'Create Products', 'إنشاء المنتجات'),
('products', 'edit', 'products.edit', 'Edit Products', 'تعديل المنتجات'),
('products', 'delete', 'products.delete', 'Delete Products', 'حذف المنتجات'),
('products', 'export', 'products.export', 'Export Products', 'تصدير المنتجات'),
('products', 'import', 'products.import', 'Import Products', 'استيراد المنتجات'),
('products', 'manage_stock', 'products.manage_stock', 'Manage Stock', 'إدارة المخزون'),
('products', 'manage_prices', 'products.manage_prices', 'Manage Prices', 'إدارة الأسعار'),

-- Categories
('categories', 'view', 'categories.view', 'View Categories', 'عرض التصنيفات'),
('categories', 'create', 'categories.create', 'Create Categories', 'إنشاء التصنيفات'),
('categories', 'edit', 'categories.edit', 'Edit Categories', 'تعديل التصنيفات'),
('categories', 'delete', 'categories.delete', 'Delete Categories', 'حذف التصنيفات'),

-- Brands
('brands', 'view', 'brands.view', 'View Brands', 'عرض العلامات'),
('brands', 'create', 'brands.create', 'Create Brands', 'إنشاء العلامات'),
('brands', 'edit', 'brands.edit', 'Edit Brands', 'تعديل العلامات'),
('brands', 'delete', 'brands.delete', 'Delete Brands', 'حذف العلامات'),

-- Devices
('devices', 'view', 'devices.view', 'View Devices', 'عرض الأجهزة'),
('devices', 'create', 'devices.create', 'Create Devices', 'إنشاء الأجهزة'),
('devices', 'edit', 'devices.edit', 'Edit Devices', 'تعديل الأجهزة'),
('devices', 'delete', 'devices.delete', 'Delete Devices', 'حذف الأجهزة'),
('devices', 'import', 'devices.import', 'Import Devices', 'استيراد الأجهزة'),

-- Customers
('customers', 'view', 'customers.view', 'View Customers', 'عرض العملاء'),
('customers', 'create', 'customers.create', 'Create Customers', 'إنشاء العملاء'),
('customers', 'edit', 'customers.edit', 'Edit Customers', 'تعديل العملاء'),
('customers', 'delete', 'customers.delete', 'Delete Customers', 'حذف العملاء'),
('customers', 'export', 'customers.export', 'Export Customers', 'تصدير العملاء'),
('customers', 'approve', 'customers.approve', 'Approve Customers', 'الموافقة على العملاء'),
('customers', 'suspend', 'customers.suspend', 'Suspend Customers', 'تعليق العملاء'),
('customers', 'adjust_wallet', 'customers.adjust_wallet', 'Adjust Wallet', 'تعديل المحفظة'),
('customers', 'view_financial', 'customers.view_financial', 'View Financial Statement', 'عرض الكشف المالي'),

-- Returns
('returns', 'view', 'returns.view', 'View Returns', 'عرض المرتجعات'),
('returns', 'process', 'returns.process', 'Process Returns', 'معالجة المرتجعات'),
('returns', 'approve', 'returns.approve', 'Approve Returns', 'الموافقة على المرتجعات'),
('returns', 'reject', 'returns.reject', 'Reject Returns', 'رفض المرتجعات'),
('returns', 'link_supplier', 'returns.link_supplier', 'Link to Supplier', 'ربط بالمورد'),

-- Suppliers
('suppliers', 'view', 'suppliers.view', 'View Suppliers', 'عرض الموردين'),
('suppliers', 'create', 'suppliers.create', 'Create Suppliers', 'إنشاء الموردين'),
('suppliers', 'edit', 'suppliers.edit', 'Edit Suppliers', 'تعديل الموردين'),
('suppliers', 'delete', 'suppliers.delete', 'Delete Suppliers', 'حذف الموردين'),
('suppliers', 'manage_returns', 'suppliers.manage_returns', 'Manage Supplier Returns', 'إدارة مرتجعات الموردين'),

-- Purchase Orders
('purchase_orders', 'view', 'purchase_orders.view', 'View Purchase Orders', 'عرض أوامر الشراء'),
('purchase_orders', 'create', 'purchase_orders.create', 'Create Purchase Orders', 'إنشاء أوامر الشراء'),
('purchase_orders', 'edit', 'purchase_orders.edit', 'Edit Purchase Orders', 'تعديل أوامر الشراء'),
('purchase_orders', 'delete', 'purchase_orders.delete', 'Delete Purchase Orders', 'حذف أوامر الشراء'),
('purchase_orders', 'approve', 'purchase_orders.approve', 'Approve Purchase Orders', 'الموافقة على أوامر الشراء'),
('purchase_orders', 'receive', 'purchase_orders.receive', 'Receive Goods', 'استلام البضاعة'),

-- Inventory
('inventory', 'view', 'inventory.view', 'View Inventory', 'عرض المخزون'),
('inventory', 'adjust', 'inventory.adjust', 'Adjust Inventory', 'تعديل المخزون'),
('inventory', 'transfer', 'inventory.transfer', 'Transfer Stock', 'تحويل المخزون'),
('inventory', 'view_movements', 'inventory.view_movements', 'View Movements', 'عرض الحركات'),
('inventory', 'count', 'inventory.count', 'Inventory Count', 'جرد المخزون'),

-- Promotions
('promotions', 'view', 'promotions.view', 'View Promotions', 'عرض العروض'),
('promotions', 'create', 'promotions.create', 'Create Promotions', 'إنشاء العروض'),
('promotions', 'edit', 'promotions.edit', 'Edit Promotions', 'تعديل العروض'),
('promotions', 'delete', 'promotions.delete', 'Delete Promotions', 'حذف العروض'),

-- Coupons
('coupons', 'view', 'coupons.view', 'View Coupons', 'عرض الكوبونات'),
('coupons', 'create', 'coupons.create', 'Create Coupons', 'إنشاء الكوبونات'),
('coupons', 'edit', 'coupons.edit', 'Edit Coupons', 'تعديل الكوبونات'),
('coupons', 'delete', 'coupons.delete', 'Delete Coupons', 'حذف الكوبونات'),

-- Reviews
('reviews', 'view', 'reviews.view', 'View Reviews', 'عرض التقييمات'),
('reviews', 'moderate', 'reviews.moderate', 'Moderate Reviews', 'إدارة التقييمات'),
('reviews', 'delete', 'reviews.delete', 'Delete Reviews', 'حذف التقييمات'),

-- Banners
('banners', 'view', 'banners.view', 'View Banners', 'عرض البانرات'),
('banners', 'create', 'banners.create', 'Create Banners', 'إنشاء البانرات'),
('banners', 'edit', 'banners.edit', 'Edit Banners', 'تعديل البانرات'),
('banners', 'delete', 'banners.delete', 'Delete Banners', 'حذف البانرات'),

-- Pages
('pages', 'view', 'pages.view', 'View Pages', 'عرض الصفحات'),
('pages', 'create', 'pages.create', 'Create Pages', 'إنشاء الصفحات'),
('pages', 'edit', 'pages.edit', 'Edit Pages', 'تعديل الصفحات'),
('pages', 'delete', 'pages.delete', 'Delete Pages', 'حذف الصفحات'),

-- FAQs
('faqs', 'view', 'faqs.view', 'View FAQs', 'عرض الأسئلة الشائعة'),
('faqs', 'manage', 'faqs.manage', 'Manage FAQs', 'إدارة الأسئلة الشائعة'),

-- Notifications
('notifications', 'view', 'notifications.view', 'View Notifications', 'عرض الإشعارات'),
('notifications', 'create', 'notifications.create', 'Create Notifications', 'إنشاء الإشعارات'),
('notifications', 'send', 'notifications.send', 'Send Notifications', 'إرسال الإشعارات'),

-- Education
('education', 'view', 'education.view', 'View Education', 'عرض المحتوى التعليمي'),
('education', 'create', 'education.create', 'Create Education', 'إنشاء المحتوى التعليمي'),
('education', 'edit', 'education.edit', 'Edit Education', 'تعديل المحتوى التعليمي'),
('education', 'delete', 'education.delete', 'Delete Education', 'حذف المحتوى التعليمي'),
('education', 'publish', 'education.publish', 'Publish Education', 'نشر المحتوى التعليمي'),

-- Support
('support', 'view', 'support.view', 'View Support Tickets', 'عرض تذاكر الدعم'),
('support', 'reply', 'support.reply', 'Reply to Tickets', 'الرد على التذاكر'),
('support', 'close', 'support.close', 'Close Tickets', 'إغلاق التذاكر'),
('support', 'assign', 'support.assign', 'Assign Tickets', 'تعيين التذاكر'),

-- Reports
('reports', 'view_sales', 'reports.view_sales', 'View Sales Reports', 'عرض تقارير المبيعات'),
('reports', 'view_inventory', 'reports.view_inventory', 'View Inventory Reports', 'عرض تقارير المخزون'),
('reports', 'view_financial', 'reports.view_financial', 'View Financial Reports', 'عرض التقارير المالية'),
('reports', 'view_customers', 'reports.view_customers', 'View Customer Reports', 'عرض تقارير العملاء'),
('reports', 'export', 'reports.export', 'Export Reports', 'تصدير التقارير'),

-- Settings
('settings', 'view', 'settings.view', 'View Settings', 'عرض الإعدادات'),
('settings', 'edit', 'settings.edit', 'Edit Settings', 'تعديل الإعدادات'),
('settings', 'manage_locations', 'settings.manage_locations', 'Manage Locations', 'إدارة المواقع'),
('settings', 'manage_payment', 'settings.manage_payment', 'Manage Payment Methods', 'إدارة طرق الدفع'),
('settings', 'manage_shipping', 'settings.manage_shipping', 'Manage Shipping', 'إدارة الشحن'),

-- Invoices
('invoices', 'view', 'invoices.view', 'View Invoices', 'عرض الفواتير'),
('invoices', 'export', 'invoices.export', 'Export Invoices', 'تصدير الفواتير'),

-- App Versions
('app_versions', 'view', 'app_versions.view', 'View App Versions', 'عرض إصدارات التطبيق'),
('app_versions', 'manage', 'app_versions.manage', 'Manage App Versions', 'إدارة إصدارات التطبيق'),

-- Integrations
('integrations', 'view', 'integrations.view', 'View Integrations', 'عرض التكاملات'),
('integrations', 'manage', 'integrations.manage', 'Manage Integrations', 'إدارة التكاملات'),

-- Admin Users
('admin_users', 'view', 'admin_users.view', 'View Admin Users', 'عرض المستخدمين'),
('admin_users', 'create', 'admin_users.create', 'Create Admin Users', 'إنشاء المستخدمين'),
('admin_users', 'edit', 'admin_users.edit', 'Edit Admin Users', 'تعديل المستخدمين'),
('admin_users', 'delete', 'admin_users.delete', 'Delete Admin Users', 'حذف المستخدمين'),
('admin_users', 'manage_roles', 'admin_users.manage_roles', 'Manage Roles', 'إدارة الأدوار'),

-- Activity Logs
('activity_logs', 'view', 'activity_logs.view', 'View Activity Logs', 'عرض سجل النشاطات'),
('activity_logs', 'export', 'activity_logs.export', 'Export Activity Logs', 'تصدير سجل النشاطات');
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 7: تحسينات الأداء
# ═══════════════════════════════════════════════════════════════════════════════

## 7.1 استراتيجية التخزين المؤقت (Redis Caching)

```yaml
بيانات ثابتة (TTL: 24 ساعة):
  - التصنيفات
  - العلامات التجارية
  - الأجهزة
  - المدن والمناطق
  - الإعدادات العامة
  - مستويات الأسعار

بيانات شبه ثابتة (TTL: 1 ساعة):
  - قوائم المنتجات
  - البانرات
  - العروض النشطة
  - الأسئلة الشائعة

بيانات ديناميكية (TTL: 5-15 دقيقة):
  - أسعار المنتجات
  - كميات المخزون
  - إحصائيات Dashboard

بيانات المستخدم (TTL: 30 دقيقة):
  - بيانات الجلسة
  - السلة
  - المفضلة
```

## 7.2 تحسين البحث (Meilisearch)

```yaml
Indexes:
  - products: للبحث في المنتجات
  - devices: للبحث في الأجهزة
  - customers: للبحث في العملاء (Admin)
  - orders: للبحث في الطلبات (Admin)

Searchable Attributes (Products):
  - name, name_ar
  - sku, barcode
  - description
  - brand_name
  - category_name
  - device_names

Filterable Attributes:
  - brand_id, category_id
  - device_ids, quality_type_id
  - status, price_range
  - in_stock, is_featured
```

## 7.3 تحسين الصور

```yaml
Image Optimization:
  - WebP للمتصفحات الحديثة
  - JPEG كـ fallback
  - ضغط بجودة 80%

أحجام الصور:
  - thumbnail: 150x150
  - small: 300x300
  - medium: 600x600
  - large: 1200x1200

CDN Configuration:
  - تخزين مؤقت للصور (1 سنة)
  - Gzip/Brotli compression
  - Lazy Loading
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 8: التكاملات الخارجية
# ═══════════════════════════════════════════════════════════════════════════════

## 8.1 بوابات الدفع

```yaml
Tap Payments / Moyasar:
  - بطاقات الائتمان
  - Apple Pay
  - mada

Tabby / Tamara:
  - الدفع بالتقسيط
  - اشتر الآن وادفع لاحقاً
```

## 8.2 شركات الشحن

```yaml
Aramex / SMSA / Fetchr:
  - إنشاء شحنات
  - طباعة بوليصة الشحن
  - تتبع الشحنات
  - Webhook للتحديثات
```

## 8.3 خدمات الرسائل

```yaml
SMS: Unifonic / Twilio
WhatsApp: Business API
Email: SendGrid / Mailgun
```

## 8.4 خدمات أخرى

```yaml
Firebase:
  - Push Notifications
  - Analytics
  - Crashlytics

Google Maps:
  - عرض الخرائط
  - Geocoding

Error Tracking: Sentry
File Storage: AWS S3 / Cloudflare R2
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 9: خارطة الطريق
# ═══════════════════════════════════════════════════════════════════════════════

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         خارطة الطريق (29 أسبوع)                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  المرحلة 1: الأساسيات (4 أسابيع)                                            │
│  ✓ إعداد قاعدة البيانات (97 جدول)                                           │
│  ✓ نظام المصادقة الكامل                                                     │
│  ✓ إدارة المستخدمين والصلاحيات                                              │
│  ✓ نظام التخزين المؤقت (Redis)                                              │
│                                                                              │
│  المرحلة 2: الكتالوج والمنتجات (3 أسابيع)                                   │
│  ✓ إدارة العلامات والتصنيفات والأجهزة                                       │
│  ✓ إدارة المنتجات والتسعير                                                  │
│  ✓ البحث المتقدم (Meilisearch)                                              │
│  ✓ نظام التقييمات والمفضلة                                                  │
│                                                                              │
│  المرحلة 3: الطلبات والمدفوعات (3 أسابيع)                                   │
│  ✓ سلة التسوق والدفع                                                        │
│  ✓ إدارة الطلبات                                                            │
│  ✓ الكوبونات والعروض                                                        │
│  ✓ الفواتير                                                                 │
│                                                                              │
│  المرحلة 4: المخزون والموردين (2 أسابيع)                                    │
│  ✓ إدارة المستودعات والمخزون                                                │
│  ✓ إدارة الموردين وأوامر الشراء                                             │
│  ✓ نظام الجرد                                                               │
│                                                                              │
│  المرحلة 5: المرتجعات والمحفظة (2 أسابيع)                                   │
│  ✓ نظام المرتجعات الكامل                                                    │
│  ✓ المحفظة ونقاط الولاء                                                     │
│  ✓ نظام الإحالات                                                            │
│                                                                              │
│  المرحلة 6: تطبيق Flutter (5 أسابيع)                                        │
│  ✓ جميع الشاشات (66 شاشة)                                                   │
│  ✓ الإشعارات والدعم                                                         │
│                                                                              │
│  المرحلة 7: لوحة التحكم React (4 أسابيع)                                    │
│  ✓ جميع الصفحات (66 صفحة)                                                   │
│  ✓ التقارير والإعدادات                                                      │
│                                                                              │
│  المرحلة 8: الميزات الإضافية (2 أسابيع)                                     │
│  ✓ الإشعارات والحملات                                                       │
│  ✓ الدعم والدردشة                                                           │
│  ✓ المحتوى التعليمي                                                         │
│                                                                              │
│  المرحلة 9: التكاملات (2 أسابيع)                                            │
│  ✓ بوابات الدفع وشركات الشحن                                                │
│  ✓ خدمات الرسائل وFirebase                                                  │
│                                                                              │
│  المرحلة 10: الاختبار والنشر (2 أسابيع)                                     │
│  ✓ اختبار الوحدات والتكامل                                                  │
│  ✓ النشر والمراقبة                                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

# ═══════════════════════════════════════════════════════════════════════════════
# القسم 10: الملخص النهائي
# ═══════════════════════════════════════════════════════════════════════════════

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                    TRAS Phone - المواصفات النهائية الشاملة                   ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   📊 الإحصائيات النهائية:                                                    ║
║   ─────────────────────────                                                  ║
║   • جداول قاعدة البيانات: 97 جدول                                           ║
║   • API Endpoints: ~262 endpoint                                             ║
║   • شاشات Flutter: 66 شاشة                                                   ║
║   • صفحات React Admin: 66 صفحة                                               ║
║   • الصلاحيات: 95 صلاحية                                                     ║
║   • الوقت المقدر: 7 أشهر (29 أسبوع)                                          ║
║                                                                               ║
║   🎯 الميزات الرئيسية:                                                       ║
║   ─────────────────────                                                      ║
║   • نظام B2B كامل للتجارة الإلكترونية                                        ║
║   • تسعير متعدد المستويات                                                    ║
║   • إدارة مخزون متقدمة مع نظام الجرد                                         ║
║   • نظام مرتجعات شامل                                                        ║
║   • محفظة إلكترونية ونقاط ولاء                                               ║
║   • نظام إحالات                                                              ║
║   • نظام تقييمات ومفضلة                                                      ║
║   • نظام إشعارات متكامل مع حملات                                             ║
║   • دعم فني بنظام التذاكر والدردشة                                           ║
║   • محتوى تعليمي                                                             ║
║   • تقارير وإحصائيات متقدمة                                                  ║
║   • دعم ثنائي اللغة (عربي/إنجليزي)                                           ║
║   • تكاملات خارجية (دفع، شحن، رسائل)                                         ║
║                                                                               ║
║   💰 تكلفة البنية التحتية الشهرية:                                           ║
║   ─────────────────────────────────                                          ║
║   • الحد الأدنى: $100-150/شهر                                                ║
║   • المتوسط: $200-350/شهر                                                    ║
║   • المتقدم: $400-600/شهر                                                    ║
║                                                                               ║
║   👥 الفريق المقترح:                                                         ║
║   ─────────────────────                                                      ║
║   • 1 Tech Lead / Senior Backend                                             ║
║   • 1-2 Backend Developers                                                   ║
║   • 1-2 Flutter Developers                                                   ║
║   • 1 Frontend Developer (React)                                             ║
║   • 1 QA Engineer                                                            ║
║                                                                               ║
║   ✅ الملف جاهز للتنفيذ                                                       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```
