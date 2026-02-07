# virtual-bank-chatbot-infrastructure

## ภาพรวม
โครงสร้างนี้เป็น Docker Compose สำหรับระบบ Virtual Bank Chatbot ที่ประกอบด้วย
- Python Chatbot API (FastAPI)
- Java Application
- Ollama สำหรับรัน NLP Model
- MySQL
- Nginx (Reverse Proxy + TLS)
- Certbot (ออกและต่ออายุ TLS อัตโนมัติ)

เหมาะกับการรันแบบ Single VM/Server และสามารถ scale service ได้ด้วย Docker Compose

## โครงสร้างบริการ
- `python-app` เปิดพอร์ต `8000` ภายในเครือข่าย
- `java-app` เปิดพอร์ต `8080` ภายในเครือข่าย
- `ollama` เปิดพอร์ต `11434` ภายในเครือข่าย
- `mysql` เปิดพอร์ต `3306` ภายในเครือข่าย
- `nginx` เปิดพอร์ต `80` และ `443` ออกสู่ภายนอก
- `certbot` ทำงานแบบ loop ต่ออายุ cert ทุก 12 ชั่วโมง

## สิ่งที่ต้องมี
- Docker และ Docker Compose
- โดเมนที่ชี้ DNS มาที่เครื่องนี้ (สำหรับ TLS)

## ไฟล์สำคัญ
- `docker-compose.yml` โครงสร้าง service ทั้งหมด
- `.env` ค่าคอนฟิกหลัก (โดเมน, อีเมล, MySQL)
- `nginx/nginx.conf` ค่าพื้นฐานของ Nginx
- `nginx/templates/default.conf.template` คอนฟิก Virtual Host + upstream
- `certbot/init-letsencrypt.sh` สคริปต์ออก cert ครั้งแรก
- `certbot/renew.sh` สคริปต์ต่ออายุ cert อัตโนมัติ

## วิธีใช้งาน (Quick Start)
1. ตั้งค่าที่ `.env`
```bash
DOMAIN=example.com
CERTBOT_EMAIL=admin@example.com
CERTBOT_STAGING=1
MYSQL_ROOT_PASSWORD=change_me_root
MYSQL_DATABASE=virtual_bank
MYSQL_USER=vb_user
MYSQL_PASSWORD=change_me_user
```

2. ออกใบรับรอง TLS ครั้งแรก
```bash
./certbot/init-letsencrypt.sh
```

3. รันทั้งหมด
```bash
docker compose up -d
```

## Endpoints
- `https://<DOMAIN>/python/health`
- `https://<DOMAIN>/python/chat`
- `https://<DOMAIN>/java/health`

## การ scale
```bash
docker compose up -d --scale python-app=3 --scale java-app=2
```

Nginx ใช้ Docker DNS re-resolution (`resolver 127.0.0.11` + `resolve`) เพื่ออัปเดต upstream อัตโนมัติเมื่อจำนวน container เปลี่ยน

## การต่ออายุ TLS อัตโนมัติ
- `certbot/renew.sh` จะรันทุก 12 ชั่วโมง
- `nginx/reload.sh` จะ reload ทุก 6 ชั่วโมง เพื่อโหลดใบรับรองใหม่

## หมายเหตุการใช้งานจริง
- เมื่อพร้อมใช้งานจริงให้ตั้ง `CERTBOT_STAGING=0` ใน `.env`
- ตรวจสอบว่า DNS ของโดเมนชี้มายัง server เรียบร้อยก่อนออก cert
