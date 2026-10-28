FROM python:3.11-slim

WORKDIR /app

# Create a non-root user
RUN useradd --create-home appuser

# Copy application dependencies
COPY requirements.txt .


# Install application dependencies and fixed package versions
RUN python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir --upgrade --force-reinstall \
       "jaraco.context==6.1.0" \
       "wheel==0.46.2"

# Diagnose all installed copies of the affected packages
RUN python - <<'PY'
import importlib.metadata as metadata

for dist in metadata.distributions():
    name = (dist.metadata.get("Name") or "").lower().replace("_", "-")
    if name in {"jaraco.context", "wheel"}:
        print(f"{name}=={dist.version}: {dist._path}")

for name, expected in [
    ("jaraco.context", "6.1.0"),
    ("wheel", "0.46.2"),
]:
    actual = metadata.version(name)
    assert actual == expected, f"{name}: expected {expected}, got {actual}"
    print(f"Verified {name}=={actual}")
PY

# Copy application source code
COPY app/ .

# Set application ownership
RUN chown -R appuser:appuser /app

# Run the application as a non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
