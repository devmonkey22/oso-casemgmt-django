from rest_framework.filters import BaseFilterBackend

# Translate request method (GET, POST, etc) into Permission "action" name
REQUEST_METHOD_TO_AUTHORIZE_ACTION = {
    'GET': 'view',
    'OPTIONS': 'view',
    'HEAD': 'view',
    'POST': 'add',
    'PUT': 'change',
    'PATCH': 'change',
    'DELETE': 'delete',
}

class AuthorizeFilter(BaseFilterBackend):
    """
    A filter backend that uses the ``django-oso`` authorization library to filter a ``AuthorizedQuerySet`` using the defined policies.

    The filter should get added to a DRF View's `filter_backends` like:

    - `filter_backends = (AuthorizeFilter, )`.
    """
    def filter_queryset(self, request, queryset, view):
        # If Queryset derives from AuthorizedQuerySet, etc.
        if hasattr(queryset, 'authorize'):
            action = REQUEST_METHOD_TO_AUTHORIZE_ACTION.get(request.method, 'unknown')
            return queryset.authorize(request, action=action)
        else:
            raise TypeError(f"View {view.__class__.__name__} uses to QuerySet {queryset.__class__.__name__} that "
                            f"does not support authorization. Cannot filter.")

