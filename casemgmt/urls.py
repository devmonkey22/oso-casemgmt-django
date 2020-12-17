from django.shortcuts import redirect
from django.urls import path, include
from django.contrib.auth import views as auth_views
from rest_framework import routers

from .api.views import ClientViewSet, DocumentViewSet, DocumentTemplateViewSet, CaseloadViewSet


router = routers.DefaultRouter()
router.APIRootView.__doc__ = "Case Management API"

router.register(r'clients', ClientViewSet)
router.register(r'templates', DocumentTemplateViewSet)
router.register(r'documents', DocumentViewSet)
router.register(r'caseloads', CaseloadViewSet)

def index(request):
    return redirect("api-root")


urlpatterns = [
    path('', index, name="index"),
    path('api/', include(router.urls)),
    path(
        "login/",
        auth_views.LoginView.as_view(template_name="login.html"),
        name="login",
    ),
    path("logout/", auth_views.LogoutView.as_view(), name="logout"),

    path('api-auth/', include('rest_framework.urls')),
]
