# ALLOW RULES

### Allow superusers/staff to view everything
allow(user: casemgmt::User, _action, _resource) if
    user.is_staff;


# ##################################################################
# Core Authorization Resource Policies
# ##################################################################

# In order to provide model_cls to rbac_allow_action, each model must provide their own `allow` rule.
#allow(user: casemgmt::User, action: String, resource) if
#    rbac_allow_action(user, action, resource, model_cls);



### ##################################################################################################
### RBAC ALLOW ACTION
### rbac_allow_action(user: casemgmt::User, action: String, resource, model_cls)
### Determine if ``user`` has RBAC (permission) for the given ``action`` to the given ``resource``
### which is a model type of ``model_cls``.
###
### The ``action`` may be a standard "view", "add", "change", "delete" model permission or a custom
### action that matches "{app_label}.{action}_{model_name}".
###
### Generally, policies should use this rule when given an action, but does not need to define additional rules to
### specialize this rule.  Instead, specializations of ``rbac_allow`` can be created if permissions derive from
### alternate sources (related to resource, etc) beyond global permissions.
###
### Examples:
###
### # Test if user has view action permission (indirectly `casemgmt.view_client` permission to Client with PK 1
### ?= rbac_allow_action(casemgmt::User.objects.get(username="user"), "view", casemgmt::Client.objects.get(pk=1), casemgmt::Client);

### User has RBAC access by action (to anything) if staff
rbac_allow_action(user: casemgmt::User, _action: String, _resource, _model_cls) if
  user.is_staff;


### TODO: If we could resolve the actual model_cls using `Partial`s `TypeConstraint` from `resource`, we could skip `model_cls`
### parameter. However, assuming `Partial` could have multiple constraints, I'm guessing this isn't possible.

### User has RBAC access by action if RBAC access by permission
rbac_allow_action(user: casemgmt::User, action: String, resource, model_cls) if
  get_permission_by_action(action, model_cls, permission) and
  rbac_allow(user, permission, resource);


# ?= rbac_allow_action(casemgmt::User.objects.get(username: "admin"), "view", casemgmt::Client.objects.get(id: 1), casemgmt::Client)
# ?= rbac_allow_action(casemgmt::User.objects.get(username: "admin"), "view", casemgmt::Document.objects.get(id: 1), casemgmt::Document)


### ##################################################################################################
### RBAC ALLOW (BY PERMISSION): rbac_allow(user: casemgmt::User, permission, resource)

# Rule overload when perm_name given, not Permission
rbac_allow(user: casemgmt::User, perm_name: String, resource) if
  get_permission(perm_name, permission) and
  rbac_allow(user, permission, resource);


# ?= rbac_allow(casemgmt::User.objects.get(username: "admin"), "casemgmt.view_document", casemgmt::Document.objects.get(id: 1))


### User has RBAC access (to any resource) if superuser
rbac_allow(user: casemgmt::User, _perm: auth::Permission, _resource) if
  user.is_staff;


### User has RBAC access if has permission through resource or related resource
rbac_allow(actor: casemgmt::User, perm: auth::Permission, resource) if
    resource_relates_to(resource, related_resource) and
    user_has_permission(actor, perm, related_resource) and
    perm_allow(actor, perm, resource);



### #############################################################################################
### RESOURCE RELATIONSHIPS: resource_relates_to(x, y)
### Indicates if/how ``x`` is related to ``y``.

### These rules allow objects to relate to each other in defined ways.
### For example, for permissions to apply to resources other than those that they are scoped to.
### The most common example of this is nested resources, e.g. CaseloadRole permissions should apply to the
### Clients or CaseTypes that are assigned a caseload.
###
### Each relationship should define a new rule that helps bind the child resource (ie: Client) to the
### parent resource (ie: Caseload).

### Identity Rule: A resource relates to itself as (from, to)
resource_relates_to(resource, resource);



### ##################################################################
### Helper Rules
### ##################################################################

### Get Permission record by permission name (`app_label.codename`) (source rule)
get_permission(perm_name: String, permission) if
  [app_label, codename] = perm_name.split(".", 1) and
  permission in auth::Permission.objects.all().filter(content_type__app_label: app_label, codename: codename).select_related("content_type");

# ?= get_permission("casemgmt.view_client", p)


### Get Permission name from permission object (`app_label.codename`) (source rule)
get_permission_by_action(action: String, model_cls, permission) if
  codename := "".join([action, "_", model_cls._meta.model_name]) and
  permission in auth::Permission.objects.all().filter(content_type__app_label: model_cls._meta.app_label, codename: codename).select_related("content_type");

# ?= get_permission_by_action("view", casemgmt::Client, p)



### Does the user have the given global role (permission)?  (Regardless of resource)
user_has_permission(user: casemgmt::User, perm: auth::Permission, _related_resource) if
  user.has_perm("".join([perm.content_type.app_label, ".", perm.codename]));

# ?= user_has_permission(casemgmt::User.objects.get(username: "admin"), auth::Permission.objects.get(codename: "view_client"), "")
# ?= user_has_permission(casemgmt::User.objects.get(username: "admin"), auth::Permission.objects.get(codename: "view_client", content_type__app_label: "casemgmt"), "")


### Determine if role has the given permission.
### Binds ``permission``
role_has_permission(role: casemgmt::Role, permission) if
  permission in role.permissions.all();

# ?= role_has_permission(casemgmt::Role.objects.get(name: "CaseWorker Role"), auth::Permission.objects.get(codename: "view_client"))
# ?= role_has_permission(casemgmt::Role.objects.get(name: "CaseWorker Role"), p)



#
#### Determine if role has the given permission by name (source rule)
#### Also binds ``permission``
#role_has_permission(role: casemgmt::Role, perm_name: String, permission) if
  #[app_label, codename] = perm_name.split(".", 1) and
  #permission in role.permissions.all() and
  #permission.content_type.app_label = app_label and
  #permission.codename = codename;
#
#
#### Determine if role has the given permission by object (source rule)
#### Also binds ``perm_name``
#role_has_permission(role: casemgmt::Role, perm_name, permission: auth::Permission) if
  #permission in role.permissions.all() and
  #perm_name := "".join([permission.content_type.app_label, ".", permission.codename]);


### Get the auth groups that a user belongs to (source rule)
get_user_groups(user: casemgmt::User, group) if
  # group will bind to a auth::Group model
  group in auth::Group.objects.filter(user: user);


# By default, if permission available, consider it a valid permission found from the user's scope,
# so by default, it should be allowed.  Specialized rules could validate permission again using user or resource
# using fine-grained rules if desired.
perm_allow(_user: casemgmt::User, _perm: auth::Permission, _resource) if
  true;


