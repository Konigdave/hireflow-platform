import json
import time

from django.http import StreamingHttpResponse

from .models import Document


def document_status_stream(document_id):
    last_status = None

    while True:
        document = Document.objects.get(id=document_id)
        current_status = document.status

        if current_status != last_status:
            yield f"data: {json.dumps({'status': current_status})}\n\n"
            last_status = current_status

        if current_status in {"COMPLETED", "FAILED"}:
            break

        time.sleep(1)


def document_status_events(request, document_id):
    response = StreamingHttpResponse(
        document_status_stream(document_id),
        content_type="text/event-stream",
    )

    response["Cache-Control"] = "no-cache"
    response["X-Accel-Buffering"] = "no"

    return response
