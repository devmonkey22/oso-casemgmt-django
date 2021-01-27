## Global permissions assigned to users

### Allow superusers/staff to view everything
#global_allow(user: casemgmt::User, _action, _resource) if
#    user.is_superuser;

### User has access if has permission through direct (global) permission assignment
global_allow(user, perm: String, _resource) if
  user_has_perm(user, perm);


### User has access if has permission through direct (global) permission assignment
global_allow(user, perm: PermissionInfo, _resource) if
  user_has_perm(user, perm.full_name);
