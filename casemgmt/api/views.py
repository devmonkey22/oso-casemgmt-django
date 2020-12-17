from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from casemgmt.api.serializers import (
    ClientSerializer, DocumentSerializer, DocumentTemplateSerializer, CaseloadSerializer,
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
    queryset = Caseload.objects.all()
    serializer_class = CaseloadSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']

