from django.test import TestCase

from .models import Document, DocumentStatus


class DocumentModelTest(TestCase):
    def test_document_defaults_to_pending(self):
        document = Document.objects.create(
            original_filename="test.pdf",
            storage_key="documents/test.pdf",
        )

        self.assertEqual(document.status, DocumentStatus.PENDING)
