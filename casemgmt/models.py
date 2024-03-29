from django.contrib.auth.models import AbstractUser, Group, Permission, GroupManager
from django.db import models
from django_oso.models import AuthorizedModel


## MODELS ##

class User(AbstractUser):
    """
    System users as Case Workers, Supervisors, Auditors, etc.
    """
    # basic info
    email = models.CharField(max_length=256)


class Role(models.Model):
    """
    Job role that has associated permissions. Modeled using ``auth.Group`` model, but separated to prevent assigning
    users directly to the role (group) globally.  Users can be assigned to this role through scoped models like ``CaseloadRole``.
    """
    name = models.CharField(max_length=150, unique=True)
    permissions = models.ManyToManyField(
        Permission,
        blank=True,
    )

    objects = GroupManager()

    class Meta:
        verbose_name = 'Role'
        verbose_name_plural = 'Roles'

    def __str__(self):
        return self.name

    def natural_key(self):
        return (self.name,)


class Client(AuthorizedModel):
    """
    Client/Customer
    """
    first_name = models.CharField(max_length=256)
    last_name = models.CharField(max_length=256)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"


class CaseType(AuthorizedModel):
    """
    Case (Program) Type - for example, Medical, Unemployment, WorkersCompensation
    """
    code = models.CharField(max_length=5, unique=True)
    name = models.CharField(max_length=256)

    def __str__(self):
        return f"{self.name} ({self.code})"


class DocumentTemplate(AuthorizedModel):
    """
    Document Template used for Documents (of a specific CaseType)
    """
    code = models.CharField(max_length=10)
    name = models.CharField(max_length=256)
    case_type = models.ForeignKey(CaseType, related_name="document_templates", on_delete=models.CASCADE)
    filename = models.CharField(max_length=1024)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["code", "case_type"], name="code_case_type")
        ]

    def __str__(self):
        return f"{self.name} ({self.case_type.code})"


class Document(AuthorizedModel):
    """
    Individual document instances for a client based on templates.
    Documents are indirectly linked to CaseTypes through its `template.case_type` field.
    """
    name = models.CharField(max_length=256)
    client = models.ForeignKey(Client, related_name="documents", on_delete=models.CASCADE)
    template = models.ForeignKey(DocumentTemplate, related_name="documents", on_delete=models.CASCADE)

    # Just as an example to store data for document. Normally would be stored in related DB models, NoSQL, etc.
    content = models.TextField(null=True)

    # time info
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} for {self.client} ({self.template.case_type.code})"




class DocumentActivityLog(AuthorizedModel):
    """
    Activity log records for related documents
    """
    VERB_VIEWED = 'viewed'
    VERB_CREATED = 'created'
    VERB_UPDATED = 'updated'
    VERB_DELETED = 'deleted'
    VERB_SHARED = 'shared'
    VERB_MAILED = 'mailed'

    LOG_VERB_CHOICES = [
        (VERB_VIEWED, 'Viewed document'),
        (VERB_CREATED, 'Created document'),
        (VERB_UPDATED, 'Updated document'),
        (VERB_DELETED, 'Deleted document'),
        (VERB_SHARED, 'Shared document'),
        (VERB_MAILED, 'Mailed document'),
    ]

    document = models.ForeignKey(Document, related_name="activities", on_delete=models.CASCADE)

    date = models.DateTimeField(auto_now_add=True)
    actor = models.ForeignKey(User, related_name="document_activities", null=True, on_delete=models.SET_NULL)

    verb = models.CharField(max_length=10, choices=LOG_VERB_CHOICES)
    description = models.CharField(max_length=255, null=True)


    def __str__(self):
        return f"{self.actor.username} {self.verb} '{self.document}': {self.description}"

    class Meta:
        ordering = ("date", "id")


class Caseload(AuthorizedModel):
    """
    A caseload is a set of clients and set of casetypes.
    A client may have related records to multiple different case types, not all of which may be part of this caseload.
    """
    name = models.CharField(max_length=1024)

    # many-to-many relationship with clients
    clients = models.ManyToManyField(Client, related_name="caseloads")

    # many-to-many relationship with CaseTypes
    case_types = models.ManyToManyField(CaseType, related_name="caseloads")

    def __str__(self):
        return f"{self.name}"


## ROLE MODELS ##

class CaseloadRole(AuthorizedModel):
    """
    A caseload role is a role assignment from a user/group to a caseload.
    """
    caseload = models.ForeignKey(Caseload, related_name="caseload_roles", on_delete=models.CASCADE)

    # Role (auth group) with permissions (not just a role name)
    # For simplicity, auth.Group is being overloaded as a Role with permissions assigned (but in theory, no global members)
    # For larger systems, it is recommended to create an explicit `Role` model with permissions, admin interface, etc.
    role = models.ForeignKey(Role, related_name="caseload_roles", on_delete=models.CASCADE)

    # many-to-many relationship with users
    user = models.ForeignKey(User, blank=True, null=True, related_name="caseload_roles", on_delete=models.CASCADE)

    # many-to-many relationship with groups (groups can be teams of CaseWorkers, rather than explicit `Team` model)
    group = models.ForeignKey(Group, blank=True, null=True, related_name="caseload_roles", on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.role.name} on {self.caseload}"



## Case-specific Data Models related to Documents ##

class WkcmpEligibilityData(AuthorizedModel):
    """
    Data specific to Eligibility Form (Document) records.
    Provides example of authorizing access based on related model (Document) and all its policies, plus any specific
    policies for ourselves too.
    """

    document = models.ForeignKey(Document, related_name="wkcmp_eligibility", on_delete=models.CASCADE)

    current_monthly_income = models.DecimalField(max_digits=8, decimal_places=2)
    employer = models.CharField(max_length=100)

    num_dependents = models.PositiveSmallIntegerField()

