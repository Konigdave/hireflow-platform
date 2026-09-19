from django.db import connection
from django.http import JsonResponse


def health_check(request):
    return JsonResponse({"status": "healthy"})


def readiness_check(request):
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")

        return JsonResponse({"status": "ready"})

    except Exception:
        return JsonResponse(
            {"status": "not ready"},
            status=503,
        )
