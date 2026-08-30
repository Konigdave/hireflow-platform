#!/bin/sh

set -e

chown -R appuser:appuser /app/media

echo "Applying database migrations..."
su appuser -c "python manage.py migrate"

echo "Starting Django..."
exec su appuser -c "python manage.py runserver 0.0.0.0:8000"
