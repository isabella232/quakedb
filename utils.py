from django.core.serializers import serialize
from django.contrib.gis.geos import GEOSGeometry
from django.shortcuts import render_to_response
from django.http import HttpResponse
import json, csv

def HttpSimpleJsonResponse(querySet, single=True):
    response = HttpResponse("", content_type='application/json')
    if not single: response.write('[')
    lines = ','.join(['{"id":%s,"date":"%s","depth":%s,"magnitude":"%s","type":"%s","location":"%s","geom":"%s"}' % (data.pk,data.isodate(),data.depth,data.magnitude,data.type,data.location,data.geom.wkt) for data in querySet])
    response.write(lines)
    if not single: response.write(']')
    return response

def HttpGeoJsonResponse(querySet, single=True):
    response = HttpResponse("", content_type='application/json')
    if not single: response.write('{"type":"FeatureCollection","features":[')
    lines = ','.join(['{"type":"Feature","id":%s,"geometry":%s,"properties":{"date":"%s","depth":%s,"magnitude":"%s","type":"%s","location":"%s"}}' % (data.id,data.geom.json,data.isodate(),data.depth,data.magnitude,data.type,data.location) for data in querySet])
    response.write(lines)
    if not single: response.write(']}')
    return response

def HttpKmlResponse(querySet, single=True):
    context = { 'features': [ { 'name': feature.__unicode__(), 'description': 'Soon to come', 'geom': feature.geom.kml } for feature in querySet ] }
    return render_to_response("kml.xml", context, mimetype='application/vnd.google-earth.kml+xml')    

def HttpCsvResponse(querySet):            
    fieldnames = ['Year', 'Month', 'Day', 'Latitude (N)', 'Longitude (W)', 'Depth (km)', 'Hours', 'Minutes', 'Seconds', 'Mag/Int', 'Location', 'Source Catalog']
    response = HttpResponse("", content_type='text/csv')
    csvWriter = csv.DictWriter(response, fieldnames)
    headerRow = {}
    for header in fieldnames: 
        headerRow[header] = header
    csvWriter.writerow(headerRow)
    
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
        
    return response
        