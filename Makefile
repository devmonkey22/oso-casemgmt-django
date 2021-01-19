SHELL := /usr/bin/env bash


# Set up the venv, ensure the latest version of pip installed (>=20), etc.
venv:
	python3 -m venv venv/ && \
	source ./venv/bin/activate && \
	python -m pip install -U 'pip >=20' && \
	pip install -r requirements.txt && \
	python manage.py migrate && \
	bash ./casemgmt/fixtures/load.sh


run: venv
	./venv/bin/python manage.py runserver 0.0.0.0:10000

debug: venv
	POLAR_LOG=1 ./venv/bin/python manage.py runserver 0.0.0.0:10000


clean:
	rm -rf venv/ && \
	rm -f db.sqllite3


.PHONY: run clean