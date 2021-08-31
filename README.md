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
  - Job role that has associated permissions. Modeled after ``auth.Group`` model, but separated to prevent assigning
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

To configure and run the application using the Makefile, just run:

```
$ make run
```


To **manually** set up and run the application, complete the following steps:

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


If you want to start from a fresh environment/data, run:

```
$ make clean run
```


## Primary Permission Sources

In this example, we will use the Django `Permission` model with various scopes (sources).

In some systems, to simplify permissions, assignments, and administration,
we could utilize permissions related to primary models, rather than all ancillary data tables and their permissions.
Or we could use a hybrid approach with permissions driving access to primary models, then custom Oso policies to control more fine-grained actions on ancillary models - dealer's choice.

### Sources

1. Global User/Group permissions
	- For example, if a user is assigned the `casemgmt.view_client` permission globally, they can see any client.
	- As future work (homework), you could create models to associate users or groups to a role globally, then create a custom Django auth backend that loads those with the user.  That way, roles can play a bigger part of the global permission sources.
2. `CaseloadRoles`
	- If a user (or one of their groups) is assigned to a caseload role, the user will inherit the permissions of that role, for any linked client/casetype.


There are several models that drive the authorization policies in this example.

1. `Client`
2. `CaseType`
3. `Caseload`


## Secondary Models

1. `Document`
	- Users are not assigned to documents directly. It derives it's role sources from its related `Client` and `CaseType`, and more accurately, from their mutual caseloads that a user is a member of. For example, the user must have the `casemgmt.view_document` permission through their caseload role of a caseload in which the client and document template's `CaseType` are linked (Caseload Scope) or globally (not common in a case management system).

2. `WkcmpEligibilityData`
    - This is an example of an extension type model, where we may want policies specific to this model, but in general, want to use the related document (and thus client/casetype/caseloads) to find scoped roles for the user.


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


## Querying Policies

