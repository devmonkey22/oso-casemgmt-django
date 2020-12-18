from django.contrib.auth.models import Group
from rest_framework import serializers

from casemgmt.models import Client, DocumentTemplate, Document, CaseType, User, Caseload, CaseloadRole, Role


class ClientSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Client
        fields = ['url', 'first_name','last_name']


class CaseTypeSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = CaseType
        fields = ['code', 'name']


class DocumentTemplateSerializer(serializers.HyperlinkedModelSerializer):
    case_type = CaseTypeSerializer(read_only=True)

    class Meta:
        model = DocumentTemplate
        fields = ['url', 'name', 'case_type']


class DocumentSerializer(serializers.HyperlinkedModelSerializer):
    client = ClientSerializer()
    template = DocumentTemplateSerializer()

    class Meta:
        model = Document
        fields = ['url', 'name', 'client', 'template', 'created_at', 'updated_at']


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id','username']


class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ['id', 'name']

class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = ['id', 'name']

class CaseloadRoleSerializer(serializers.HyperlinkedModelSerializer):
    role = RoleSerializer()
    users = UserSerializer(many=True)
    groups = GroupSerializer(many=True)

    class Meta:
        model = CaseloadRole
        fields = ['role', 'users', 'groups']


class CaseloadSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Caseload
        fields = ['url', 'name']


class CaseloadDetailsSerializer(serializers.HyperlinkedModelSerializer):
    clients = ClientSerializer(many=True)
    case_types = CaseTypeSerializer(many=True)
    caseload_roles = CaseloadRoleSerializer(many=True)

    class Meta:
        model = Caseload
        fields = ['url', 'name', 'clients', 'case_types', 'caseload_roles']


