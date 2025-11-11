FROM postgres:16-alpine

# Copy SQL initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Copy custom entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]
