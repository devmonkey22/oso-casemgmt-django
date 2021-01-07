# ALLOW RULES --- entrypoint for all authorization decisions

## Defer to models

### check for RBAC rule
allow(actor, action: String, resource) if
    rbac_allow(actor, action, resource);

### check for global rule
allow(actor, action: String, resource) if
    global_allow(actor, action, resource);

## Delegate by resource

### Delegate 

allow(user: casemgmt::User, action, client: casemgmt::Client) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    # with the `matches. Somehow unify works fine
    # NB: All relations should be expressed over the resource on the RHS
    # to avoid using querysets
    caseload = client.caseloads and
    caseload matches casemgmt::Caseload and
    # TODO: Ideally this would call `allow` again, but currently the lack of
    # types for rule selection means this would recurse infinitely
    rbac_allow(user, action, caseload);


allow(user: casemgmt::User, action, case_type: casemgmt::CaseType) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    # with the `matches. Somehow unify works fine
    # NB: All relations should be expressed over the resource on the RHS
    # to avoid using querysets
    caseload = case_type.caseloads and
    caseload matches casemgmt::Caseload and
    # TODO: Ideally this would call `allow` again, but currently the lack of
    # types for rule selection means this would recurse infinitely
    rbac_allow(user, action, caseload);


allow(user: casemgmt::User, action, template: casemgmt::DocumentTemplate) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    caseload = template.case_type.caseloads and
    caseload matches casemgmt::Caseload and
    rbac_allow(user, action, caseload);

allow(user: casemgmt::User, action, document: casemgmt::Document) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    case_type_caseload = document.template.case_type.caseloads and
    case_type_caseload matches casemgmt::Caseload and
    rbac_allow(user, action, case_type_caseload);

    # TODO: Need to make sure case_type and client's caseload are the same (not just unrelated ones)
    # But the unify returns "Not supported: cannot unify partials" error.
    #client_caseload = document.client.caseloads and
    #client_caseload matches casemgmt::Caseload and
    #case_type_caseload.id = client_caseload.id and
    #rbac_allow(user, action, client_caseload);
