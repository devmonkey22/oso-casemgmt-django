from typing import Dict

from rest_framework import serializers


class HyperlinkedNestedIdentityField(serializers.HyperlinkedIdentityField):
    """
    Extended hyperlink identity field that supports including additional URL kwargs when reversing URLs.
    For example, when using `documents/{document_pk}/.../subdata/{pk}`

    For extended/complex uses, consider `drf-nested-routers` package.
    """

    # Dictionary of `{ "nested_lookup_url_kwarg": "lookup_field" }` (related view's kwarg to our object's properties)
    nested_lookup_kwargs = None


    def __init__(self, view_name=None, nested_lookup_kwargs: Dict=None, **kwargs):
        if nested_lookup_kwargs:
            self.nested_lookup_kwargs = nested_lookup_kwargs
        super().__init__(view_name, **kwargs)

    def get_url(self, obj, view_name, request, format):
        """
        Given an object, return the URL that hyperlinks to the object.

        May raise a `NoReverseMatch` if the `view_name` and `lookup_field`
        attributes are not configured to correctly match the URL conf.
        """
        # Unsaved objects will not yet have a valid URL.
        if hasattr(obj, 'pk') and obj.pk in (None, ''):
            return None

        lookup_value = getattr(obj, self.lookup_field)
        kwargs = {self.lookup_url_kwarg: lookup_value}

        # Add additional kwargs for URL
        if self.nested_lookup_kwargs:
            for nested_lookup_url_kwarg, lookup_field in self.nested_lookup_kwargs.items():
                kwargs[nested_lookup_url_kwarg] = getattr(obj, lookup_field)

        return self.reverse(view_name, kwargs=kwargs, request=request, format=format)
