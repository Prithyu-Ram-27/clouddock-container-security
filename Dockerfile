
FROM node:24-bookworm-slim

WORKDIR /app

# Run the application as a non-root user
COPY --chown=node:node app/server.js .

USER node

EXPOSE 5000

CMD ["node", "server.js"]
