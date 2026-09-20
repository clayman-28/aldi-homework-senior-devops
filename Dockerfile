FROM python:3.13-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN python -m venv /opt/venv \
&& /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY app.py .

RUN useradd --uid 10001 --no-create-home appuser
USER 10001

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "app:app"]