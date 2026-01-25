"""
URL configuration for underfoot project.
"""
from django.contrib import admin
from django.urls import path
from ninja import NinjaAPI

from chat.api import router as chat_router

api = NinjaAPI()
api.add_router("/underfoot", chat_router)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", api.urls),
]
