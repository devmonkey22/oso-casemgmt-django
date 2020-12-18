from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from casemgmt.api.serializers import (
    ClientSerializer, DocumentSerializer, DocumentTemplateSerializer, CaseloadSerializer, CaseloadDetailsSerializer,
)
from casemgmt.models import (
    Client, DocumentTemplate, Document, Caseload,
)

from drf_oso.filters import AuthorizeFilter


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['last_name', 'first_name']


class DocumentTemplateViewSet(viewsets.ModelViewSet):
    queryset = DocumentTemplate.objects.all()
    serializer_class = DocumentTemplateSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']


class DocumentViewSet(viewsets.ModelViewSet):
    queryset = Document.objects.all()
    serializer_class = DocumentSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']


class CaseloadViewSet(viewsets.ModelViewSet):
    # For list, just return high-level information
    # For details serializer, pull related tables (might be a bad idea performance-wise in large system still)
    list_queryset = Caseload.objects.all()
    queryset = Caseload.objects.all().prefetch_related('clients',
                                                       'case_types',
                                                       'caseload_roles',
                                                       'caseload_roles__role',
                                                       'caseload_roles__users',
                                                       'caseload_roles__groups')
    list_serializer_class = CaseloadSerializer
    serializer_class = CaseloadDetailsSerializer

    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']

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
