### ########################################################
### MODEL ALLOW POLICIES
###
### If a model wants to perform any additional ABAC type checks, they should be able to add those into the `allow` rules
### below, or defer into a lower-level rule like `role_allow` or something.
### ########################################################



allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::Client) if
    base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::CaseType) if
    base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::DocumentTemplate) if
    base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::Document) if
    base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::DocumentActivityLog) if
  # To demonstrate optional foreign keys policy, if document is none, consider globally accessible activity.
  # Don't use this so blindly with all permissions in a real system, but maybe allow viewing?
  resource.document = nil or

  # TESTING: WHEN ACCESSING `/api/documents/1/activities/` THIS BREAKS WITH:
  #   AssertionError at /api/documents/1/activities/
  #   Inapplicable rule should have been filtered out
  #
  # And you can see the `APPLICABLE RULES` sections becomes expanded beyond the
  # `resource_role_applies_to(log: casemgmt::DocumentActivityLog{}, resource)` rule.
  #
  # [debug]    APPLICABLE_RULES:
  # [debug]      rbac_allow(user, perm: PermissionInfo{}, resource) if resource_role_applies_to(resource, role_resource) and user_in_role(user, role, role_resource) and role_allow(role, perm, resource);
  # [debug]    RULE: rbac_allow(user, perm: PermissionInfo{}, resource) if resource_role_applies_to(resource, role_resource) and user_in_role(user, role, role_resource) and role_allow(role, perm, resource);
  # [debug]    MATCHES: _perm_196 matches PermissionInfo{}, BINDINGS: {_perm_196 = <PermissionInfo: casemgmt.view_documentactivitylog(60)>}
  # [debug]    MATCHES: <PermissionInfo: casemgmt.view_documentactivitylog(60)> matches PermissionInfo{}, BINDINGS: {}
  # [debug]    MATCHES: <PermissionInfo: casemgmt.view_documentactivitylog(60)> matches {}, BINDINGS: {}
  # [debug]    QUERY: resource_role_applies_to(_resource_197, _role_resource_198) and user_in_role(_user_195, _role_199, _role_resource_198) and role_allow(_role_199, _perm_196, _resource_197), BINDINGS: {_user_195 = <SimpleLazyObject: <User: alan-wkcmp>>, _perm_196 = <PermissionInfo: casemgmt.view_documentactivitylog(60)>, _resource_197 = resource matches casemgmt::DocumentActivityLog{} and resource = _resource_74 and _resource_74 = _resource_88 and _resource_88 = __resource_105 and __resource_105 matches casemgmt::DocumentActivityLog{} and _resource_74 = _resource_160 and _resource_160 matches casemgmt::DocumentActivityLog{} and __value_3_162 = _resource_160.document and __value_3_162 = _resource_180 and _resource_180 = _resource_197}
  # [debug]      QUERY: resource_role_applies_to(_resource_197, _role_resource_198), BINDINGS: {_resource_197 = resource matches casemgmt::DocumentActivityLog{} and resource = _resource_74 and _resource_74 = _resource_88 and _resource_88 = __resource_105 and __resource_105 matches casemgmt::DocumentActivityLog{} and _resource_74 = _resource_160 and _resource_160 matches casemgmt::DocumentActivityLog{} and __value_3_162 = _resource_160.document and __value_3_162 = _resource_180 and _resource_180 = _resource_197}
  # [debug]        APPLICABLE_RULES:
  # [debug]          resource_role_applies_to(caseload: casemgmt::Caseload{}, caseload);
  # [debug]          resource_role_applies_to(client: casemgmt::Client{}, caseload) if client.caseloads = _value_5 and caseload in _value_5;
  # [debug]          resource_role_applies_to(case_type: casemgmt::CaseType{}, caseload) if case_type.caseloads = _value_6 and caseload in _value_6;
  # [debug]          resource_role_applies_to(template: casemgmt::DocumentTemplate{}, resource) if template.case_type = _value_7 and resource_role_applies_to(_value_7, resource);
  # [debug]          resource_role_applies_to(resource: casemgmt::Document{}, caseload) if resource.client = _value_8 and _value_8.caseloads = _value_9 and caseload in _value_9 and resource.template = _value_10 and _value_10.case_type = _value_11 and _value_11.caseloads = _value_12 and caseload in _value_12;
  # [debug]          resource_role_applies_to(log: casemgmt::DocumentActivityLog{}, resource) if log.document = _value_13 and resource_role_applies_to(_value_13, resource);
  # [debug]        RULE: resource_role_applies_to(caseload: casemgmt::Caseload{}, caseload);

  base_allow(user, perm, resource.document);

  # THIS WORKS: If `resource` is used instead such that `resource_role_applies_to` does the hierarchy lookup,
  # the policy eval runs fine.
  #base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::Caseload) if
    base_allow(user, perm, resource);


