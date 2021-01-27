### ########################################################
### ALLOW RULES --- entrypoint for all authorization decisions
### ########################################################

### Is user allowed to perform "action" on resource?
###
### The ``action`` may be a standard "view", "add", "change", "delete" model permission or a custom
### action that matches "{app_label}.{action}_{model_name}".
###

allow(actor, action: String, resource) if
  ### Lookup action -> permission, then check allow
  action_to_permission(action, resource, perm) and
  allow(actor, perm, resource);

# Each model should define their own allow, and can use `base_allow` and/or any other custom logic.
# We could use this generic rule to automatically call `base_allow`, then I feel like it's more difficult to totally
# override all policies on a per-model basis.
#allow(actor, perm: PermissionInfo, resource) if
#  base_allow(actor, perm, resource);







### ########################################################
### BASE ALLOW POLICIES
### ########################################################


### User has access if allowed to access resource with given permission (using RBAC with potentially resource-scoped (non-global) roles)
base_allow(actor, perm: PermissionInfo, resource) if
  rbac_allow(actor, perm, resource);


### User has access if has permission through direct (global) permission assignment
base_allow(actor, perm: PermissionInfo, resource) if
  global_allow(actor, perm, resource);


# Superusers can do anything, regardless of permission/action
base_allow(actor, _action, _resource) if
  actor.is_superuser;




