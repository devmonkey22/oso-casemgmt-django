#!/bin/bash

python manage.py loaddata casemgmt/fixtures/group.json
python manage.py loaddata casemgmt/fixtures/user.json
python manage.py loaddata casemgmt/fixtures/role.json
python manage.py loaddata casemgmt/fixtures/client.json
python manage.py loaddata casemgmt/fixtures/casetype.json
python manage.py loaddata casemgmt/fixtures/template.json
python manage.py loaddata casemgmt/fixtures/document.json
python manage.py loaddata casemgmt/fixtures/caseload.json
python manage.py loaddata casemgmt/fixtures/caseload-role.json

python manage.py loaddata casemgmt/fixtures/wkcmp-eligibility.json


python manage.py generate_data
