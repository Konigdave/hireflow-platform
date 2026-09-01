from django.utils import timezone
from celery import shared_task

from .models import Document, DocumentStatus
from .services.pdf_extractor import extract_text
from .services.candidate_parser import (
    extract_candidate_name,
    extract_email,
    extract_phone,
)


@shared_task
def process_document(document_id):
    document = Document.objects.get(id=document_id)

    try:
        document.status = DocumentStatus.PROCESSING
        document.save(update_fields=["status"])

        # Get the uploaded file path.
        file_path = document.file.path

        # Extract text from the PDF.
        text = extract_text(file_path)

        # Extract candidate information.
        candidate_name = extract_candidate_name(text)
        email = extract_email(text)
        phone = extract_phone(text)

        # Save extracted candidate information.
        document.candidate_name = candidate_name
        document.email = email
        document.phone = phone
        document.status = DocumentStatus.COMPLETED
        document.processed_at = timezone.now()

        document.save(
            update_fields=[
                "candidate_name",
                "email",
                "phone",
                "status",
                "processed_at",
            ]
        )

        return f"Document {document_id} processed successfully"

    except Exception:
        document.status = DocumentStatus.FAILED
        document.save(update_fields=["status"])

        raise
