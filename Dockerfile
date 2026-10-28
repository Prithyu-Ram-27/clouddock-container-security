
FROM node:24-alpine

WORKDIR /app

COPY app/server.js .

USER node

EXPOSE 5000

CMD ["node", "server.js"]
