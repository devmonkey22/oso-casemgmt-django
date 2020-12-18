#!/bin/bash

python manage.py dumpdata --natural-foreign --natural-primary --indent 2 auth.Group -o casemgmt/fixtures/group.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.User -o casemgmt/fixtures/user.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.Role -o casemgmt/fixtures/role.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.Client -o casemgmt/fixtures/client.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.CaseType -o casemgmt/fixtures/casetype.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.DocumentTemplate -o casemgmt/fixtures/template.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.Document -o casemgmt/fixtures/document.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.Caseload -o casemgmt/fixtures/caseload.json
python manage.py dumpdata --natural-foreign --natural-primary --indent 2 casemgmt.CaseloadRole -o casemgmt/fixtures/caseload-role.json

