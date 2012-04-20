from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('',
    url(r'^earthquakedata/(?P<quakeId>\d+)(?P<extension>\..+)?$', 'quakedb.views.byResource'),     
    url(r'^earthquakedata(?P<extension>\..+)?$', 'quakedb.views.byCollection'), 
    url(r'^map$', 'quakedb.views.map'),                
)