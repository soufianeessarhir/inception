# Developer Documentation

## Environment Setup from Scratch

### Prerequisites

**System Requirements**:
- Virtual Machine (VM) or physical machine running Linux
- Minimum 4GB RAM, 20GB free disk space
- Root or sudo access

**Required Software**:
1. Docker Engine (latest stable version)
2. Docker Compose V2
3. Make
4. Git

### Installing Docker and Docker Compose

**For Alpine Linux**:
```bash
# Update package index
sudo apk update

# Install Docker and Docker Compose
sudo apk add docker docker-compose docker-cli-compose

# Start Docker service
sudo rc-update add docker boot
sudo service docker start

# Add your user to docker group
sudo addgroup $USER docker

# Log out and back in for group changes to take effect
```

**For Fedora**:
```bash
# Update package index
sudo dnf update -y

# Install Docker
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker Engine and Docker Compose
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

**For Debian/Ubuntu**:
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

**Verify Installation** (all distributions):
```bash
docker --version
docker compose version
```

### Cloning and Configuring the Project

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Configure your environment:

**a. Update domain name in `/etc/hosts`**:
```bash
sudo nano /etc/hosts
```
Add this line:
```
127.0.0.1 sessarhi.42.fr adminer.sessarhi.42.fr static.sessarhi.42.fr
```

**b. Update paths in Makefile**:
```bash
nano Makefile
```
Change `DATA_PATH` to match your username:
```makefile
DATA_PATH = /home/YOUR_USERNAME/data
```

**c. Update paths in docker-compose.yml**:
```bash
nano srcs/docker-compose.yml
```
Replace all instances of `/home/sessarhi/data` with `/home/YOUR_USERNAME/data`

**d. Update environment variables**:
```bash
nano srcs/.env
```
Update `DOMAIN_NAME` if needed (currently `sessarhi.42.fr`)

### Setting Up Secrets

The project uses Docker secrets for sensitive data. Secrets are already configured in the `secrets/` directory with default passwords.

**For production, you should change these**:

```bash
# Generate secure passwords
openssl rand -base64 32 > secrets/db_root_password.txt
openssl rand -base64 32 > secrets/db_password.txt
openssl rand -base64 32 > secrets/wp_admin_password.txt
openssl rand -base64 32 > secrets/wp_user_password.txt
openssl rand -base64 32 > secrets/ftp_pass.txt

