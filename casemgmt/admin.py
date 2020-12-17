from django.contrib import admin
from django.contrib.auth.admin import UserAdmin, GroupAdmin
from casemgmt.models import (
    User,
    Role,
    Client,
    CaseType,
    DocumentTemplate,
    Document,
    Caseload,
    CaseloadRole,
)

# Register your models here.
admin.site.register(User, UserAdmin)
admin.site.register(Role, GroupAdmin)
admin.site.register(Client)
admin.site.register(CaseType)
admin.site.register(DocumentTemplate)
admin.site.register(Document)
admin.site.register(Caseload)
admin.site.register(CaseloadRole)
