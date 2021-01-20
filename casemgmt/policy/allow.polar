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
    # NB: All relations should be expressed over the resource on the RHS
    # to avoid using querysets
    caseload in client.caseloads and
    caseload matches casemgmt::Caseload and
    allow(user, action, caseload);


allow(user: casemgmt::User, action, case_type: casemgmt::CaseType) if
    # NB: All relations should be expressed over the resource on the RHS
    # to avoid using querysets
    caseload in case_type.caseloads and
    caseload matches casemgmt::Caseload and
    allow(user, action, caseload);


allow(user: casemgmt::User, action, template: casemgmt::DocumentTemplate) if
    caseload in template.case_type.caseloads and
    caseload matches casemgmt::Caseload and
    allow(user, action, caseload);

allow(user: casemgmt::User, action, document: casemgmt::Document) if
    caseload in document.template.case_type.caseloads and
    caseload in document.client.caseloads and
    caseload matches casemgmt::Caseload and
    allow(user, action, caseload);


# Allow access if user has same action rights on related document
allow(user: casemgmt::User, action, elig_data: casemgmt::WkcmpEligibilityData) if
    allow(user, action, elig_data.document);
