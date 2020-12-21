## Global permissions assigned to users

### Allow superusers/staff to view everything
allow(user: casemgmt::User, _action, _resource) if
    user.is_staff;

### User has access if has permission through direct permission assignment
global_allow(user: casemgmt::User, action: String, _resource: casemgmt::Caseload) if
    user.has_perm("".join(["casemgmt.", action, "_caseload"]));

global_allow(user: casemgmt::User, action: String, _resource: casemgmt::Document) if
    user.has_perm("".join(["casemgmt.", action, "_document"]));

global_allow(user: casemgmt::User, action: String, _resource: casemgmt::Client) if
    user.has_perm("".join(["casemgmt.", action, "_client"]));

global_allow(user: casemgmt::User, action: String, _resource: casemgmt::CaseType) if
    user.has_perm("".join(["casemgmt.", action, "_casetype"]));
