# VOIPIRAN ContactCenter

<div dir="rtl">

پنل هوشمند مرکز تماس **voipiran.io** برای مدیریت و مانیتورینگ تماس‌های
مرکز تماس مبتنی بر **Asterisk** و **Issabel** است. این پروژه یک راهکار
یکپارچه برای مشاهده تماس‌ها، صف‌ها، کارشناسان، ضبط مکالمات، گزارش‌ها و
WebRTC ارائه می‌دهد.

</div>

[![Python](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18%2B-61DAFB?logo=react&logoColor=111827)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100%2B-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Node.js](https://img.shields.io/badge/Node.js-24%2B-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Issabel](https://img.shields.io/badge/Issabel-compatible-1f2937)](https://www.issabel.org/)
[![Asterisk](https://img.shields.io/badge/Asterisk-compatible-2c3e50?logo=asterisk&logoColor=white)](https://www.asterisk.org/)
[![WebRTC](https://img.shields.io/badge/WebRTC-supported-333333?logo=webrtc&logoColor=white)](https://webrtc.org/)
[![RTL](https://img.shields.io/badge/UI-RTL%20%7C%20فارسی-16a34a)](#)

> توسعه و سفارشی‌سازی: **[voipiran.io](https://voipiran.io)**

## ارزش پروژه

راه‌اندازی و مدیریت مرکز تماس معمولاً به چند ابزار جداگانه برای Asterisk،
گزارش‌گیری، ضبط مکالمه، WebRTC و مانیتورینگ نیاز دارد. VOIPIRAN ContactCenter
این بخش‌ها را در یک پنل واحد جمع می‌کند تا مدیر و کارشناس مرکز تماس بدون
کار با چند سامانه متفاوت، وضعیت تماس‌ها و عملکرد مجموعه را مشاهده و مدیریت
کنند.

مزیت‌های اصلی:

- کاهش زمان راه‌اندازی مرکز تماس روی Issabel
- اتصال مستقیم به Asterisk و دیتابیس Issabel
- مشاهده زنده وضعیت داخلی‌ها، صف‌ها و تماس‌ها
- دسترسی یکپارچه به ضبط مکالمات و گزارش‌های تماس
- پشتیبانی از تماس WebRTC در پنل
- آماده برای رابط فارسی و راست‌به‌چپ
- امکان توسعه و سفارشی‌سازی برای سازمان‌ها و مشتریان مختلف
- نصب تکرارپذیر با اسکریپت و وابستگی‌های نسخه‌بندی‌شده

## امکانات

- داشبورد مانیتورینگ اپراتورها و تماس‌های فعال
- مشاهده داخلی‌ها، صف‌ها و وضعیت کارشناسان
- نمایش تماس‌های ورودی و خروجی
- جست‌وجو و گزارش‌گیری از CDR
- دسترسی به فایل‌های ضبط‌شده مکالمات
- WebRTC Softphone و اتصال SIP از طریق مرورگر
- تنظیم WebSocket مربوط به Asterisk
- پشتیبانی از Issabel و FreePBX
- رابط کاربری فارسی و RTL
- frontend آماده برای نصب Production
- backend مبتنی بر FastAPI
- نصب و اجرای سرویس با systemd
- تنظیم Nginx، گواهی و reverse proxy
- تنظیم دیتابیس Issabel و تنظیمات WebRTC
- اعمال patchهای اختصاصی VOIPIRAN پس از نصب

## نصب مستقیم روی Issabel

این Repository برای نصب مستقل روی Issabel آماده شده است و برای اجرای
نصب‌کننده به پروژه دیگری وابسته نیست.

روی سرور Issabel با کاربر root اجرا کنید:


یا:

```bash
curl -fsSL https://raw.githubusercontent.com/voipiran/voiz-contact-center/main/install-from-github.sh | sudo bash
```

نصب‌کننده مراحل زیر را انجام می‌دهد:

1. بررسی root بودن کاربر و شناسایی Issabel
2. دریافت همین Repository از GitHub
3. اجرای [install.sh](./install.sh)
4. نصب OpDesk در `/opt/OpDesk`
5. نصب Python و وابستگی‌های backend
6. نصب و تنظیم Nginx
7. تنظیم دسترسی دیتابیس Issabel
8. Deploy کردن frontend آماده
9. اجرای [voipiran-patch/apply.sh](./voipiran-patch/apply.sh)
10. تنظیم WebRTC، Asterisk و سرویس `opdesk`

### تنظیم Repository، branch و مسیر دریافت

نصب‌کننده به‌صورت پیش‌فرض از Repository رسمی و branch `main` استفاده می‌کند.
در صورت نیاز:

```bash
VOIPIRAN_REPO_URL="https://github.com/voipiran/voiz-contact-center.git" \
VOIPIRAN_REPO_BRANCH="main" \
VOIPIRAN_PACKAGE_DIR="/opt/voipiran-contactcenter-installer" \
sudo -E /tmp/voipiran-contactcenter-install.sh
```

اگر مسیر package از قبل یک checkout معتبر Git باشد، همان نسخه استفاده می‌شود.
مسیر غیرخالی و غیر Git به‌صورت خودکار حذف یا بازنویسی نمی‌شود.

## پیش‌نیازها

- Issabel 4/5 یا سیستم سازگار مبتنی بر RHEL/CentOS
- دسترسی root
- دسترسی شبکه برای دریافت Repository و وابستگی‌ها
- Asterisk و MariaDB/MySQL
- حداقل Python 3.11 برای backend
- دسترسی آزاد پورت‌های مورد استفاده Nginx و WebRTC
- فضای کافی برای frontend، backend و وابستگی‌های Python

## پورت‌ها و سرویس‌ها

نصب‌کننده از تنظیمات پروژه برای اجرای OpDesk استفاده می‌کند. پس از نصب،
وضعیت سرویس را با دستورات زیر بررسی کنید:

```bash
systemctl status opdesk --no-pager
systemctl status nginx --no-pager
nginx -t
```

برای مشاهده لاگ‌ها:

```bash
journalctl -u opdesk -n 100 --no-pager
journalctl -u nginx -n 100 --no-pager
```

## توسعه و Build

### Backend

```bash
cd backend
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Frontend

```bash
cd frontend
npm install
npm run build
```

خروجی Production در `frontend/dist` قرار می‌گیرد. نصب‌کننده روی سرور
Production عملیات build را انجام نمی‌دهد و از frontend آماده داخل Repository
استفاده می‌کند.

## ساختار پروژه

```text
backend/                 API و سرویس‌های Python/FastAPI
frontend/                رابط React و خروجی dist
nginx/                   کانفیگ Nginx
scripts/                 اسکریپت‌های کمکی
voipiran-patch/          سفارشی‌سازی‌های اختصاصی VOIPIRAN
install.sh               نصب‌کننده اصلی OpDesk
install-from-github.sh   نصب‌کننده مستقیم از GitHub
```

## به‌روزرسانی

برای به‌روزرسانی، ابتدا نسخه جدید را در یک محیط آزمایشی بررسی کنید. سپس
checkout نصب‌کننده را به‌صورت کنترل‌شده به‌روزرسانی کنید و مراحل اعتبارسنجی
را اجرا کنید. نصب‌کننده مستقیم، checkout موجود را خودکار pull نمی‌کند تا
تغییرات محلی یا تنظیمات مشتری از بین نرود.

## مشارکت و حمایت

گزارش خطا، پیشنهاد قابلیت و Pull Request با ذکر نسخه Issabel، نسخه Python،
لاگ سرویس و مراحل بازتولید خطا بسیار ارزشمند است.

اگر پروژه برای شما مفید است، لطفاً به Repository یک ⭐ بدهید و آن را با
تیم‌های فنی، شرکت‌ها و مراکز تماس دیگر به اشتراک بگذارید.

## مالکیت

این پروژه و سفارشی‌سازی‌های VOIPIRAN متعلق به **voipiran.io** است. استفاده
تجاری، بازنشر یا توزیع نسخه سفارشی باید مطابق مجوز و توافق مالک پروژه انجام
شود.
