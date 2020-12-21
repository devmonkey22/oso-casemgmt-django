### Delegate 

allow(user: casemgmt::User, action, case_type: casemgmt::CaseType) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    # somehow unify works fine
    caseload = case_type.caseloads and
    caseload matches casemgmt::Caseload and
    rbac_allow(user, action, caseload);


allow(user: casemgmt::User, action, template: casemgmt::DocumentTemplate) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    caseload = template.case_type.caseloads and
    caseload matches casemgmt::Caseload and
    rbac_allow(user, action, caseload);

allow(user: casemgmt::User, action, document: casemgmt::Document) if
    # TODO: This _should_ be `in` instead, but `in` isn't working correctly
    caseload = document.template.case_type.caseloads and
    caseload matches casemgmt::Caseload and
    rbac_allow(user, action, caseload);
