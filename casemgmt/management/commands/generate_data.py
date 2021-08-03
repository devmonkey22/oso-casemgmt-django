# Example:
#   python manage.py generate_data --nbr_logs 100

import logging
from collections import OrderedDict

from django.core.management.base import BaseCommand
from django.db import connection
from faker import Faker

from casemgmt.models import Document, User, DocumentActivityLog

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Generate fake test data'


    def add_arguments(self, parser):
        parser.add_argument('--nbr_logs', help="Number of activity logs per document to generate (default: 100)", type=int, default=100)


    def handle(self, *args, **options):
        # Prevent lots of debug logs (change if needed)
        logging.getLogger().setLevel(logging.INFO)

        fake = Faker()

        users = list(User.objects.all())

        # Generate 'Viewed' 75% of the time, and the others evenly distributed otherwise (not a big deal for testing, but why not)
        VERB_CODE_WEIGHTS = OrderedDict([
            (c[0], 0.75 if c[0] == 'viewed' else 0.25 / (len(DocumentActivityLog.LOG_VERB_CHOICES)-1) )
            for c in DocumentActivityLog.LOG_VERB_CHOICES
        ])

        for doc in Document.objects.all():
            logger.info(f"Generating {options['nbr_logs']} logs for '{doc}' document...")

            # Generate random document activity logs for each document
            logs = []
            for log_index in range(options['nbr_logs']):
                log = DocumentActivityLog(document=doc)
                log.date = fake.date_this_month(before_today=True)
                log.actor = fake.random_element(elements=users)
                log.description = fake.sentence(nb_words=6)
                log.verb = fake.random_element(elements=VERB_CODE_WEIGHTS)

                logger.debug(f"Created log: {log}")
                logs.append(log)

            DocumentActivityLog.objects.bulk_create(logs)


        logger.info(f"Running ANALYZE to ensure DB statistics are updated with new data...")
        try:
            with connection.cursor() as cursor:
                cursor.execute("ANALYZE VERBOSE")
        except Exception as ex:
            logger.info(f"Couldn't analyze the DB: {ex}")

