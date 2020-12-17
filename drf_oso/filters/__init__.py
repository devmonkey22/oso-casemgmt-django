from rest_framework.filters import BaseFilterBackend

class AuthorizeFilter(BaseFilterBackend):
    """
    A filter backend that uses the ``django-oso`` authorization library to filter a ``AuthorizedQuerySet`` using the defined policies.

    The filter should get added to a DRF View's `filter_backends` like:

    - `filter_backends = (AuthorizeFilter, )`.
    """
    def filter_queryset(self, request, queryset, view):
        # If Queryset derives from AuthorizedQuerySet, etc.
        if hasattr(queryset, 'authorize'):
            return queryset.authorize(request)
        else:
            raise TypeError(f"View {view.__class__.__name__} uses to QuerySet {queryset.__class__.__name__} that "
                            f"does not support authorization. Cannot filter.")

