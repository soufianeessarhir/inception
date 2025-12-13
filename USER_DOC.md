# User Documentation

## Overview

This infrastructure provides a complete web hosting solution with the following services:

- **WordPress Website**: A content management system for creating and managing your website
- **Database Management**: Adminer tool for managing the MariaDB database
- **Static Website**: A simple HTML/CSS website for additional content
- **FTP Server**: File transfer access to your WordPress files
- **Container Management**: Portainer for monitoring and managing Docker containers

All services are secured with TLS/SSL encryption and run in isolated Docker containers.

## Getting Started

### Prerequisites

Before you begin, ensure you have:
- Access to the server where the project is installed
- Terminal/SSH access
- The project repository cloned on your system

### Starting the Project

1. Open a terminal and navigate to the project directory:
```bash
cd /path/to/inception
```

2. Start all services:
```bash
make
```

This command will:
- Create necessary directories
- Build Docker images
- Start all containers
- Set up networking and volumes

The first build may take 1.5-5 minutes. Subsequent starts will be faster.

3. Verify services are running:
```bash
make status
```

You should see all containers with status "Up" or "healthy".

### Stopping the Project

To stop all services:
```bash
make down
```

This preserves your data and configuration. To start again, use:
```bash
make up
```

## Accessing Services

### WordPress Website

**URL**: https://sessarhi.42.fr

**Features**:
- Create and publish posts and pages
- Upload media (images, documents)
- Customize appearance with themes
- Extend functionality with plugins

**User Accounts**:

Administrator Account:
- Username: `sessarhi`
- Password: Located in `secrets/wp_admin_password.txt`
- Access: Full control over the website

Author Account:
- Username: `soufiane`
- Password: Located in `secrets/wp_user_password.txt`
- Access: Can create and edit their own posts

**Login**:
1. Visit https://sessarhi.42.fr/wp-admin
2. Enter your username and password
3. Click "Log In"

### Database Management (Adminer)

**URL**: https://adminer.sessarhi.42.fr

**Purpose**: Manage your WordPress database directly

**Login Credentials**:
- System: MySQL
- Server: `mariadb`
- Username: `sessarhi`
- Password: Located in `secrets/db_password.txt`
- Database: `wordpress`

**What you can do**:
- View database tables and structure
- Run SQL queries
- Export database backups
- Import data
- Modify table structures

**Caution**: Be careful when modifying the database directly. Always backup before making changes.

### Static Website

**URL**: https://static.sessarhi.42.fr

A simple static website demonstrating a cafe menu. This is an example of how additional websites can be hosted alongside WordPress.

### FTP Server

**Connection Details**:
- Host: `localhost` or your server IP
- Port: `21`
- Protocol: FTP
- Username: `ftpuser`
- Password: Located in `secrets/ftp_pass.txt`

**Purpose**: Upload files directly to your WordPress installation

**Recommended FTP Clients**:
- lftp (CLI FTP client)

**Connection Steps**:
1. Open your FTP client
2. Create a new connection with the details above
3. Connect to the server
4. Navigate to `/var/www/html` (WordPress directory)
5. Upload/download files as needed

### Container Management (Portainer)

**URL**: https://localhost:9443

**Purpose**: Monitor and manage Docker containers through a web interface

**First-Time Setup**:
1. Visit https://localhost:9443
2. Create an admin password (recommended: strong password)
3. Select "Local" environment
4. Click "Connect"

**Features**:
- View container status and logs
- Start/stop/restart containers
- Monitor resource usage (CPU, memory)
- Access container shells
- Manage volumes and networks

## Managing Credentials

### Location

All passwords are stored in the `secrets/` directory:

```
secrets/
├── db_password.txt          # Database user password
├── db_root_password.txt     # Database root password
├── ftp_pass.txt             # FTP server password
├── wp_admin_password.txt    # WordPress admin password
└── wp_user_password.txt     # WordPress author password
```

### Viewing Credentials

To view a password:
```bash
cat secrets/wp_admin_password.txt
```

### Changing Passwords

**IMPORTANT**: Changing passwords requires rebuilding containers

1. Stop all services:
```bash
make down
```

