
const http = require("http");

const PORT = 5000;

const server = http.createServer((req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8"
  });

  res.end(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>CloudDock</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 100px;
            background: #f0f4f8;
          }
          h1 { color: #1769aa; }
          .status { color: green; font-weight: bold; }
        </style>
      </head>
      <body>
        <h1>CloudDock Deployment Successful!</h1>
        <p class="status">Application is running on AWS EC2.</p>
        <p>Docker container is running successfully.</p>
        <p>CI/CD and security scanning demonstration.</p>
      </body>
    </html>
  `);
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`CloudDock server listening on port ${PORT}`);
});
