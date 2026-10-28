FROM python:3.11-slim

WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser

# Copy application dependencies
COPY requirements.txt .

# Install application dependencies
RUN python -m pip install --no-cache-dir -r requirements.txt

# Upgrade vulnerable Python packages
RUN python -m pip install --no-cache-dir --upgrade --force-reinstall \
    "jaraco.context==6.1.0" \
    "wheel==0.46.2"

# Verify the installed versions
RUN python -c "import importlib.metadata as m; \
assert m.version('jaraco.context') == '6.1.0', m.version('jaraco.context'); \
assert m.version('wheel') == '0.46.2', m.version('wheel'); \
print('jaraco.context:', m.version('jaraco.context')); \
print('wheel:', m.version('wheel'))"

# Copy application source code
COPY app/ .

# Set application ownership
RUN chown -R appuser:appuser /app

# Run the application as a non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
