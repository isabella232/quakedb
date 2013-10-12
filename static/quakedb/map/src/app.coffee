root = @
if not root.app? then app = root.app = {} else app = root.app

app.center = ol.proj.transform [-112.085034, 33.857990], 'EPSG:4326', 'EPSG:3857'

app.osm_layer = new ol.layer.Tile
    source: new ol.source.MapQuestOpenAerial()

ol.expr.register 'resolution', ->
    app.map.getView().getView2D().getResolution()

app.view = new ol.View2D
    center: app.center
    zoom: 7

app.map = new ol.Map
    target: 'map'
    layers: [app.osm_layer]
    renderer: ol.RendererHint.CANVAS
    view: app.view

app.classes = 9
app.color_id = 'YlOrRd'
app.colors = colorbrewer[app.color_id][app.classes]

app.dataLayers = [
    new app.models.GeoJSONLayer
        id:'eqs'
        name:'Earthquakes'
        description:'Earthquakes in and around Arizona.'
        namespace:'azgs:earthquakedata'
        service_url:'http://data.usgin.org/arizona/ows'
        active: true
        layerOptions:
            style = new ol.style.Style symbolizers: [
                new ol.style.Shape
                    size: ol.expr.parse 'drawMagSize()'
                    fill: new ol.style.Fill
                        color: ol.expr.parse 'drawColor()'
                        opacity: 0.7
                    stroke: new ol.style.Stroke
                        color: '#ff9900'
                        opacity: 1
            ]
]

app.dataLayerCollection = new app.models.LayerCollection app.dataLayers

app.layers = new app.views.LayerView
    collection: app.dataLayerCollection
app.layers.render()