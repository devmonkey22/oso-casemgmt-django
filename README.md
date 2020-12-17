# Modeling a Case Management system authorization design with oso

This application is a sample application that presents a basic Case Management data model,
meant to demonstrate the basics of an authorization approach using `django-oso` [authorization library](https://docs.osohq.com/using/frameworks/django.html) with [Django](https://www.djangoproject.com/) and [Django REST Framework](https://www.django-rest-framework.org/) as the base web frameworks.

As with any example, there are a wide variety of possible designs both more simple and more complex (fine-grained).
The approach chosen here was used to both demonstrate and validate Oso's capabilities as an authorization policy
framework in Django.


## Application Data Model

The app has the following models:

- `User`
  - System users as Case Workers, Supervisors, Auditors, etc.
- `Role`
  - Job role that has associated permissions. Modeled using ``auth.Group`` model, but separated to prevent assigning
    users directly to the role (group) globally.  Users can be assigned to this role through scoped models like ``CaseloadRole``.
  - Pre-defined roles include:
    - `Auditor Role` - Has `view` (read-only) access to various models.
    - `CaseWorker Role` - Has `view` and `change` permissions to various models, as well as `add` and `delete` permissions to other models.
    - `Director Role` - Has `view`, `add`, `change`, and `delete` permissions to various models.
- `Client`
  - Client/Customer record.
- `CaseType`
  - Case (Program) Type - for example, Medical, Unemployment, Workers Compensation.
- `DocumentTemplate`
  - Document Template used for Documents (of a specific CaseType).
- `Document`
  - Individual document instances for a client based on templates.  Documents are indirectly linked to `CaseType` through its `template.case_type` field.
- `Caseload`
  - A caseload is a set of clients and set of casetypes. A client may have related records to multiple different case types, not all of which may be part of this caseload.
- `CaseloadRole`
  - Roles scoped to a caseload; each is associated with a single caseload.
  - Assigned to users through a many-to-many relationship.
  - Assigned to groups through a many-to-many relationship.
  - The role's permissions are described in `Role`.


## Running the App

To run the application, complete the following steps:

1. Set up a virtual environment and install required packages

   ```
   $ python -m venv venv/
   
   $ source venv/bin/activate

   $ pip install -r requirements.txt
   ```

2. Create the database

   ```
   $ python manage.py migrate
   ```

3. [OPTIONAL] Load the fixture data. This will create some seed data, as well as a superuser with the following credentials:
   username: admin
   password: admin

   ```
   $ bash ./casemgmt/fixtures/load.sh
   ```

   If you don't load the fixture data, you will need to create your own superuser with

   ```
   $ python manage.py createsuperuser
   ```

4. Run the server

   ```
   $ python manage.py runserver 0.0.0.0:10000
   ```

   Once the server is running, you can login to the admin dashboard (http://localhost:8000/admin/) to view or create more sample data.

   The API methods are browsable through http://localhost:10000/).

    Currently, most API serializers are only functioning for viewing. Due to the nested relations, they need more work to support
    POSTing, etc. The Admin dashboard is needed to add more data right now.




## Primary Permission Sources

In this example, we will use the Django `Permission` model with various scopes (sources).

In some systems, to simplify permissions, assignments, and administration,
we could utilize permissions related to primary models, rather than all ancillary data tables and their permissions.
Or we could use a hybrid approach with permissions driving access to primary models, then custom Oso policies to control more fine-grained actions on ancillary models - dealer's choice.

### Sources

1. Global User/Group permissions
	- For example, if a user is assigned the `casemgmt.view_client` permission globally, they can see any client.
2. `CaseloadRoles`
	- If a user is assigned to a caseload role, the user will inherit the permissions of that role, for any linked client/casetype.


There are several models that drive the authorization policies in this example.

1. `Client`
2. `CaseType`
3. `Caseload`


## Secondary Models

1. `Document`
	- Document does not have permissions required of its own. It derives it's permissions from its related Client and CaseType. For example, the user must have the `casemgmt.view_document` permission through their caseload role of a caseload in which the client and document's `CaseType` are linked (Caseload Scope) or globally (not common in a case management system).



## Demo Users

The users configured from the fixture data are:

```
username: admin
password: admin

username: billy-med
password: caseworker123

username: ralph-unemp
password: caseworker123

username: alan-wkcmp
password: caseworker123

username: tom-auditor
password: auditor123

username: director
password: theboss123

```

where `admin` is the django superuser.