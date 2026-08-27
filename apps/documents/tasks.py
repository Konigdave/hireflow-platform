from django.utils import timezone
from celery import shared_task

from .models import Document, DocumentStatus


@shared_task
def process_document(document_id):
    document = Document.objects.get(id=document_id)

    try:
        document.status = DocumentStatus.PROCESSING
        document.save(update_fields=["status"])

        # Simulate CV processing for now.

        document.status = DocumentStatus.COMPLETED
        document.processed_at = timezone.now()
        document.save(update_fields=["status", "processed_at"])

        return f"Document {document_id} processed successfully"

    except Exception:
        document.status = DocumentStatus.FAILED
        document.save(update_fields=["status"])

        raise
