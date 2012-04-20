from django.http import HttpResponse, HttpResponseNotAllowed, Http404
from django.shortcuts import get_object_or_404, render_to_response
from utils import HttpSimpleJsonResponse, HttpGeoJsonResponse, HttpKmlResponse, HttpCsvResponse
from models import EarthquakeData
import mimeparse

def byCollection(req, extension):
    quakes = EarthquakeData.objects.all();
    
    if req.method == 'GET':
        return contentNegotiation(req, extension, quakes, False)
    else:
        return HttpResponseNotAllowed(['GET'])

def byResource(req, quakeId, extension):
    quake = get_object_or_404(EarthquakeData, pk=quakeId)
    
    if req.method == 'GET':
        return contentNegotiation(req, extension, [quake])
    else:
        return HttpResponseNotAllowed(['GET'])
    
def contentNegotiation(req, extension, queryset, multiple=True):
    acceptedExtensions = {'.json': 'json', '.geojson': 'geojson', '.kml': 'kml', '.csv': 'csv'}
    acceptedTypes = {'application/json': 'json', 'application/geojson': 'geojson', 'application/vnd.google-earth.kml+xml': 'kml', 'text/csv': 'csv'}
    accept = req.META['HTTP_ACCEPT'].lower()
    
    if extension != None and extension in acceptedExtensions.keys():
        format = acceptedExtensions[extension]
    else:
        bestType = mimeparse.best_match(acceptedTypes.keys(), accept)
        if bestType in acceptedTypes.keys():
            format = acceptedTypes[bestType]
        else:
            return HttpResponse('Not Acceptable', status=406)
            
    if format == 'json':
        return HttpSimpleJsonResponse(queryset, multiple)
    elif format == 'geojson':
        return HttpGeoJsonResponse(queryset, multiple)
    elif format == 'kml':
        return HttpKmlResponse(queryset)
    elif format == 'csv':
        return HttpCsvResponse(queryset)
    

def map(req):
    return render_to_response("map.html")