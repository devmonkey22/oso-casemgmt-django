# RBAC BASE POLICY

## Top-level RBAC allow rule

### The association between the resource roles and the requested resource is outsourced from the rbac_allow
rbac_allow(user, action, resource) if
    # First, check whether user has a direct role
    # or a role from an associated resource
    resource_role_applies_to(resource, role_resource) and
    user_in_role(user, role, role_resource) and
    role_allow(role, action, resource);

# RESOURCE-ROLE RELATIONSHIPS

## These rules allow roles to apply to resources other than those that they are scoped to.
## The most common example of this is nested resources, e.g. Repository roles should apply to the Issues
## nested in that repository.

### A resource's roles applies to itself
resource_role_applies_to(role_resource, role_resource);

# ROLE-ROLE RELATIONSHIPS

## Role Hierarchies

### Grant a role permissions that it inherits from a more junior role
role_allow(role, action, resource) if
    inherits_role(role, inherited_role) and
    role_allow(inherited_role, action, resource);

# TODO: Revisit if this works
# ### Helper to determine relative order or roles in a list
# inherits_role_helper(role, inherited_role, role_order) if
#     ([first, *rest] = role_order and
#     role = first and
#     inherited_role in rest) or
#     ([first, *rest] = role_order and
#     inherits_role_helper(role, inherited_role, rest));