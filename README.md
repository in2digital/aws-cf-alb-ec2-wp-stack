## 🚀 Quick Start

### 1. Prepare Your AMI
Launch a Debian 12 AMI, or bake a custom one with required packages.

### 2. Create CloudWatch Log Groups
1. Open the [CloudWatch Console](https://console.aws.amazon.com/cloudwatch/home#logs:)
2. Go to **Logs → Log groups**
3. Click **“Create log group”**
4. Enter the name: `/wordpress`
5. Set **Retention** (e.g. 14 days)
6. Click **“Create”**

### 3. Launch EC2 with User Data
Use the script from `user-data/init.sh`:
- Installs NGINX + PHP
- Pulls NGINX & PHP-FPM config from GitHub
- Configures CloudWatch agent and logging
- No WordPress install — install manually

### 4. CloudFront Setup
Use a CloudFront Origin Request Policy that forwards:
- `Host`
- `X-Forwarded-For`
- `X-Forwarded-Proto`

---

## 📊 CloudWatch Logging

The following logs are forwarded from each EC2 instance to the **shared CloudWatch Log Group** `/wordpress`.

Each log uses a unique **log stream name** based on the EC2 instance ID.

| File Path                     | Log Group    | Log Stream Name                         |
|------------------------------|--------------|------------------------------------------|
| `/var/log/nginx/access.log`  | `/wordpress` | `nginx-access-i-{instance-id}`           |
| `/var/log/nginx/error.log`   | `/wordpress` | `nginx-error-i-{instance-id}`            |
| `/var/log/php[version]-fpm.log` | `/wordpress` | `php-fpm-i-{instance-id}`              |
| `/etc/logs/user-data.log`    | `/wordpress` | `user-data-i-{instance-id}`              |

> ℹ️ `{instance-id}` is automatically replaced by the CloudWatch Logs Agent at runtime.

---

## 🔒 Security Notes

- PHP `disable_functions` set in pool config
- `open_basedir` locked to WP paths
- `display_errors` disabled in production

---

## 🛠 Requirements

- Debian 12 (or compatible)
- IAM Instance Profile with CloudWatch Logs access
- ALB + CloudFront

---