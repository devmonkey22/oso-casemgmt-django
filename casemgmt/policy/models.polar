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



# Allow a user to change a DocumentTemplate as long as they have access to
# change it for *ALL* documents that link to template.
allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::DocumentTemplate) if
    perm.full_name in ["casemgmt.change_documenttemplate"] and
    forall( doc in resource.documents,
            doc matches casemgmt::Document and
            base_allow(user, perm, doc) );


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::DocumentTemplate) if
    not perm.full_name in ["casemgmt.change_documenttemplate"] and
    base_allow(user, perm, resource);


allow(user: casemgmt::User, perm: PermissionInfo, resource: casemgmt::Document) if
    base_allow(user, perm, resource);


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


# Eligibility Data is associated to it's document's role relations (ie: should be a caseload)
#resource_role_applies_to(elig_data: casemgmt::WkcmpEligibilityData, resource) if
#  resource_role_applies_to(elig_data.document, resource);
