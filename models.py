from django.contrib.gis.db import models
from django.contrib.gis.geos import GEOSGeometry
import re

magnitude_types = (
    ('-', '-'),
    ('M', 'M'),
    ('Mb', 'Mb'),
    ('mbGS', 'mbGS'),
    ('Mc', 'Mc'),
    ('MD', 'MD'),
    ('MD/ML', 'Mh'),
    ('ML', 'ML'),
    ('MLGS', 'MLGS'),
    ('MLPAS', 'MLPAS'),
    ('MLSLC', 'MLSLC'),
    ('MM', 'MM'),
    ('Ms', 'Ms'),
    ('Mw', 'Mw'),
    ('MwHRV', 'MwHRV'),
    ('Unk', 'Unknown')
)

class EarthquakeData(models.Model):
    class Meta:
        verbose_name_plural = 'Earthquake data'
        
    date = models.DateTimeField()
    depth = models.FloatField()
    magnitude = models.CharField(max_length=6)
    type = models.CharField(max_length=5, choices=magnitude_types)
    location = models.CharField(max_length=50, blank=True)
    source_catalog = models.CharField(max_length=50)
    latitude = models.FloatField()
    longitude = models.FloatField()
    geom = models.PointField(srid=4326, blank=True, null=True)
    objects = models.GeoManager()
    
    def __unicode__(self):
        return "Magnitude %s on %s" % (self.magnitude, self.occurance_date())
    
    def isodate(self):
        return self.date.isoformat()
    
    def occurance_date(self):
        return "%s/%s/%s" % (self.month(), self.day(), self.year())
        
    def year(self):
        m = re.search('^\d{4}', self.isodate())
        return m.group(0)
    
    def month(self):
        m = re.search('-(?P<month>\d{2})-', self.isodate())
        return m.group('month')
    
    def day(self):
        m = re.search('-(?P<day>\d{2})T', self.isodate())
        return m.group('day')
    
    def hours(self):
        m = re.search('T(?P<hour>\d{2}):', self.isodate())
        return m.group('hour')
    
    def minutes(self):
        m = re.search(':(?P<min>\d{2}):', self.isodate())
        return m.group('min')
    
    def seconds(self):
        m = re.search(':(?P<sec>\d{2})$', self.isodate())
        return m.group('sec')
    
    def clean(self):
        self.geom = GEOSGeometry('POINT(' + str(self.longitude) + ' ' + str(self.latitude) + ')')