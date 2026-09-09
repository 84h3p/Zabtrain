# ---------- Build stage ----------
FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---------- Runtime stage ----------
FROM python:3.12-slim

WORKDIR /app

# Install dependencies from builder
COPY --from=builder /install /usr/local

# Copy application files
COPY app.py .
COPY tasks.json .
COPY templates/ templates/

EXPOSE 5000

CMD ["python", "app.py"]