# Allow access if user has permission using related document as a potential role source
# The permissions should still be `casemgmt.{action}_wkcmpeligibilitydata`, etc so role needs those permissions still.
allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::WkcmpEligibilityData) if
    allow(user, perm, resource.document);


# Alternately, for WkcmpEligibilityData, we could have just called `base_allow`, and defined the
# `resource_role_applies_to(elig_data: casemgmt::WkcmpEligibilityData, resource)` rule below.  The above `allow`
# approach allows us to reuse/call document-specific policies more directly.
#
# allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::WkcmpEligibilityData) if
#       base_allow(user, perm, resource);




### ####################################################################################################
### RELATIONSHIP RULES/HELPERS

# TODO: If we had a way to use a function like `type(resource)` to pull the partial's type automatically,
#       these rules wouldn't be needed, or could become generic like:
#         resource_to_class(resource, resource_cls) if
#             resource_cls = type(resource);
#
# Define the link between an instance of a resource (even a Partial), and the real type
resource_to_class(_resource: casemgmt::Caseload, casemgmt::Caseload);
resource_to_class(_resource: casemgmt::Client, casemgmt::Client);
resource_to_class(_resource: casemgmt::Document, casemgmt::Document);
resource_to_class(_resource: casemgmt::DocumentActivityLog, casemgmt::DocumentActivityLog);
resource_to_class(_resource: casemgmt::DocumentTemplate, casemgmt::DocumentTemplate);
resource_to_class(_resource: casemgmt::CaseType, casemgmt::CaseType);

# Caseloads are their own role sources/relation
resource_role_applies_to(caseload: casemgmt::Caseload, caseload);


# Clients are associated to caseloads (and their roles)
resource_role_applies_to(client: casemgmt::Client, caseload) if
  caseload in client.caseloads;


# CaseTypes are associated to caseloads (and their member roles)
resource_role_applies_to(case_type: casemgmt::CaseType, caseload) if
  caseload in case_type.caseloads;


# DocumentTemplates are associated to their case type's caseloads (or other things if CaseType defines it)
resource_role_applies_to(template: casemgmt::DocumentTemplate, resource) if
  #resource in template.case_type.caseloads;
  resource_role_applies_to(template.case_type, resource);



# Documents are associated to caseloads (and their roles) when it's client and case_type are in the same caseload
resource_role_applies_to(resource: casemgmt::Document, caseload) if
  caseload in resource.client.caseloads and
  caseload in resource.template.case_type.caseloads;



# Activity logs are associated to it's document's role relations (ie: should be a caseload)
resource_role_applies_to(log: casemgmt::DocumentActivityLog, resource) if
  resource_role_applies_to(log.document, resource);


# Eligibility Data is associated to it's document's role relations (ie: should be a caseload)
#resource_role_applies_to(elig_data: casemgmt::WkcmpEligibilityData, resource) if
#  resource_role_applies_to(elig_data.document, resource);