2. Edit the password file:
```bash
nano secrets/wp_admin_password.txt
```

3. For WordPress passwords, you must also update them in WordPress:
   - Log in to WordPress as admin
   - Go to Users → All Users
   - Click on the user
   - Scroll to "New Password"
   - Enter and save new password

4. Rebuild and restart:
```bash
make fclean
make
```

**Note**: `make fclean` removes all data. For password changes only, consider modifying them directly in the services instead.

## Checking Service Health

### Method 1: Using Make

```bash
make status
```

Shows the status of all containers. Look for:
- **Up**: Container is running
- **healthy**: Container passed health checks
- **Exit**: Container has stopped (problem)

### Method 2: Checking Logs

View logs for all services:
```bash
make logs
```

View logs for a specific service:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Method 3: Testing Services

**Test WordPress**:
1. Visit https://sessarhi.42.fr
2. Page should load without errors
3. Try logging in to /wp-admin

**Test Database**:
1. Visit https://adminer.sessarhi.42.fr
2. Login with database credentials
3. Verify you can see the wordpress database

**Test FTP**:
1. Connect using FTP client
2. Verify you can list files
3. Try uploading a test file

### Method 4: Container Shell Access

To troubleshoot a specific container:

```bash
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it nginx sh
```

## Common Tasks

### Backing Up Your Website

**Backup WordPress Files**:
```bash
sudo tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /home/sessarhi/data/wordpress
```

**Backup Database**:
1. Visit https://adminer.sessarhi.42.fr
2. Login to the database
3. Click "Export" in the left menu
4. Select "SQL" format
5. Click "Export" button
6. Save the file

Or via command line:
```bash
docker exec mariadb mysqldump -u sessarhi -p wordpress > backup-$(date +%Y%m%d).sql
```

### Restoring from Backup

**Restore WordPress Files**:
```bash
make down
sudo rm -rf /home/sessarhi/data/wordpress/*
sudo tar -xzf wordpress-backup-YYYYMMDD.tar.gz -C /
make up
```

**Restore Database**:
1. Visit https://adminer.sessarhi.42.fr
2. Login to the database
3. Click "Import" in the left menu
4. Select your SQL backup file
5. Click "Execute"

### Updating WordPress

WordPress updates are handled through the WordPress admin panel:
1. Login to https://sessarhi.42.fr/wp-admin
2. Navigate to Dashboard → Updates
3. Click "Update Now"
4. Follow on-screen instructions

### Viewing Resource Usage

Check disk space:
```bash
df -h /home/sessarhi/data
```

Check Docker disk usage:
```bash
docker system df
```

Monitor container resources:
- Visit Portainer at https://localhost:9443
- Go to "Containers" section
- View CPU and memory usage graphs

## Troubleshooting

### Website Not Loading

1. Check if containers are running:
```bash
make status
```

2. Check nginx logs:
```bash
docker logs nginx
```

3. Restart services:
```bash
make restart
```

### Database Connection Errors

1. Check if MariaDB is healthy:
```bash
docker ps | grep mariadb
```

2. View MariaDB logs:
```bash
docker logs mariadb
```

3. Verify database credentials in Adminer

### FTP Connection Failed

1. Check if FTP container is running:
```bash
docker ps | grep ftp
```

2. Verify ports are open:
```bash
sudo netstat -tulpn | grep 21
```

3. Check FTP logs:
```bash
docker logs ftp
```

### SSL Certificate Warnings

The project uses self-signed SSL certificates. Your browser will show a security warning:
1. Click "Advanced" or "Details"
2. Click "Proceed to site" or "Accept the Risk"
3. This is normal for self-signed certificates

### Out of Disk Space

1. Check disk usage:
```bash
df -h
```

2. Clean up Docker resources:
```bash
make clean
```

3. Remove old backups if necessary

## Getting Help

If you encounter issues:

1. **Check the logs**: Most problems are visible in container logs
2. **Verify configuration**: Ensure all paths in docker-compose.yml match your system
3. **Review documentation**: Check DEV_DOC.md for technical details
4. **Restart services**: Many issues resolve with a restart

For persistent issues, check the Docker and service-specific documentation linked in README.md.