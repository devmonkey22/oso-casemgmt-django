### ########################################################
### HELPER RULES
### ########################################################

### Maps action to permission info { "id": int, "full_name": "{app_label}.{action}_{model_name}", ... }
### e.g. "view" -> "casemgmt.view_client"
action_to_permission(action: String, resource, perm) if
  resource_to_class(resource, resource_cls) and
  perm = PermissionHelper.get_permission_info_for_model_action(action, resource_cls);


# If action is already PermissionInfo, use it
action_to_permission(action: PermissionInfo, _resource, perm) if
  perm = action;



### Does the user have the given global role (permission)?
user_has_perm(user, perm: String) if
  user.has_perm(perm);
