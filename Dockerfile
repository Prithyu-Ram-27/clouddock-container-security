
FROM python:3.11-slim

WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser

# Install application dependencies
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir --upgrade --force-reinstall \
       "jaraco.context==6.1.0" \
       "wheel==0.46.2" \
    && python -m pip check \
    && python -c "import importlib.metadata as m; \
assert m.version('jaraco.context') == '6.1.0'; \
assert m.version('wheel') == '0.46.2'; \
print('Python package versions verified')"

# Copy application source
COPY app/ .

# Set ownership and use non-root user
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
