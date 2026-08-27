from rest_framework import viewsets

from .models import Document
from .serializers import DocumentSerializer
from .tasks import process_document


class DocumentViewSet(viewsets.ModelViewSet):
    queryset = Document.objects.all()
    serializer_class = DocumentSerializer

    def perform_create(self, serializer):
        document = serializer.save()

        process_document.delay(document.id)
