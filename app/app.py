from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <html>
        <head>
            <title>CloudDock</title>
        </head>
        <body>
            <h1>CloudDock Secure Application</h1>
            <p>Container Image Hardening and Security Scanner</p>
            <p>Status: Running on AWS EC2</p>
        </body>
    </html>
    """


@app.route("/health")
def health():
    return {
        "status": "healthy",
        "application": "CloudDock"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
