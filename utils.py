from django.core.serializers import serialize
from django.contrib.gis.geos import GEOSGeometry
from django.shortcuts import render_to_response
from django.http import HttpResponse
import json, csv

def HttpSimpleJsonResponse(querySet, single=True):
    output = list()
    for eqData in querySet:
        feature = {
            "id": eqData.pk,
            "date": eqData.isodate(),
            "depth": eqData.depth,
            "magnitude": eqData.magnitude,
            "type": eqData.type,
            "location": eqData.location,    
            "geom": eqData.geom.wkt       
        }
        output.append(feature)
        
    if single: output = feature
    return HttpResponse(json.dumps(output), content_type="application/json")

def HttpGeoJsonResponse(querySet, single=True):
    output = { "type": "FeatureCollection", "features": list() }
    for eqData in querySet:
        feature = {
            "type": "Feature",
            "id": eqData.pk,
            "properties": {
                "date": eqData.isodate(),
                "depth": eqData.depth,
                "magnitude": eqData.magnitude,
                "type": eqData.type,
                "location": eqData.location,                       
            },
            "geometry": json.loads(eqData.geom.json)       
        }
        output['features'].append(feature)
    if single: output = feature
    return HttpResponse(json.dumps(output), content_type="application/json")

def HttpKmlResponse(querySet, single=True):
    context = { 'features': list() }
    for feature in querySet:
        context['features'].append({
            'name': feature.__unicode__(),
            'description': 'There will be a description here',
            'geom': feature.geom.kml
        })
        
    return render_to_response("kml.xml", context, mimetype='application/vnd.google-earth.kml+xml')

def HttpCsvResponse(querySet):
    class FakeFile:
        def __init__(self):
            self.output = ""
        def write(self, data):
            self.output = self.output + str(data)
            
    fieldnames = ['Year', 'Month', 'Day', 'Latitude (N)', 'Longitude (W)', 'Depth (km)', 'Hours', 'Minutes', 'Seconds', 'Mag/Int', 'Location', 'Source Catalog']
    csvOut = FakeFile()
    csvWriter = csv.DictWriter(csvOut, fieldnames)
    csvWriter.writeheader()
    
    for f in querySet:
        row = {
            'Year': f.year(),
            'Month': f.month(),
            'Day': f.day(),
            'Latitude (N)': f.latitude,
            'Longitude (W)': f.longitude,
            'Depth (km)': f.depth,
            'Hours': f.hours(),
            'Minutes': f.minutes(),
            'Seconds': f.seconds(),
            'Mag/Int': f.magnitude,
            'Location': f.location,
            'Source Catalog': f.source_catalog            
        }
        csvWriter.writerow(row)
        
    return HttpResponse(csvOut.output, content_type='text/csv')
        