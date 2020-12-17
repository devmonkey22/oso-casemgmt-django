import traceback

from django.core.management.base import BaseCommand

# Example:
#   python manage.py oso_shell

class Command(BaseCommand):
    help = 'Start OSO Authorization Policy REPL Shell'

    def handle(self, *args, **options):
        from django_oso.oso import Oso
        while True:
            # Run OSO (which runs in loop too), and handle unhandled exceptions (KB Interrupt is already handled within
            # repl as a normal return.
            try:
                Oso.repl()
                return
            except Exception as e:
                traceback.print_exc()
