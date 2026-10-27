<div dir="rtl">

# Voiz Contact Center

### پنل حرفه‌ای مدیریت، پایش و تحلیل مرکز تماس مبتنی بر Asterisk

[![نسخه](https://img.shields.io/badge/نسخه-Voiz%20Contact%20Center-0f766e?style=for-the-badge)](https://github.com/voipiran/voiz-contact-center)
[![زبان](https://img.shields.io/badge/رابط%20کاربری-فارسی%20و%20RTL-2563eb?style=for-the-badge)](https://github.com/voipiran/voiz-contact-center)
[![Backend](https://img.shields.io/badge/Backend-Python%20%7C%20FastAPI-3776ab?style=for-the-badge&logo=python&logoColor=white)](https://fastapi.tiangolo.com/)
[![Frontend](https://img.shields.io/badge/Frontend-React%20%7C%20TypeScript-149eca?style=for-the-badge&logo=react&logoColor=white)](https://react.dev/)
[![PBX](https://img.shields.io/badge/PBX-Asterisk%20%7C%20Issabel%20%7C%20FreePBX-f59e0b?style=for-the-badge)](https://www.asterisk.org/)
[![License](https://img.shields.io/badge/مجوز-GPL--3.0-22c55e?style=for-the-badge)](LICENSE)

**Voiz Contact Center** یک راهکار بومی و یکپارچه برای مدیریت مرکز تماس است که روی Asterisk اجرا می‌شود و اطلاعات تماس، داخلی‌ها، صف‌ها و عملکرد کارشناسان را در یک پنل وب مدرن در اختیار مدیران و کاربران قرار می‌دهد.

این پروژه بر پایه پروژه والد **[OpDesk](https://github.com/Ibrahimgamal99/OpDesk)** توسعه داده شده و برای محیط‌های فارسی‌زبان، چیدمان راست‌به‌چپ (RTL)، نیازهای عملیاتی مجموعه‌های ایرانی و کار با **Issabel / FreePBX** بهینه‌سازی شده است. کد و اسکریپت‌های این مخزن بسته‌بندی اختصاصی Voiz هستند؛ برای نصب، از دستورهای همین صفحه استفاده کنید.

</div>

---

## فهرست مطالب

- [معرفی کوتاه](#معرفی-کوتاه)
- [قابلیت‌ها](#قابلیت‌ها)
- [پیش‌نیازها](#پیشنیازها)
- [نصب سریع](#نصب-سریع)
- [راه‌اندازی اتصال مرکز تماس](#راهاندازی-اتصال-مرکز-تماس)
- [معماری و فناوری‌ها](#معماری-و-فناوریها)
- [ساختار پروژه](#ساختار-پروژه)
- [مستندات و پشتیبانی](#مستندات-و-پشتیبانی)
- [پروژه والد و مجوز](#پروژه-والد-و-مجوز)

## معرفی کوتاه

Voiz Contact Center برای تیم‌هایی طراحی شده است که می‌خواهند بدون جایگزین‌کردن Asterisk، یک لایه مدیریتی و عملیاتی کامل روی سیستم تلفنی خود داشته باشند. سامانه رویدادهای Asterisk را از طریق AMI دریافت می‌کند، وضعیت زنده را از طریق WebSocket به مرورگر می‌رساند و داده‌های تماس و گزارش‌ها را از طریق API در اختیار رابط کاربری قرار می‌دهد.

این راهکار برای استفاده در مرکز تماس، واحد فروش، پشتیبانی، نظرسنجی و تیم‌های خدمات مشتری مناسب است و می‌تواند در کنار تنظیمات فعلی Issabel یا FreePBX نصب شود.

## قابلیت‌ها

### مدیریت و پایش لحظه‌ای

- داشبورد زنده برای وضعیت داخلی‌ها، تماس‌های فعال، صف‌ها و کارشناسان
- نمایش تماس‌های در حال زنگ‌خوردن، پاسخ‌داده‌شده و در انتظار
- مشاهده طولانی‌ترین زمان انتظار و شاخص‌های کلیدی روزانه
- به‌روزرسانی رویدادها با WebSocket و بدون وابستگی به polling مداوم
- پشتیبانی از نقش‌های مدیریتی و سطح دسترسی کاربران

### کنترل تماس و نظارت کارشناسان

- برقراری و دریافت تماس از داخل مرورگر با WebRTC و SIP.js
- نگه‌داشتن تماس، بی‌صداکردن، انتقال و کنترل وضعیت آماده / غیرآماده
- ورود و خروج کارشناس از صف
- شنود تماس، Whisper و Barge با سطح دسترسی کنترل‌شده
- پشتیبانی از Softphone موبایل و تولید QR برای ورود سریع
- ضبط مکالمات و تحلیل سکوت / گفت‌وگو با VAD

### گزارش‌گیری و تحلیل

- تاریخچه کامل تماس‌ها و جست‌وجوی چندمعیاره
- نمایش مسیر تماس (Call Journey) برای تماس‌های چندمرحله‌ای
- گزارش عملکرد صف‌ها و کارشناسان
- شاخص‌های KPI، تغییرات دوره‌ای و نمودارهای تحلیلی
- خروجی CSV و XLSX
- تحلیل کیفیت تماس و دسترسی به فایل ضبط‌شده

### ارتباط با CRM و API

- دفترچه تلفن متمرکز و نمایش نام مخاطب در پنل
- ارسال اطلاعات تماس به CRM از طریق Webhook
- ثبت لاگ ارسال‌ها و امکان ارسال مجدد
- REST API با کلیدهای دسترسی و Scope
- Click-to-Call و دریافت اطلاعات مخاطب از CRM
- لاگ رویدادهای AMI، Trace مربوط به SIP و رخدادهای CRM

### رابط کاربری فارسی

- بهینه‌شده برای زبان فارسی و چیدمان RTL
- طراحی واکنش‌گرا برای دسکتاپ، تبلت و موبایل
- پشتیبانی از حالت روشن و تاریک
- تمرکز بر خوانایی، دسترسی سریع و استفاده عملیاتی در محیط مرکز تماس

## پیش‌نیازها

| مورد | توضیح |
|---|---|
| سیستم تلفنی | Issabel یا FreePBX مبتنی بر Asterisk |
| دسترسی Asterisk | فعال‌بودن AMI روی پورت `5038` و HTTP/WebSocket روی پورت `8088` |
| سیستم‌عامل | Debian 12+، Ubuntu یا توزیع‌های خانواده RHEL |
| دسترسی نصب | دسترسی `root` یا کاربری دارای `sudo` |
| پایگاه داده | MySQL یا MariaDB و دسترسی به دیتابیس‌های Asterisk و CDR |
| ابزارهای پایه | `curl` و `openssl`؛ اسکریپت نصب فقط ابزارهای ضروریِ مفقود را نصب می‌کند |
| نصب عمومی | برای HTTPS عمومی، دامنه‌ای که به سرور اشاره کند و دسترسی پورت ۸۰ برای Let's Encrypt |

> **نکته پورت‌ها:** در Issabel و FreePBX معمولاً Apache پورت‌های ۸۰ و ۴۴۳ را در اختیار دارد. اسکریپت نصب در صورت نیاز پورت جایگزین HTTPS (پیش‌فرض `8443`) را پیشنهاد می‌کند. پیش از نصب، وضعیت سرویس‌های فعال و فایروال را بررسی کنید.

## نصب سریع

### روش پیشنهادی: دریافت نسخه اصلی با tarball

دستور زیر را روی سرور PBX اجرا کنید:

```bash
cd /opt && \
rm -rf voiz-contact-center voiz-contact-center.tar.gz && \
curl -fL https://github.com/voipiran/voiz-contact-center/archive/refs/heads/main.tar.gz \
  -o voiz-contact-center.tar.gz && \
tar -xzf voiz-contact-center.tar.gz && \
mv voiz-contact-center-main voiz-contact-center && \
cd voiz-contact-center && \
sudo bash install.sh
```

### روش جایگزین: دریافت با Git

```bash
sudo rm -rf /opt/voiz-contact-center
sudo git clone --depth 1 https://github.com/voipiran/voiz-contact-center.git \
  /opt/voiz-contact-center
cd /opt/voiz-contact-center
sudo bash install.sh
```

اسکریپت `install.sh` محیط لازم را آماده می‌کند، نسخه bundled برنامه را در مسیر عملیاتی `/opt/OpDesk` قرار می‌دهد، Node.js و Python مورد نیاز را بررسی / نصب می‌کند و سرویس‌های لازم را برای اجرا آماده می‌سازد. نصب‌کننده به‌صورت عمدی کد را از پروژه والد Clone نمی‌کند؛ نسخه هماهنگ‌شده Voiz از همین مخزن استفاده می‌شود.

در ابتدای نصب، اگر `curl` و `openssl` از قبل روی سیستم موجود باشند، هیچ بسته‌ای برای ابزارهای پایه نصب نمی‌شود. نصب Python، Nginx و وابستگی‌های runtime در مراحل بعدی و فقط در صورت نیاز انجام می‌شود؛ در آن مراحل مدیر بسته سیستم‌عامل ممکن است متادیتای Repositoryهای فعال را بررسی کند.

### اجرای مستقیم نسخه موجود در مخزن

اگر پروژه از قبل روی سرور قرار دارد:

```bash
cd /opt/voiz-contact-center
sudo bash install.sh
```

> اجرای نصب با `sudo` توصیه می‌شود، چون اسکریپت با مسیرهای سیستمی، تنظیمات Asterisk و سرویس‌های سیستم‌عامل کار می‌کند.

## راه‌اندازی اتصال مرکز تماس

اسکریپت `contactcenter.sh` تنظیمات تکمیلی اتصال Voiz به Asterisk را انجام می‌دهد. این مرحله را بعد از نصب اصلی اجرا کنید:

```bash
cd /opt/voiz-contact-center
sudo bash contactcenter.sh
```

این اسکریپت در صورت امکان اطلاعات اتصال دیتابیس Issabel / FreePBX را تشخیص می‌دهد و تنظیمات مورد نیاز ChanSpy و Feature Codeهای نظارت تماس را در Asterisk اعمال می‌کند. اگر اطلاعات دیتابیس به‌صورت خودکار پیدا نشود، اسکریپت آن‌ها را به‌صورت تعاملی درخواست می‌کند.

پس از پایان نصب:

1. آدرس نمایش‌داده‌شده توسط نصب‌کننده را در مرورگر باز کنید؛ معمولاً `https://<server>` یا `https://<server>:8443` است.
2. با کاربر مدیری که نصب‌کننده اعلام می‌کند وارد شوید و رمز پیش‌فرض را تغییر دهید.
3. در بخش کاربران، هر کاربر را به داخلی و صف‌های مربوط به خود متصل کنید.
4. تنظیمات AMI، دیتابیس، دامنه و HTTPS را بررسی کنید.
5. برای اطمینان، یک تماس آزمایشی برقرار و تاریخچه، ضبط و وضعیت صف را بررسی کنید.

## تنظیمات مهم

فایل نمونه تنظیمات در [.env.example](.env.example) قرار دارد. مهم‌ترین موارد عبارت‌اند از:

| متغیر | کاربرد |
|---|---|
| `DB_HOST`، `DB_USER`، `DB_PASSWORD` | اتصال به MySQL / MariaDB |
| `DB_NAME`، `DB_CDR` | دیتابیس تنظیمات و تاریخچه تماس |
| `AMI_HOST`، `AMI_PORT`، `AMI_USERNAME`، `AMI_SECRET` | اتصال مدیریتی به Asterisk |
| `PORT` | پورت داخلی Backend |
| `OPDESK_HTTPS_PORT`، `NGINX_HTTPS_PORT` | پورت سرویس HTTPS |
| `JWT_SECRET` | کلید امضای نشست‌ها؛ باید طولانی و تصادفی باشد |
| `ASTERISK_RECORDING_ROOT_DIR` | مسیر فایل‌های ضبط مکالمه |
| `FCM_*` و `APNS_*` | تنظیمات اختیاری اعلان بیدارباش Softphone موبایل |

اطلاعات حساس، کلیدهای سرویس و فایل‌های APNs / FCM را در Git Commit نکنید.

## معماری و فناوری‌ها

```text
مرورگر (React + WebRTC)
        │ HTTPS / WSS
        ▼
Nginx ───────► FastAPI / Uvicorn ───────► Asterisk
                  │   │                     │
                  │   ├── MySQL / MariaDB  ├── AMI
                  │   ├── CRM Webhook      └── SIP / RTP
                  │   └── تحلیل تماس
                  └── REST API + WebSocket
```

| لایه | فناوری‌ها |
|---|---|
| Backend | Python 3.11+، FastAPI، Uvicorn، asyncio، WebSocket |
| Frontend | React 18، TypeScript، Vite، React Router |
| تلفن تحت وب | SIP.js، WebRTC و Asterisk HTTP/WebSocket |
| پایگاه داده | MySQL / MariaDB، دیتابیس Asterisk و CDR |
| احراز هویت | JWT و bcrypt |
| گزارش‌گیری | Recharts، openpyxl و خروجی CSV/XLSX |
| تحلیل صوت | WebRTC VAD و ONNX Runtime |
| استقرار | Nginx، systemd، HTTPS و Let's Encrypt |

### اجرای توسعه‌ای

برای کار روی Frontend و Backend به‌صورت محلی:

```bash
cd /opt/voiz-contact-center
bash start.sh --dev
```

برای اجرای Production، Frontend باید از قبل Build شده باشد:

```bash
cd /opt/voiz-contact-center/frontend
npm ci
npm run build

cd ..
bash start.sh --production
```

در نصب production، `start.sh` عمداً Frontend را روی سرور Build نمی‌کند و از `frontend/dist` آماده استفاده می‌کند.

## ساختار پروژه

```text
voiz-contact-center/
├── backend/             # API، اتصال AMI، منطق تماس و تحلیل
├── frontend/            # رابط کاربری React و TypeScript
├── nginx/               # نمونه تنظیمات Reverse Proxy
├── screenshots/         # تصاویر معرفی رابط کاربری
├── docs/                # راهنماهای فنی و API
├── contactcenter.sh     # تنظیمات تکمیلی Asterisk و ChanSpy
├── install.sh           # نصب و آماده‌سازی محیط
└── start.sh             # اجرای توسعه‌ای و production
```

## مستندات و پشتیبانی

- [راهنمای نصب و عیب‌یابی](docs/guides/installation.md)
- [راهنمای تنظیمات](docs/guides/configuration.md)
- [راهنمای تحلیل و KPI](docs/guides/analytics.md)
- [راهنمای Softphone و Push موبایل](docs/guides/mobile-push.md)
- [مرجع API](docs/api/overview.md) و [فهرست Endpointها](docs/api/endpoints.md)
- [Webhookهای CRM](docs/api/webhooks.md) و [جست‌وجوی مخاطب](docs/api/contact-lookup.md)

برای گزارش خطا، نسخه Issabel / FreePBX، نسخه Asterisk، روش نصب و لاگ مرتبط سرویس را همراه با گزارش خود در [Issues گیت‌هاب](https://github.com/voipiran/voiz-contact-center/issues) ارسال کنید. رمزها، کلیدهای API و اطلاعات شخصی تماس‌ها را در Issue قرار ندهید.

## پروژه والد و مجوز

این پروژه از نظر ایده و بخش‌هایی از معماری بر پایه **[OpDesk](https://github.com/Ibrahimgamal99/OpDesk)** شکل گرفته است. Voiz Contact Center یک نسخه سفارشی‌سازی‌شده برای محیط فارسی و زیرساخت‌های رایج VoIP در ایران است و تغییرات بسته‌بندی، نصب، رابط کاربری و یکپارچه‌سازی خود را در همین مخزن نگه می‌دارد.

کد این پروژه تحت مجوز **[GNU GPL v3](LICENSE)** منتشر شده است. هنگام استفاده، تغییر یا توزیع مجدد، شرایط مجوز و اعلان‌های حق‌نشر وابستگی‌ها را رعایت کنید.
