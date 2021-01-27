### ########################################################
### RBAC BASE POLICY
### ########################################################

## Top-level RBAC allow rule

### The association between the resource roles and the requested resource is outsourced from the rbac_allow
rbac_allow(user, perm: PermissionInfo, resource) if
    # First, check whether user has a direct role or a role from an associated resource
    resource_role_applies_to(resource, role_resource) and
    user_in_role(user, role, role_resource) and
    role_allow(role, perm, resource);




### #############################################################################################
### RESOURCE TO TYPE RELATIONSHIPS
### #############################################################################################

### Each model (resource) that needs to be able to use `action_to_permission()` to convert action to permission
### must define a `resource_to_class()` rule.  This is needed until there is support for a function like `type(var)`
### to do this automatically.

#resource_to_class(_resource: label::Name, label::Name)



### ########################################################
### ROLE ALLOW CHECKS
### ########################################################


### Direct/indirect `Role` permission check
### If role has given permission by ID
role_allow(role, perm: PermissionInfo, _resource) if
  role_perm in role.permissions and
  role_perm.id = perm.id;


### Direct/indirect `Role` permission assignments
### If role has given permission name
role_allow(role, perm: String, _resource) if
  # Lookup permission info first
  perm_info = PermissionHelper.get_permission_info(perm) and
  role_perm in role.permissions and
  role_perm.id = perm_info.id;
