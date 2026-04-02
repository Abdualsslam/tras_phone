# دليل النشر على VPS ودومين جديد (Production)

هذا الدليل عملي خطوة بخطوة لنشر مشروع `tras_phone` على سيرفر جديد، مع تثبيت **Nginx Proxy Manager** (واجهة إدارة الشهادات SSL والـ Proxy).

## 1) المتطلبات قبل البدء

- VPS بنظام Ubuntu 22.04 (أو 24.04).
- دومين جديد (مثال: `example.com`).
- صلاحية `root` أو مستخدم sudo.
- فتح البورتات من مزود السيرفر:
  - `22` (SSH)
  - `80` (HTTP)
  - `443` (HTTPS)
  - `81` (لوصول لوحة Nginx Proxy Manager)

## 2) ضبط DNS للدومين

من لوحة DNS أضف A records نحو IP السيرفر:

- `api.example.com` -> `SERVER_IP`
- `admin.example.com` -> `SERVER_IP`
- (اختياري) `npm.example.com` -> `SERVER_IP`

مهم:
- انتظر انتشار DNS (غالبا من دقائق إلى ساعات).
- لو تستخدم Cloudflare، اجعل السجلات `DNS only` أثناء إصدار الشهادة أول مرة.

## 3) تجهيز السيرفر

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg git ufw
```

إعداد جدار الحماية:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 81
sudo ufw --force enable
sudo ufw status
```

## 4) تثبيت Docker + Docker Compose Plugin

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
docker --version
docker compose version
```

## 5) تثبيت Nginx Proxy Manager (NPM)

أنشئ مجلد خاص:

```bash
mkdir -p /opt/npm
cd /opt/npm
```

أنشئ ملف `docker-compose.yml` بهذا المحتوى:

```yaml
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - web-network

networks:
  web-network:
    external: true
```

أنشئ الشبكة الخارجية المطلوبة مرة واحدة:

```bash
docker network create web-network || true
```

شغّل NPM:

```bash
docker compose up -d
```

الدخول للوحة NPM:
- `http://SERVER_IP:81`
- الحساب الافتراضي أول مرة:
  - Email: `admin@example.com`
  - Password: `changeme`

بعد أول دخول غيّر البريد وكلمة المرور فورا.

## 6) رفع المشروع على السيرفر

```bash
mkdir -p /opt/apps
cd /opt/apps
git clone <REPO_URL> tras_phone
cd tras_phone
```

## 7) إعداد ملفات البيئة Production

### Backend

```bash
cd /opt/apps/tras_phone/backend
cp .env.example .env
```

عدّل `backend/.env` (القيم المهمة):

- `NODE_ENV=production`
- `PORT=3000`
- `MONGODB_URI=...` (قاعدة الإنتاج)
- `REDIS_HOST=tras-redis`
- `REDIS_PORT=6379`
- `JWT_SECRET=...` و `JWT_REFRESH_SECRET=...` (قيم قوية)
- `CORS_ORIGINS=https://admin.example.com`

### Admin

عدّل ملف `admin/.env.production`:

```env
VITE_API_URL=https://api.example.com/api/v1
```

مهم: لأن Vite يبني القيم وقت الـ build، أي تعديل على `VITE_API_URL` يحتاج إعادة build للحاوية.

## 8) تشغيل المشروع (Backend + Admin + Redis)

ارجع لجذر المشروع:

```bash
cd /opt/apps/tras_phone
docker compose up -d --build
docker compose ps
```

## 9) ربط الدومينات من Nginx Proxy Manager + SSL

من لوحة NPM أنشئ Proxy Hosts:

### A) API Host

- Domain Names: `api.example.com`
- Scheme: `http`
- Forward Hostname/IP: `tras-backend`
- Forward Port: `3000`
- فعّل:
  - `Block Common Exploits`
  - `Websockets Support` (اختياري لكنه مفيد)

ثم من تبويب SSL:
- اختر `Request a new SSL Certificate`
- فعّل `Force SSL`
- فعّل `HTTP/2 Support`
- أدخل بريدك ووافق على Let’s Encrypt ToS

### B) Admin Host

- Domain Names: `admin.example.com`
- Scheme: `http`
- Forward Hostname/IP: `tras-admin`
- Forward Port: `80`
- فعّل `Block Common Exploits`

ثم SSL بنفس الخطوات السابقة.

## 10) التحقق النهائي بعد النشر

- افتح:
  - `https://admin.example.com`
  - `https://api.example.com/api/v1` (أو endpoint صحة مثل `/api` حسب المشروع)
- تحقق أن تسجيل الدخول في الأدمن يعمل.
- تحقق من Console/Network أن الطلبات تذهب إلى `api.example.com`.

## 11) أوامر التشغيل اليومية

### تحديث الكود ونشر نسخة جديدة

```bash
cd /opt/apps/tras_phone
git pull
docker compose up -d --build
```

### عرض السجلات

```bash
cd /opt/apps/tras_phone
docker compose logs -f tras-backend
docker compose logs -f tras-admin
```

### إعادة تشغيل خدمة

```bash
cd /opt/apps/tras_phone
docker compose restart tras-backend
docker compose restart tras-admin
```

## 12) توصيات أمان مهمة (Production)

- لا تترك منفذ `81` مفتوحا للعالم لفترة طويلة:
  - إما تقصره على IP معين عبر Firewall.
  - أو تنقل لوحة NPM لدومين داخلي محمي.
- لا تحفظ أسرار الإنتاج داخل Git.
- استخدم كلمات مرور قوية و2FA حيث ممكن.
- خذ نسخ احتياطية دورية:
  - `backend/.env`
  - مجلدات NPM: `/opt/npm/data` و `/opt/npm/letsencrypt`
  - قاعدة البيانات MongoDB

## 13) استكشاف الأخطاء السريعة

- الشهادة لا تصدر:
  - تأكد DNS يشير لنفس السيرفر.
  - تأكد البورت 80 مفتوح.
  - أوقف Proxy CDN مؤقتا (Cloudflare) أثناء الإصدار الأول.
- الأدمن لا يتصل بالـ API:
  - راجع `admin/.env.production`.
  - أعد بناء الحاوية: `docker compose up -d --build`.
- خطأ CORS:
  - تأكد `CORS_ORIGINS=https://admin.example.com` في `backend/.env`.
  - أعد تشغيل الباك إند.

---

إذا أردت، أستطيع تجهيز لك نسخة ثانية من هذا الدليل باسم دومينك الحقيقي (جاهزة Copy/Paste بدون أي placeholders).
