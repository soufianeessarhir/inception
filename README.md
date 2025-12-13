# Inception

*This project has been created as part of the 42 curriculum by sessarhi.*

## Description

Inception is a system administration project that focuses on Docker containerization and orchestration. The project involves setting up a complete web infrastructure using Docker Compose, with multiple services running in isolated containers. The infrastructure includes a WordPress website with MariaDB database, NGINX reverse proxy with TLS encryption, Redis caching, and several bonus services including FTP server, Adminer database manager, Portainer container management, and a static website.

The main goal is to understand Docker concepts, container networking, volume management, secrets handling, and service orchestration while following security best practices.

## Instructions

### Prerequisites

- A Virtual Machine running a Linux distribution (Fedora/Alpine recommended)
- Docker and Docker Compose installed
- Root or sudo privileges
- At least 4GB of RAM and 20GB of disk space

### Installation

1. Clone the repository:
```bash
git clone 
cd inception
```

2. Configure your domain name in `/etc/hosts`:
```bash
sudo echo "127.0.0.1 sessarhi.42.fr adminer.sessarhi.42.fr static.sessarhi.42.fr" >> /etc/hosts
```

3. Ensure the data directory path matches your system:
   - Edit the `Makefile` and update `DATA_PATH` to match your home directory
   - Edit `srcs/docker-compose.yml` and update all volume source paths

### Compilation and Execution

