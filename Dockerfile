# Используем легковесный официальный образ Python 3.12
FROM python:3.12-slim

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Устанавливаем зависимости системы (если нужны, например, для компиляции некоторых библиотек)
# RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

# Копируем только файл зависимостей для кеширования слоев Docker
COPY requirements.txt .

# Устанавливаем Python-зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь остальной код приложения (включая папки static/ и templates/)
COPY . .

# Создаем непривилегированного пользователя для безопасности
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

# Указываем порт, который будет слушать контейнер
EXPOSE 8000

# Команда запуска приложения через Gunicorn
# wsgi:app означает "файл wsgi.py, объект app внутри него"
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:8000", "wsgi:app"]