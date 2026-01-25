from django.apps import AppConfig  # type: ignore
from django.http import HttpRequest, HttpResponse  # type: ignore


class ChatConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "chat"
