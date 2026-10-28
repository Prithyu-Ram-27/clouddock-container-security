FROM python:3.11-slim

WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser

# Copy application dependencies
COPY requirements.txt .

# Install application dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Upgrade packages with known vulnerabilities
RUN pip install --no-cache-dir \
    "jaraco.context==6.1.0" \
    "wheel==0.46.2"

# Copy application source code
COPY app/ .

# Set application ownership
RUN chown -R appuser:appuser /app

# Run the application as a non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
