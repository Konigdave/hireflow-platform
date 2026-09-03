from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .sse import document_status_events
from .views import DocumentViewSet


router = DefaultRouter()
router.register(r"documents", DocumentViewSet, basename="documents")


urlpatterns = [
    path("", include(router.urls)),
    path(
        "documents/<int:document_id>/events/",
        document_status_events,
        name="document-status-events",
    ),
]
