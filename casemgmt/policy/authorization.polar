# ALLOW RULES

### Allow superusers/staff to view everything
allow(user: casemgmt::User, _action, _resource) if
    user.is_staff;


# RBAC BASE POLICY

## Top-level RBAC allow rule

### To disable the RBAC policy, simply comment out this rule
allow(user: casemgmt::User, _action: String, _resource) if
    user.is_authenticated;
    #rbac_allow(user, action, resource);

### The association between the resource roles and the requested resource is outsourced from the rbac_allow
rbac_allow(actor: casemgmt::User, action, resource) if
    resource_role_applies_to(resource, role_resource) and
    user_in_role(actor, role, role_resource) and
    role_allow(role, action, resource);

## Resource-role relationships

### These rules allow a roles to apply to resources other than those that they are scoped to.
### The most common example of this is nested resources, e.g. Repository roles should apply to the Issues
### nested in that repository.

### A resource's roles applies to itself
resource_role_applies_to(role_resource, role_resource);




# USER-ROLE RELATIONSHIPS

