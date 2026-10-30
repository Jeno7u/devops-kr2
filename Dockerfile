FROM python:3.12-slim

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --home-dir /app app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app app.py .

USER app

EXPOSE 8004

CMD ["gunicorn", "--bind", "0.0.0.0:8004", "app:app"]