Build and start all services (If the any command asks for permission (well known behavior on Fedora/Alpine Distro's) prefix it with sudo):
```bash
make

Other available commands:
```bash
make up        # Start existing containers
make down      # Stop all containers
make restart   # Restart all containers
make clean     # Stop containers and remove unused Docker resources
make fclean    # Complete cleanup (removes all data)
make re        # Rebuild everything from scratch
make logs      # View container logs
make status    # Check container status
```

### Accessing Services

- **WordPress**: https://sessarhi.42.fr
- **Adminer** (Database Manager): https://adminer.sessarhi.42.fr
- **Static Site**: https://static.sessarhi.42.fr
- **Portainer** (Container Manager): https://localhost:9443
- **FTP Server**: ftp://localhost:21

### Default Credentials

All passwords are stored in `./secrets/` directory:
- WordPress Admin: `sessarhi` / see `secrets/wp_admin_password.txt`
- WordPress User: `soufiane` / see `secrets/wp_user_password.txt`
- Database User: `sessarhi` / see `secrets/db_password.txt`
- Database Root: see `secrets/db_root_password.txt`
- FTP User: `ftpuser` / see `secrets/ftp_pass.txt`

## Resources

### Docker Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

### Service-Specific Resources
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI Documentation](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Redis Documentation](https://redis.io/documentation)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### Security Resources
- [TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [Docker Security](https://docs.docker.com/engine/security/)

### Others
- [Alex Ellis' Blog](https://blog.alexellis.io/)
- [A great lab for lerning and practicing Docker, podman, kubernetes and more]( https://labs.iximiuz.com/)
- [The OpenContainers specs](https://specs.opencontainers.org/)
- [A great Blog website where you can learn about containers, cgroups, namespaces ...](https://blog.quarkslab.com/)

### AI Usage

AI tools were used in this project for the following tasks:

1. **Configuration File Generation**: AI assisted in generating initial configuration templates for NGINX, PHP-FPM, MariaDB, and Redis, which were then reviewed and customized for the specific requirements.

2. **Shell Script Validation**: AI helped review and validate the setup scripts (`setup.sh` files) for potential issues, security concerns, and best practices compliance.

3. **Documentation Research**: AI was used to quickly find relevant documentation and best practices for Docker, service configuration, and security implementations.

4. **Debugging Assistance**: When encountering issues with container networking, health checks, and service dependencies, AI provided suggestions for troubleshooting approaches.

5. **Security Review**: AI helped identify potential security vulnerabilities in configurations, such as exposed ports, weak permissions, and insecure default settings.

All AI-generated content was thoroughly reviewed, tested, and modified to ensure it met the project requirements and worked correctly in the actual environment. Peer review was conducted to validate the final implementation.

## Project Description

### Docker vs Virtual Machines

**Virtual Machines (VMs)**:
- Full operating system with its own kernel
- Hardware virtualization through hypervisor
- Larger resource footprint (GBs of disk space, more RAM)
- Slower startup time (minutes)
- Complete isolation at hardware level
- Can run different operating systems

**Docker Containers**:
- Share host OS kernel
- OS-level virtualization
- Lightweight (MBs of disk space)
- Fast startup time (seconds)
- Process-level isolation
- Must run same OS type as host (Linux containers on Linux)

**Why Docker for this project**: Docker is ideal for microservices architecture where each service (NGINX, WordPress, MariaDB) runs independently, can be scaled easily, and maintains consistent behavior across different environments. The lightweight nature makes it perfect for development and deployment.

### Secrets vs Environment Variables

**Environment Variables**:
- Stored in `.env` file or defined in docker-compose.yml
- Visible in container environment and process listings
- Can be logged or exposed accidentally
- Suitable for non-sensitive configuration (domain names, ports, usernames)

**Docker Secrets**:
- Stored encrypted in Docker's internal storage
- Mounted as read-only files in `/run/secrets/`
- Never appear in environment variables or logs
- Only accessible to authorized containers
- Suitable for passwords, API keys, certificates

**Project Implementation**: This project uses environment variables for configuration values (domain name, database name, usernames) and Docker secrets for all sensitive data (passwords, credentials) to follow security best practices.

### Docker Network vs Host Network

**Bridge Network (Docker Network)**:
- Isolated network namespace
- Containers get internal IP addresses
- Communication via container names (DNS resolution)
- Port mapping required for external access
- Better security through network isolation
- Default for Docker Compose

**Host Network**:
- Container shares host's network stack
- No network isolation
- Container uses host's IP directly
- All ports automatically exposed
- Performance benefit (no NAT overhead)
- Security concern (less isolation)

**Project Choice**: This project uses Docker's bridge network (`inception`) because it provides proper isolation, allows service discovery by name (e.g., `wordpress:9000`), and maintains security by only exposing necessary ports through NGINX.

### Docker Volumes vs Bind Mounts

**Docker Volumes**:
- Managed by Docker in `/var/lib/docker/volumes/`
- Created and managed via Docker commands
- Platform-independent paths
- Better performance on Docker Desktop
- Automatic backup/migration support
- Preferred for production

**Bind Mounts**:
- Mount specific host directory into container
- Full path specification required
- Direct file system access
- Easier development workflow
- Host-dependent paths
- Used when you need specific host locations

**Project Implementation**: This project uses bind mounts pointing to `/home/sessarhi/data/` because:
1. The subject explicitly requires volumes in `/home/login/data`
2. Makes data easily accessible for backup and inspection
3. Allows direct host file system access for debugging
4. Data persists even if Docker is reinstalled

### Main Design Choices

1. **Alpine Linux Base**: All containers use Alpine 3.21 for minimal footprint and security
2. **Non-root Users**: Services run as dedicated users (nginx, mysql, www) for security
3. **Health Checks**: Containers include health checks for reliable dependency management
4. **TLS Only**: NGINX enforces TLSv1.3 for all connections
5. **No Tag Latest**: All images use explicit version tags
6. **Secrets Management**: All credentials stored in separate files, never in code
7. **Network Isolation**: All services communicate through internal Docker network named inception
8. **Single Entry Point**: NGINX is the only container exposing HTTPS (443) FTP and Portainer are excluded

### Service Architecture

```
Internet → NGINX (443) → [Docker Network: inception] → WordPress (9000)
                                                      → Adminer (8080)
                                                      → Static Site (80)
                         
                         WordPress → MariaDB (3306)
                                  → Redis (6379)

External → FTP (21) → WordPress Volume
        → Portainer (9443) → Docker Socket
```

Each service is containerized independently with:
- Custom Dockerfile (no pulling pre-made images except base OS)
- Dedicated configuration files
- Setup scripts for initialization
- Proper restart policies
- Resource optimization