from django.contrib import admin
from models import EarthquakeData

class EQAdmin(admin.ModelAdmin):
    list_display = ('id', '__unicode__', 'magnitude',  'type', 'rms', 'depth', 'erz', 'occurance_date', 'source_catalog', 'latitude', 'longitude', 'erh')
    list_display_links = ('__unicode__',)
    exclude = ('geom', 'calculated_magnitude')
    
admin.site.register(EarthquakeData, EQAdmin)