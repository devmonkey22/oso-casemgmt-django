from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from casemgmt.api.filters import DocumentUrlPathFilter
from casemgmt.api.wkcmp.serializers import WkcmpEligibilitySerializer
from casemgmt.models import WkcmpEligibilityData, Document
from drf_oso.filters import AuthorizeFilter


class WkcmpEligibilityViewSet(viewsets.ModelViewSet):
    """Workers Compensation Eligiblity Form (Document) data"""
    list_queryset = WkcmpEligibilityData.objects.all()
    queryset = WkcmpEligibilityData.objects.all().prefetch_related()
    list_serializer_class = WkcmpEligibilitySerializer
    serializer_class = WkcmpEligibilitySerializer

    filter_backends = (DocumentUrlPathFilter, AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['employer']

    def get_queryset(self):
        if self.action == "list":
            return self.list_queryset
        else:
            return self.queryset

    def get_serializer_class(self):
        if self.action == "list":
            return self.list_serializer_class
        else:
            return self.serializer_class

    def perform_create(self, serializer):
        # Pull in document_pk from URL to create (not the only way to make this happen), and check authZ
        doc = get_object_or_404(Document.objects.authorize(request=self.request), pk=self.kwargs["document_pk"])
        serializer.validated_data['document'] = doc
        return super().perform_create(serializer)