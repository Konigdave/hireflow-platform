from rest_framework import serializers

from .models import Document


class DocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Document
        fields = [
            "id",
            "file",
            "original_filename",
            "storage_key",
            "status",
            "uploaded_at",
            "processed_at",
            "candidate_name",
            "email",
            "phone",
        ]
        read_only_fields = [
            "id",
            "original_filename",
            "storage_key",
            "status",
            "uploaded_at",
            "processed_at",
            "candidate_name",
            "email",
            "phone",
        ]

    def create(self, validated_data):
        uploaded_file = validated_data["file"]

        document = Document(
            original_filename=uploaded_file.name,
        )

        document.file.save(
            uploaded_file.name,
            uploaded_file,
            save=False,
        )

        document.storage_key = document.file.name

        document.save()

        return document
