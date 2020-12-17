################################################################################################################
#### Model specific Policies
################################################################################################################



# ####################################################################################################
# CLIENT POLICIES

allow(user: casemgmt::User, action: String, resource: casemgmt::Client) if
    rbac_allow_action(user, action, resource, casemgmt::Client);


### A client can have zero or more related caseloads (source rule)
resource_relates_to(client: casemgmt::Client, caseload) if
    caseload in client.caseloads.all();
    #caseload in casemgmt::Caseload.objects.filter(clients: client);


### ####################################################################################################
### CASETYPE POLICIES

allow(user: casemgmt::User, action: String, resource: casemgmt::CaseType) if
    rbac_allow_action(user, action, resource, casemgmt::CaseType);


### A casetype can have zero or more related caseloads (source rule)
resource_relates_to(case_type: casemgmt::CaseType, caseload) if
    caseload in case_type.caseloads.all();
    #caseload in casemgmt::Caseload.objects.filter(case_types: case_type);


### ####################################################################################################
### DOCUMENT POLICIES

allow(user: casemgmt::User, action: String, resource: casemgmt::Document) if
    rbac_allow_action(user, action, resource, casemgmt::Document);


### A Document can have zero or more related resources (where document's client and case_type have same relation)
### For example, same related caseload.
resource_relates_to(document: casemgmt::Document, related_resource) if
    resource_relates_to(document.client, related_resource) and
    resource_relates_to(document.case_type, related_resource);


### ####################################################################################################
### DOCUMENTTEMPLATE POLICIES

allow(user: casemgmt::User, action: String, resource: casemgmt::DocumentTemplate) if
    rbac_allow_action(user, action, resource, casemgmt::DocumentTemplate);


# TODO: Fix errors when viewing `/api/templates/` as `billy-med`
#       We want to include permissions scoped by Caseload (template's case_type in one of user's caseloads)
#       Currently, only admins and maybe users with global permission can see this.

# ORIGINAL ATTEMPT: Use relation from template (template is a Partial unfortunately though)
#   Raises error like `Not supported: cannot call method on partial partial(_value_27_221) {  }`
#resource_relates_to(template: casemgmt::DocumentTemplate, related_resource) if
#    resource_relates_to(template.case_type, related_resource);


# ATTEMPT TO FIX 1: Raises `UnexpectedPolarTypeError` on `Partial`
#resource_relates_to(template: casemgmt::DocumentTemplate, related_resource) if
#    case_type in casemgmt::CaseType.objects.filter(templates: template) and
#    resource_relates_to(case_type, related_resource);





# ####################################################################################################
# CASELOAD POLICIES
#
# 1. Superusers can access anything about casemgmt::Caseload (like all other models)
# 2. Users who are assigned to a caseload (directly or through a group) are authorized to casemgmt::Caseload if their caseload role has permission for action.
# 3.

### User has RBAC access to resource if user (or their groups) belong to caseload with a Caseload Role
### with needed model permission (to original resource itself).
### This includes Caseload model itself, or any resource that has relations with Caseload.

# Caseload Scoped Permissions: Check if user has permission through caseload roles
user_has_permission(actor: casemgmt::User, permission: auth::Permission, related_resource: casemgmt::Caseload) if
  user_in_caseload_role(actor, caseload_role, related_resource) and
  role_has_permission(caseload_role.role, permission);




# ####################################################################################################
# CASELOAD ROLE HELPER RULES

### User CaseloadRole source: direct mapping between users and caseload roles (source rule)
user_in_caseload_role(user: casemgmt::User, caseload_role, caseload: casemgmt::Caseload) if
  # caseload_role will bind to an CaseloadRole object
  caseload_role in casemgmt::CaseloadRole.objects.filter(users: user) and
  caseload_role.caseload.id = caseload.id;


### User CaseloadRole role source: role from user's groups (source rule)
user_in_caseload_role(user: casemgmt::User, caseload_role, caseload: casemgmt::Caseload) if
  # caseload_role will bind to an CaseloadRole object
  # group will bind to an auth::Group object
  get_user_groups(user, group) and
  group_in_caseload_role(group, caseload_role, caseload);



### Group CaseloadRole source: direct mapping between auth groups and caseload roles (source rule)
group_in_caseload_role(group: auth::Group, caseload_role, caseload: casemgmt::Caseload) if
  # caseload_role will bind to an CaseloadRole object
  caseload_role in casemgmt::CaseloadRole.objects.filter(groups: group) and
  caseload_role.caseload.id = caseload.id;


