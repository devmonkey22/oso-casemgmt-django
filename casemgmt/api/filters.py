from django.core.exceptions import ImproperlyConfigured
from rest_framework import filters


class DocumentUrlPathFilter(filters.BaseFilterBackend):
    """
    Filter by the given document that's part of the URL path of the view.
    """
    document_pk_kwarg = "document_pk"

    def filter_queryset(self, request, queryset, view):
        document_pk_kwarg = getattr(view, 'document_pk_kwarg', self.document_pk_kwarg)

        if document_pk_kwarg in view.kwargs:
            return queryset.filter(document_id=view.kwargs[document_pk_kwarg])
        else:
            raise ImproperlyConfigured(f"URL pattern does not contain {document_pk_kwarg}")
