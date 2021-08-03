from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets

from casemgmt.api.filters import DocumentUrlPathFilter
from casemgmt.api.serializers import (
    ClientSerializer, DocumentSerializer, DocumentTemplateSerializer, CaseloadSerializer, CaseloadDetailsSerializer,
    DocumentActivityLogSerializer,
)
from casemgmt.models import (
    Client, DocumentTemplate, Document, Caseload, DocumentActivityLog,
)

from drf_oso.filters import AuthorizeFilter


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['last_name', 'first_name']


class DocumentTemplateViewSet(viewsets.ModelViewSet):
    queryset = DocumentTemplate.objects.all().select_related('case_type')
    serializer_class = DocumentTemplateSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']


class DocumentViewSet(viewsets.ModelViewSet):
    queryset = Document.objects.all().select_related('client',
                                                     'template',
                                                     'template__case_type')
    serializer_class = DocumentSerializer
    filter_backends = (AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['name']



class DocumentActivityLogViewSet(viewsets.ModelViewSet):
    """Document Activity Log data"""
    list_queryset = DocumentActivityLog.objects.all().select_related("actor")
    queryset = DocumentActivityLog.objects.all().select_related("actor").prefetch_related()
    list_serializer_class = DocumentActivityLogSerializer
    serializer_class = DocumentActivityLogSerializer

    filter_backends = (DocumentUrlPathFilter, AuthorizeFilter, DjangoFilterBackend)
    filterset_fields = ['verb']

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
