
FROM nginxinc/nginx-unprivileged:stable-alpine

COPY app/index.html /usr/share/nginx/html/index.html

EXPOSE 8080

USER 101