# Set proper permissions
chmod 600 secrets/*.txt
```

**Important**: Never commit actual secret files to Git. The `.gitignore` should exclude them.

### Directory Structure Explanation

```
inception/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── USER_DOC.md                 # End-user documentation
├── DEV_DOC.md                  # This file
├── secrets/                    # Sensitive credentials
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── ftp_pass.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/                       # Source files
    ├── .env                    # Environment variables
    ├── docker-compose.yml      # Service orchestration
    └── requirements/           # Service configurations
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── server.conf
        │   └── tools/
        │       └── setup.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── setup.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── setup.sh
        └── bonus/              # Bonus services
            ├── adminer/
            ├── ftp/
            ├── portainer/
            ├── redis/
            └── static-site/
```

## Building and Launching

### Using the Makefile

The Makefile provides convenient commands for managing the infrastructure:

**Build and start everything**:
```bash
make
# or
make all
```

This command:
1. Creates data directories (`/home/YOUR_USERNAME/data/`)
2. Sets proper ownership and permissions
3. Builds all Docker images
4. Starts all containers

**Other Makefile targets**:

```bash
make setup      # Create directories only
make build      # Build images and start containers
make up         # Start existing containers (no rebuild)
make start      # Start stopped containers
make down       # Stop all containers
make restart    # Restart all containers
make logs       # Follow logs for all services
make status     # Show container status
make clean      # Remove stopped containers and unused images
make fclean     # Complete cleanup (WARNING: destroys data)
make re         # Rebuild everything from scratch
```

### Using Docker Compose Directly

You can also use Docker Compose commands directly:

```bash
# Navigate to srcs directory
cd srcs

# Build images
docker compose build

# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# View running containers
docker compose ps
```

### Build Process Details

When you run `make build`, the following happens:

1. **Directory Creation**: Creates persistent data directories
   ```bash
   mkdir -p /home/YOUR_USERNAME/data/mariadb
   mkdir -p /home/YOUR_USERNAME/data/wordpress
   mkdir -p /home/YOUR_USERNAME/data/portainer
   ```

2. **Ownership Assignment**: Sets proper ownership
   ```bash
   chown -R 1337:1337 /home/YOUR_USERNAME/data/wordpress  # www user
   chown -R 999:999 /home/YOUR_USERNAME/data/mariadb      # mysql user
   ```

3. **Image Building**: Builds each service's Docker image
   - Reads each Dockerfile
   - Downloads Alpine Linux base image
   - Installs required packages
   - Copies configuration files
   - Sets up entrypoints

4. **Container Creation**: Creates containers from images

5. **Network Setup**: Creates the `inception` bridge network

6. **Volume Mounting**: Mounts host directories into containers

7. **Service Startup**: Starts containers in dependency order

## Managing Containers and Volumes

### Container Management

**List running containers**:
```bash
docker ps
```

**List all containers (including stopped)**:
```bash
docker ps -a
```

**View container details**:
```bash
docker inspect <container_name>
```

**Access container shell**:
```bash
docker exec -it <container_name> sh
```

**View container logs**:
```bash
docker logs <container_name>
docker logs -f <container_name>  # Follow logs
docker logs --tail 100 <container_name>  # Last 100 lines
```

**Restart a specific container**:
```bash
docker restart <container_name>
```

**Stop a specific container**:
```bash
docker stop <container_name>
```

**Remove a stopped container**:
```bash
docker rm <container_name>
```

### Volume Management

**List volumes**:
```bash
docker volume ls
```

**Inspect a volume**:
```bash
docker volume inspect <volume_name>
```

**This project uses bind mounts, not Docker volumes**. Data locations:

- **MariaDB data**: `/home/YOUR_USERNAME/data/mariadb`
- **WordPress files**: `/home/YOUR_USERNAME/data/wordpress`
- **Portainer data**: `/home/YOUR_USERNAME/data/portainer`

**Check data directory sizes**:
```bash
du -sh /home/YOUR_USERNAME/data/*
```

**Backup data directories**:
```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/YOUR_USERNAME/data/
```

### Network Management

**List networks**:
```bash
docker network ls
```

**Inspect the inception network**:
```bash
docker network inspect inception
```

**Check container connectivity**:
```bash
# From inside a container
docker exec -it wordpress sh
ping mariadb
ping redis
ping nginx
```

## Project Data Storage and Persistence

### Data Persistence Strategy

The project uses **bind mounts** to persist data on the host filesystem:

```yaml
volumes:
  mariadb-data:
    driver: local
    driver_opts:
        type: none
        o: bind
        device: /home/${USER}/data/mariadb
```

### Data Locations

**Host System** → **Container**:

1. **MariaDB Database**:
   - Host: `/home/YOUR_USERNAME/data/mariadb`
   - Container: `/var/lib/mysql`
   - Contains: Database files, transaction logs

2. **WordPress Files**:
   - Host: `/home/YOUR_USERNAME/data/wordpress`
   - Container: `/var/www/html`
   - Contains: WordPress core, themes, plugins, uploads

3. **Portainer Data**:
   - Host: `/home/YOUR_USERNAME/data/portainer`
   - Container: `/data`
   - Contains: Portainer configuration and database

### How Data Persists

1. **Container Restart**: Data remains intact (bind mounts are not affected)

2. **Container Removal**: Data remains on host filesystem

3. **Complete Rebuild**: Data persists unless you run `make fclean`

4. **System Reboot**: Data persists (just restart containers with `make up`)

### Data Recovery

If containers are corrupted or removed:

```bash
# Stop containers
make down

# Remove containers and images
docker container prune -f
docker image prune -af

# Your data still exists
ls -la /home/YOUR_USERNAME/data/

# Rebuild and restart
make build
```

Your WordPress site and database will be restored automatically from the persistent data.

## Service-Specific Details

### NGINX Service

**Purpose**: Reverse proxy and TLS termination

**Key Configuration**:
- Listens on port 443 (HTTPS only)
- TLSv1.3 protocol
- Self-signed SSL certificates
- Proxies requests to backend services

**Configuration File**: `srcs/requirements/nginx/conf/nginx.conf`

**Virtual Hosts**:
1. `sessarhi.42.fr` → WordPress (FastCGI to port 9000)
2. `adminer.sessarhi.42.fr` → Adminer (proxy to port 8080)
3. `static.sessarhi.42.fr` → Static site (proxy to port 80)

**SSL Certificate Generation**:
Handled automatically by `setup.sh`:
```bash
openssl req -nodes -x509 -days 365 -newkey rsa:2048 \
  -out /etc/nginx/nginx.cert \
  -keyout /etc/nginx/nginx.key \
  -subj "/C=MA/ST=khouribga/L=khouribga/O=1337/CN=${DOMAIN_NAME}"
```

**Testing NGINX**:
```bash
docker exec -it nginx sh
nginx -t  # Test configuration
cat /etc/nginx/nginx.conf
ls -la /etc/nginx/nginx.cert
```

### WordPress Service

**Purpose**: Content Management System

**Key Components**:
- PHP 8.3 with PHP-FPM
- WP-CLI for automation
- Redis cache integration

**Configuration File**: `srcs/requirements/wordpress/conf/www.conf`

**Setup Process** (`setup.sh`):
1. Download WordPress if not present
2. Install WP-CLI
3. Create `wp-config.php` with database credentials
4. Install WordPress core
5. Create admin and author users
6. Install and activate Redis cache plugin
7. Set file permissions

**Useful Commands**:
```bash
# Access WordPress container
docker exec -it wordpress sh

# Run WP-CLI commands
wp --info --allow-root
wp plugin list --allow-root
wp user list --allow-root
wp cache flush --allow-root

# Check PHP-FPM status
ps aux | grep php-fpm
netstat -tulpn | grep 9000
```

### MariaDB Service

**Purpose**: MySQL-compatible database

**Key Configuration**:
- Listens on port 3306
- UTF8MB4 character set
- Configured for Docker environment
- Health checks via mysqladmin

**Configuration File**: `srcs/requirements/mariadb/conf/server.conf`

**Setup Process** (`setup.sh`):
1. Initialize database if not present
2. Secure installation (remove test database, anonymous users)
3. Create WordPress database
4. Create database user with privileges
5. Set root password

**Database Backup**:
```bash
# From host
docker exec mariadb mysqldump -u sessarhi -p$(cat secrets/db_password.txt) wordpress > backup.sql

# Restore
docker exec -i mariadb mysql -u sessarhi -p$(cat secrets/db_password.txt) wordpress < backup.sql
```

**Access Database**:
```bash
docker exec -it mariadb sh
mysql -u sessarhi -p$(cat /run/secrets/db_password) wordpress
```

### Redis Service

**Purpose**: In-memory cache for WordPress

**Key Features**:
- Speeds up WordPress by caching database queries
- Reduces database load
- Session storage

**Configuration File**: `srcs/requirements/bonus/redis/conf/redis.conf`

**Testing Redis**:
```bash
docker exec -it redis sh
redis-cli ping  # Should return PONG
redis-cli info
redis-cli monitor  # Watch commands in real-time
```

**Verify WordPress → Redis Connection**:
```bash
docker exec -it wordpress sh
wp redis status --allow-root
```

### Adminer Service

**Purpose**: Web-based database management

**Key Features**:
- Single PHP file application
- Access via `adminer.sessarhi.42.fr`
- Connects to MariaDB

**Testing**:
```bash
docker exec -it adminer sh
ls -la /var/www/html/
php -v
```

### FTP Service

**Purpose**: File transfer access to WordPress

**Key Configuration**:
- vsftpd server
- Passive mode (ports 21000-21010)
- Chroot jail for security
- Access to WordPress volume

**Configuration File**: `srcs/requirements/bonus/ftp/conf/vsftpd.conf`

**Testing FTP**:
```bash
# From another machine or terminal
lftp localhost 21
# Login with ftpuser and password from secrets/ftp_pass.txt
```

### Portainer Service

**Purpose**: Docker container management UI

**Key Features**:
- Web interface at `https://localhost:9443`
- Requires Docker socket access
- Persistent data storage

**First Setup**:
Visit https://localhost:9443 and create admin password on first run.

### Static Site Service

**Purpose**: Example static website

**Key Components**:
- NGINX serving static HTML/CSS
- Example cafe menu page
- Demonstrates multi-site hosting

**Configuration File**: `srcs/requirements/bonus/static-site/conf/nginx.conf`

## Debugging and Troubleshooting

### Container Won't Start

1. **Check logs**:
```bash
docker logs <container_name>
```

2. **Check configuration**:
```bash
docker inspect <container_name>
```

3. **Verify dependencies**:
```bash
docker compose ps
```

4. **Test manually**:
```bash
docker compose up <service_name>  # Run without -d to see output
```

### Health Check Failures

Health checks are defined in `docker-compose.yml`:

**MariaDB**:
```yaml
test: ["CMD-SHELL", "mysqladmin ping -u ${DB_USER} -p$$(cat /run/secrets/db_password) --socket=/var/run/mysqld/mysqld.sock --silent || exit 1"]
```

**WordPress**:
```yaml
test: ["CMD-SHELL", "nc -z localhost 9000 || exit 1"]
```

**Redis**:
```yaml
test: ["CMD","redis-cli","ping"]
```

**Debug health checks**:
```bash
# Run health check command manually
docker exec <container_name> <health_check_command>
```

### Network Issues

**Test connectivity between containers**:
```bash
docker exec wordpress ping mariadb
docker exec wordpress ping redis
docker exec nginx ping wordpress
```

**Inspect network**:
```bash
docker network inspect inception
```

**Check DNS resolution**:
```bash
docker exec wordpress nslookup mariadb
docker exec wordpress cat /etc/resolv.conf
```

### Permission Issues

**WordPress files**:
```bash
# Should be owned by www (UID 1337)
ls -la /home/YOUR_USERNAME/data/wordpress/

# Fix permissions
sudo chown -R 1337:1337 /home/YOUR_USERNAME/data/wordpress
sudo find /home/YOUR_USERNAME/data/wordpress -type d -exec chmod 755 {} \;
sudo find /home/YOUR_USERNAME/data/wordpress -type f -exec chmod 644 {} \;
```

**MariaDB files**:
```bash
# Should be owned by mysql (UID 999)
ls -la /home/YOUR_USERNAME/data/mariadb/

# Fix permissions
sudo chown -R 999:999 /home/YOUR_USERNAME/data/mariadb
```

### Performance Issues

**Check resource usage**:
```bash
docker stats
```

**Check disk space**:
```bash
df -h
docker system df
```

**Clean up unused resources**:
```bash
docker system prune -a --volumes
```

### Configuration Debugging

**NGINX**:
```bash
docker exec nginx nginx -t  # Test configuration
docker exec nginx cat /etc/nginx/nginx.conf
```

**PHP-FPM**:
```bash
docker exec wordpress php-fpm83 -t  # Test configuration
docker exec wordpress cat /etc/php83/php-fpm.d/www.conf
```

**MariaDB**:
```bash
docker exec mariadb cat /etc/my.cnf.d/mariadb-server.cnf
```

## Advanced Operations

### Modifying Services

When you need to change a service configuration:

1. Edit the relevant file (Dockerfile, config file, or setup script)
2. Rebuild the specific service:
```bash
docker compose build <service_name>
docker compose up -d <service_name>
```

3. Or rebuild everything:
```bash
make re
```

### Adding New Services

To add a new bonus service:

1. Create directory structure:
```bash
mkdir -p srcs/requirements/bonus/myservice/{conf,tools}
```

2. Create Dockerfile:
```bash
nano srcs/requirements/bonus/myservice/Dockerfile
```

3. Add to docker-compose.yml:
```yaml
myservice:
  build:
    context: ./requirements/bonus/myservice
    dockerfile: Dockerfile
  image: myservice:inception
  container_name: myservice
  networks:
    - inception
  restart: unless-stopped
```

4. Build and test:
```bash
docker compose build myservice
docker compose up -d myservice
```

### Secrets Management Best Practices

1. **Never commit secrets to Git**:
```bash
# .gitignore should include:
secrets/*.txt
```

2. **Use strong passwords**:
```bash
openssl rand -base64 32 > secrets/new_password.txt
```

3. **Rotate secrets regularly**:
```bash
# Update secret file
# Rebuild affected containers
make down
docker compose build <affected_services>
make up
```

4. **Restrict file permissions**:
```bash
chmod 600 secrets/*.txt
chmod 700 secrets/
```

## Common Development Tasks

### Testing SSL Certificates

```bash
# Check certificate details
openssl x509 -in /home/YOUR_USERNAME/data/nginx/nginx.cert -text -noout

# Test SSL connection
openssl s_client -connect sessarhi.42.fr:443 -servername sessarhi.42.fr
```

### Monitoring Logs in Real-Time

```bash
# All services
docker compose -f srcs/docker-compose.yml logs -f

# Specific service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Multiple services
docker compose -f srcs/docker-compose.yml logs -f wordpress mariadb nginx
```

### Database Operations

**Export database**:
```bash
docker exec mariadb mysqldump -u sessarhi -p$(cat secrets/db_password.txt) wordpress > wordpress_backup.sql
```

**Import database**:
```bash
docker exec -i mariadb mysql -u sessarhi -p$(cat secrets/db_password.txt) wordpress < wordpress_backup.sql
```

**Access MySQL console**:
```bash
docker exec -it mariadb mysql -u sessarhi -p$(cat /run/secrets/db_password) wordpress
```

### Performance Optimization

**Enable Redis caching**:
Already configured in WordPress setup. Verify:
```bash
docker exec wordpress wp redis status --allow-root
```

**Optimize database**:
```bash
docker exec -it mariadb mysql -u sessarhi -p$(cat /run/secrets/db_password) wordpress -e "OPTIMIZE TABLE wp_posts, wp_postmeta;"
```

**Monitor PHP-FPM**:
```bash
docker exec wordpress ps aux | grep php-fpm
```

## Security Considerations

### Current Security Measures

1. **TLS Encryption**: All web traffic encrypted with TLSv1.3
2. **Secrets Management**: Passwords stored in Docker secrets (read-only files)
3. **Network Isolation**: Services communicate through isolated bridge network
4. **Non-root Users**: Services run as dedicated users (not root)
5. **Health Checks**: Automatic monitoring and recovery
6. **No Latest Tags**: All images use explicit versions
7. **Minimal Base Images**: Alpine Linux reduces attack surface

### Security Recommendations

1. **Use real SSL certificates** in production (Let's Encrypt)
2. **Change default passwords** immediately
3. **Regular updates**: Keep base images and packages updated
4. **Firewall rules**: Restrict access to necessary ports only
5. **Backup regularly**: Automate backups of data directories
6. **Monitor logs**: Watch for suspicious activity
7. **Limit exposed ports**: Only NGINX should be publicly accessible

## Project Compliance

This project adheres to the 42 Inception subject requirements:

- ✅ Each service runs in dedicated container
- ✅ Custom Dockerfiles (no pulled images except base OS)
- ✅ Alpine 3.21 base images
- ✅ docker-compose.yml called by Makefile
- ✅ NGINX with TLSv1.3 only
- ✅ WordPress + php-fpm (no nginx)
- ✅ MariaDB (no nginx)
- ✅ Volumes for database and WordPress files
- ✅ Docker network for container communication
- ✅ Containers restart on crash
- ✅ No `network: host` or `--link`
- ✅ No infinite loops (`tail -f`, `sleep infinity`)
- ✅ Two WordPress users (admin + author)
- ✅ Admin username doesn't contain "admin"
- ✅ Volumes in `/home/login/data`
- ✅ Domain name points to local IP
- ✅ No `latest` tag
- ✅ No passwords in Dockerfiles
- ✅ Environment variables used
- ✅ .env file for configuration
- ✅ Docker secrets for credentials
- ✅ NGINX as only entrypoint on port 443
- ✅ Bonus: Redis cache
- ✅ Bonus: FTP server
- ✅ Bonus: Static website (not PHP)
- ✅ Bonus: Adminer
- ✅ Bonus: Additional service (Portainer)