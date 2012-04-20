from django.contrib import admin
from models import EarthquakeData

class EQAdmin(admin.ModelAdmin):
    list_display = ('__unicode__', 'magnitude', 'type', 'depth', 'occurance_date', 'source_catalog', 'latitude', 'longitude')
    exclude = ('geom',)
    
admin.site.register(EarthquakeData, EQAdmin)