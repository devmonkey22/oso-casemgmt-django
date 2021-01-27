from django_oso import Oso

from . import oso_extensions


def register_extensions():
    # Register extensions/types into Oso
    Oso.register_constant(oso_extensions.PermissionHelpers, name="PermissionHelper")
    Oso.register_class(oso_extensions.PermissionInfo, name="PermissionInfo")
