from functools import lru_cache
from typing import Tuple, Union

MAX_CACHE_SIZE = 200


class PermissionInfo:
    """
    Information needed to validate/query permissions in Polar, etc.
    We don't pass around real `Permission` models in Polar because they don't serialize/work well so far.
    """
    def __init__(self, id: int, app_label: str, codename: str):
        self.id = id
        self.app_label = app_label
        self.codename = codename

        self.full_name = ".".join([app_label, codename])

    def __repr__(self):
        return f"<PermissionInfo: {self.full_name}({self.id})>"


class PermissionHelpers:
    """
    Helper methods to work with Permissions from Oso (available as ``PermissionHelper.*`` methods)
    """

    @classmethod
    @lru_cache(maxsize=MAX_CACHE_SIZE)
    def get_permission_info_for_model_action(cls, action, model_cls) -> PermissionInfo:
        """
        Get basic permission information (ID and Full Name) for model action
        :param action:
        :param model_cls:
        :return:
        """
        app_label, codename = cls._get_permission_parts_for_model_action(action, model_cls)
        content_type_id = cls._get_permission_content_type_id((app_label, codename))
        perm_id = cls._get_permission_id(content_type_id=content_type_id, codename=codename)
        return PermissionInfo(
                id=perm_id,
                app_label=app_label,
                codename=codename,
            )


    # ########################################################################
    # region Internal Utility Methods
    # ########################################################################

    @classmethod
    @lru_cache(maxsize=MAX_CACHE_SIZE)
    def _get_permission_id(self, content_type_id, codename):
        """
        Get permission ID based on content type and codename
        :param content_type_id:
        :param codename:
        :return:
        """
        from django.contrib.auth.models import Permission
        return Permission.objects.filter(content_type_id=content_type_id, codename=codename) \
                                 .values_list("id", flat=True)[0]


    @classmethod
    def _parse_permission(cls, perm:str) -> Tuple[str, str]:
        """
        Parse the qualified permission name into its parts.
        :param perm: Permission name as `app_label.codename`
        :return: Tuple as (app_label, codename)
        """
        app_label, codename = perm.split('.', 1)
        if app_label and codename:
            return (app_label, codename)
        else:
            raise ValueError("Invalid permission format")


    @classmethod
    @lru_cache(maxsize=MAX_CACHE_SIZE, typed=True)
    def _get_permission_content_type_id(cls, perm: Union[str, Tuple[str, str]]) -> int:
        """
        Get permission ContentType
        :param perm: Permission name as `app_label.codename` or as tuple of parts
        :return:
        """
        from django.contrib.contenttypes.models import ContentType

        if isinstance(perm, str):
            app_label, codename = cls._parse_permission(perm)
        else:
            app_label, codename = perm

        ctypes = ContentType.objects.filter(app_label=app_label,
                                            permission__codename=codename).values_list("id", flat=True)
        if ctypes and len(ctypes) == 1:
            return ctypes[0]
        else:
            raise ValueError(f"Expected single ContentType for permission '{perm}'. Found: {ctypes}")


    @classmethod
    def _get_permission_parts_for_model_action(cls, action, model_cls) -> Tuple[str, str]:
        """
        Get permission information (app_label, codename) for action name
        :param action: Action name that matches permission prefix like view, add, change, delete. Or full permission name if ``model_cls` null.
        :param model_cls: Model class, or if none, assumes action is full permission name
        :return: Qualified permission name like `casemgmt.view_client' or `casemgmt.view_client'
        """
        if "." in action:
            # Action is fully-qualified permission name already, so parse it (regardless of model)
            return cls._parse_permission(action)
        elif model_cls:
            app_label = model_cls._meta.app_label
            model_name = model_cls._meta.model_name
            return (app_label, f"{action}_{model_name}")
        else:
            return cls._parse_permission(action)


    # ########################################################################
    # endregion Internal Utility Methods
    # ########################################################################

