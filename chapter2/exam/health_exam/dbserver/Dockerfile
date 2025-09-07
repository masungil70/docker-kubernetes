FROM mariadb:latest

# Set environment variables for MariaDB
ENV MARIADB_ROOT_PASSWORD=1004
ENV MARIADB_DATABASE=health_exam
ENV MARIADB_USER=kosa
ENV MARIADB_PASSWORD=1004

# Add a health check
HEALTHCHECK --interval=5s --timeout=3s --start-period=30s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p"$MARIADB_ROOT_PASSWORD"

