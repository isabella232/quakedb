from django.contrib.gis.db import models
from django.contrib.gis.geos import GEOSGeometry
from django.conf import settings

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
        ordering = ['-date']
        
    date = models.DateTimeField()
    latitude = models.FloatField()
    longitude = models.FloatField()
    depth = models.FloatField()
    magnitude = models.CharField(max_length=20)
    calculated_magnitude = models.FloatField(null=True, blank=True)
    type = models.CharField(max_length=5, choices=magnitude_types)
    rms = models.FloatField(null=True) # seconds, decimal
    erh = models.FloatField(null=True) # km, decimal
    erz = models.FloatField(null=True) # km, decimal
    source_catalog = models.CharField(max_length=50)
    location = models.CharField(max_length=50, blank=True)
    waveform_file = models.FileField(blank=True, null=True, upload_to=settings.MEDIA_ROOT + "/waveforms/") # upload a waveform file

    geom = models.PointField(srid=4326, blank=True, null=True)
    objects = models.GeoManager()
    
    def __unicode__(self):
        return "Magnitude %s on %s" % (self.magnitude, self.occurance_date())
    
    def isodate(self):
        return self.date.isoformat()

    def utcDate(self):
        return self.isodate().split("T")[0]

    def utcTime(self):
        return self.isodate().split("T")[1]

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

    def calculate_magnitude(self):
        if self.magnitude == "I":
            return float(1)
        elif self.magnitude == "II":
            return float(3)
        elif self.magnitude == "III":
            return float(3)
        elif self.magnitude == "IV":
            return float(4)
        elif self.magnitude == "V":
            return float(4)
        elif self.magnitude == "VI":
            return float(5)
        elif self.magnitude == "VII":
            return float(6)
        else:
            return float(self.magnitude)

    def clean(self):
        self.geom = GEOSGeometry('POINT(' + str(self.longitude) + ' ' + str(self.latitude) + ')')
        self.calculated_magnitude = self.calculate_magnitude()