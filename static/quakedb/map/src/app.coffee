root = @
if not root.app? then app = root.app = {} else app = root.app

app.center = ol.proj.transform [-108.81034, 33.857990], 'EPSG:4326', 'EPSG:3857'

app.osm_layer = new ol.layer.Tile
    source: new ol.source.XYZ
        url: 'http://server.arcgisonline.com/ArcGIS/rest/services/' + 
            'World_Imagery/MapServer/tile/{z}/{y}/{x}'

ol.expr.register 'resolution', ->
    app.map.getView().getView2D().getResolution()

app.view = new ol.View2D
    center: app.center
    zoom: 7

$.side = {}
$.side.bar = 2

app.sidebar = (panels) ->
    $.side.bar = panels
    if panels == 1
        $('#sidebar').animate
            right: '-100%'
    else if panels == 2
        $('#sidebar').animate
            right: '0%'

app.sidebarControl = (options) -> 
  options = options || {}

  anchor = document.createElement('a')
  anchor.href = '#sidebar-control'
  anchor.className = 'glyphicon glyphicon-indent-right'
  
  handleRotateNorth = (e) -> 
    e.preventDefault()
    if $.side.bar == 2
        return app.sidebar(1)
    else
        return app.sidebar(2)

  anchor.addEventListener 'click', handleRotateNorth, false

  element = document.createElement 'div'
  element.className = 'sidebar-control ol-unselectable'
  element.appendChild anchor

  ol.control.Control.call(@, {
    element: element,
    target: options.target
  });

ol.inherits(app.sidebarControl, ol.control.Control);

app.map = new ol.Map
    controls: ol.control.defaults().extend([
        new app.sidebarControl()
    ])
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
                        color: ol.expr.parse 'drawFill()'
                        opacity: 0.7
            ]
]

app.dataLayerCollection = new app.models.LayerCollection app.dataLayers

app.layers = new app.views.LayerView
    collection: app.dataLayerCollection
app.layers.render()