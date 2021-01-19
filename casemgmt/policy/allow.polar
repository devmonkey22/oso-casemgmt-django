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
    case_type = document.template.case_type and
    case_type matches casemgmt::CaseType and

    client = document.client and
    client matches casemgmt::Client and

    ct_caseload = case_type.caseloads and
    client_caseload = client.caseloads and

    # TODO: Need to make sure case_type and client's caseload are the same (not just unrelated ones)
    # The unify returns "Not supported: cannot unify partials" error.
    ct_caseload.id = client_caseload.id and

    #rbac_allow(user, action, ct_caseload) and
    rbac_allow(user, action, client_caseload);
