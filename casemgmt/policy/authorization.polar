# ALLOW RULES

### check for RBAC rule
allow(actor, action: String, resource) if
    rbac_allow(actor, action, resource);

### check for global rule
allow(actor, action: String, resource) if
    global_allow(actor, action, resource);