To query the Case Management policies from the command-line, we can use the `oso_shell` management command to start an [Oso REPL](https://docs.osohq.com/more/dev-tools/repl.html).

   ```
   $ ./venv/bin/python manage.py oso_shell
   ```

## Reviewing API Requests

To help to see how the API requests are performed, the [django-debug-toolbar](https://github.com/jazzband/django-debug-toolbar)
library is installed and configured to introspect/debug the API requests, including to see the underlying SQL queries submitted
with authorization checks.  This helps show `django-oso`'s partial evaluation support with Django QuerySets.


## Running with Postgres

The default database uses SQLite, but you can configure it to use PostgreSQL (if installed/available).

1. Connect to postgres like `sudo -u postgres psql`
2. Within the PSQL shell:
       
    ```postgresql
    CREATE USER case_mgmt_app WITH PASSWORD 'case_mgmt';
    ALTER ROLE case_mgmt_app WITH SUPERUSER;
    
    CREATE DATABASE oso_case_mgmt WITH OWNER case_mgmt_app ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
    ```
    
    Then press `CTRL+D` to exit the shell.

3. In `casemgmt_example/settings.py`, change the `DATABASES` dictionary to use the the postgres engine settings.
4. Run `make clean run` 


## Known Issues/TODO

Where to begin... this is still a work-in-progress...

1. Most APIs do not accept POSTing data successfully. The serializers are incomplete except for reading so far due to nested relations, etc.  See Full CRUD Implementation below for thoughts.

2. Performance of policy evaluation has room for improvement.  For example, requests to `/api/documents` with `alan-wkcmp` user took about 0.461 seconds to evaluate and prepare the QuerySet filter.  The
underlying SQL query took ~1.25ms.

    1. The SQL generated from the filtered QuerySet is also non-optimal (lots of nested/repetitive EXISTS clauses, but functionally correct, which was the goal of the Oso team to start.
    
        For example, the `user_in_role(user: casemgmt::User, role, resource: casemgmt::Caseload)` rule could ideally generate one set of joins to the CaseloadRoles table, then conditionally check user vs group, or something like that.
     
    Progress is being made all the time on these fronts.


## Full CRUD Implementation

This case management example needs more work in the area of add/change/delete unfortunately, especially add (create/POST).
In other projects, I used a combination of the `AuthorizeFilter` and a custom DRF Permission class (perhaps call it `AuthorizePermission`?) to handle all the different angles.

I also had to alter my approach to be able to return `403` in some cases and `404` in others (ie: if the user can view a record but not change/delete it, I wanted to return `403` rather than the `404` that this example is set up to do). To do that, the `AuthorizeFilter` always checked `view` permission by default, and the AuthorizePermission then checked the change, delete, etc.
Creating (`POST`) data is hard because initially there is no object to check like you can for the other actions (`view`, `change`, etc). In my case, I either used the `AuthorizePermission` to call `is_allowed` **AFTER** the object was created in an atomic transaction (in DRF's `has_object_permission`), or I had the `APIView` provide a `get_parent_object` method that would pull out a related parent object from the URL path parameters (or it uses the user model itself), and then `AuthorizePermission` could check if the user had the add permission (using either the child's model name or parent `add_{model}` perm) using that parent object.

In other words, the patterns for authorizing creates is typically either:
- Create the object then authorize that you can create it. (Maybe create it, authorize it, then save it to the DB.)
- A `create_foo` action on a parent resource. Like `create_issue` on a `Repository` using Oso's GitClub example.



### DocumentActivityLog SQL Performance Notes

To check SQL performance of DocumentActivityLog REST APIs, read here.

1. Set up PostgreSQL (see section above)
2. Run `make clean venv` to set up base database stuff.
3. Activate venv with `python3 venv/bin/activate`
4. Run `python3 manage.py generate_data --nbr_logs 5000` to generate a bunch of test data per document
5. Run `make run` to start the web server.
6. In your browser, go to http://localhost:10000/api/documents/6/activities/
7. Log in as `alan_wkcmp` and `caseworker123` (or any other user with a resource-scoped role)
8. Review SQL etc from Django Debug Toolbar in the sidebar.

In a local dev environment (4 core, 10GB VM), with 5000 logs per document, this REST API call takes ~14 seconds.  The paginated SQL COUNT query around 6 seconds and the 25 record page query around 7 seconds.

Records per document | DB Perf | Request Perf
-------------------- | ------- | ------------
2000                 | 6 queries in 76ms | Request took 673ms
3000                 | 6 queries in 95ms | Request took 704ms
3500                 | 6 queries in 98ms | Request took 706ms
4000                 | 6 queries in 9000ms | Request took 9649ms


The performance cliff in my dev environment seemed to be around 3500-4000 records, where the execution plan shifted
from a Hash Join + Index Scan to use a Nested Loop + Materialize.  To play, disabling this join type via `set enable_nestloop=off;` in pgAdmin before running the `COUNT` query changed the runtime from 4 seconds down to ~600 ms.   


Due to the high number of joins and join types that the planner allowed, tuning my Postgres DB helped to improve
performance though.  By changing my `work_mem` from `4MB` to `10MB`, my run times improved to:

Records per document | DB Perf | Request Perf
-------------------- | ------- | ------------
5000                 | 6 queries in 117ms | Request took 690ms
7500                 | 6 queries in 158ms | Request took 789ms  
10000                | 6 queries in 76932ms (COUNT query took 36 seconds in pgAdmin) | Request took 77505ms


With `work_mem` set to `20MB` now:

Records per document | DB Perf | Request Perf
-------------------- | ------- | ------------
10000                | 6 queries in 184ms | Request took 818ms
12500                | 6 queries in 213ms | Request took 800ms
15000                | 6 queries in 101750ms | Request took 102400ms 

So the heavy joins are obviously very `work_mem` and hash join dependent.



If you want to clear your DocumentActivityLog:

1. Run `./venv/bin/python3 manage.py shell`
2. In the shell, run:

    ```python
    from casemgmt.models import DocumentActivityLog
    DocumentActivityLog.objects.all().delete()
    ```
3. Then regenerate new data if you want.

