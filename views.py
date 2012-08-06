from django.http import HttpResponse, HttpResponseNotAllowed, Http404
from django.shortcuts import get_object_or_404, render_to_response
from django.contrib.gis.geos import Polygon
from utils import HttpSimpleJsonResponse, HttpGeoJsonResponse, HttpKmlResponse, HttpCsvResponse, HttpJsResponse
from models import EarthquakeData
import mimeparse, datetime

def byCollection(req, extension):
    quakes = queryParser(req)
    
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
    
def contentNegotiation(req, extension, queryset, single=True):
    acceptedExtensions = {'.json': 'json', 
                          '.geojson': 'geojson', 
                          '.kml': 'kml', 
                          '.csv': 'csv', 
                          '.js': 'js'}
    acceptedTypes = {'application/json': 'json', 
                     'application/geojson': 'geojson', 
                     'application/vnd.google-earth.kml+xml': 'kml', 
                     'text/csv': 'csv', 
                     'text/javascript': 'js',
                     'application/javascript': 'js'}
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
        return HttpSimpleJsonResponse(queryset, single)
    elif format == 'geojson':
        return HttpGeoJsonResponse(queryset, single)
    elif format == 'kml':
        return HttpKmlResponse(queryset)
    elif format == 'csv':
        return HttpCsvResponse(queryset)
    elif format == 'js':
        return HttpJsResponse(queryset, single)
    
def queryParser(req):
    query = req.GET.copy()
    for key in [ key for key in req.GET.keys() if key not in [field.name for field in EarthquakeData._meta.fields] ]:
        del query[key]
    
    if 'bbox' in req.GET.keys():
        # input is lower-left x,lower-left y,upper-right x,upper-right y, in WGS84
        queryBox = req.GET.get('bbox').split(',')        
        bbox = Polygon.from_bbox((queryBox[0], queryBox[1], queryBox[2], queryBox[3]))
        query['geom__intersects'] = bbox
        
    if 'daterange' in req.GET.keys():
        #input is year-month-day/year-month-day
        bounds = req.GET.get('daterange').split("/")
        start = bounds[0].split("-")
        end = bounds[1].split("-")
        startdate = datetime.datetime(int(start[0]), int(start[1]), int(start[2]))
        enddate = datetime.datetime(int(end[0]), int(end[1]), int(end[2]))
        query['date__range'] = (startdate, enddate)
        
    
    return EarthquakeData.objects.filter(**query.dict())
    
def map(req):
    return render_to_response("map.html")
    