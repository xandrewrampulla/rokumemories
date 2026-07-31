FROM python:3.13-slim

WORKDIR /app

COPY src/python/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/python/app.py .
COPY src/python/static static

EXPOSE 8080

CMD ["python", "-u", "app.py"]

