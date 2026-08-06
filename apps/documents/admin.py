from django.contrib import admin

from .models import Document


@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "original_filename",
        "candidate_name",
        "status",
        "uploaded_at",
    )

    list_filter = ("status",)
    search_fields = (
        "original_filename",
        "candidate_name",
        "email",
    )
