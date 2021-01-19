from rest_framework import serializers

from casemgmt import drf_components
from casemgmt.models import WkcmpEligibilityData


class WkcmpEligibilitySerializer(serializers.HyperlinkedModelSerializer):
    url = drf_components.HyperlinkedNestedIdentityField(view_name="wkcmpeligibilitydata-detail",
                                         nested_lookup_kwargs={ "document_pk": "document_id"})
    document = serializers.HyperlinkedRelatedField(view_name="document-detail", read_only=True)

    class Meta:
        model = WkcmpEligibilityData
        fields = ['url', 'document', 'current_monthly_income', 'employer', 'num_dependents']