
FROM nginx:stable-alpine

# Update installed Alpine system packages to patched versions
RUN apk update && apk upgrade --no-cache

# Copy the CloudDock webpage
COPY app/index.html /usr/share/nginx/html/index.html

EXPOSE 80
