
FROM nginxinc/nginx-unprivileged:stable-alpine

# Update installed Alpine packages to available patched versions
USER root
RUN apk upgrade --no-cache

# Copy the website
COPY app/index.html /usr/share/nginx/html/index.html

# Run Nginx as a non-root user
USER 101

EXPOSE 8080
