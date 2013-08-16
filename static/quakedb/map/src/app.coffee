root = @
if not root.app? then app = root.app = {} else app = root.app

xhr_url = "http://data.usgin.org/arizona/ows?service=WFS&version=1.0.0&request=GetFeature&outputFormat=text/javascript&typeName=azgs:earthquakedata&outputformat=json"

app.center = ol.proj.transform [-112.085034, 34.267990], 'EPSG:4326', 'EPSG:3857'

app.osm_layer = new ol.layer.TileLayer
    source: new ol.source.MapQuestOpenAerial()

ol.expr.register 'resolution', ->
    app.map.getView().getView2D().getResolution()

app.quakes_layer = new ol.layer.Vector
    source: new ol.source.Vector
        parser: new ol.parser.GeoJSON()
        url: xhr_url
    style: new ol.style.Style rules: [
        new ol.style.Rule
            symbolizers: [
                new ol.style.Shape
                    size: 20
                    strokeColor: '#FFFF00'
                    strokeOpacity: 1
                    fillColor: '#FF0000'
                    fillOpacity: 0.6
            ]]

app.view = new ol.View2D
    center: app.center
    zoom: 7

app.map = new ol.Map
    target: 'map'
    layers: [app.osm_layer, app.quakes_layer]
    renderer: ol.RendererHint.CANVAS
    view: app.view


app.margin = {top:20, right:20, bottom:30, left:40}
app.width = 960 - app.margin.left - app.margin.right
app.height = 500 - app.margin.top - app.margin.bottom

app.x = d3.scale.linear()
    .range([0, app.width])
app.y = d3.scale.linear()
    .range([app.height, 0])
app.x_axis = d3.svg.axis()
    .scale(app.x)
    .orient('bottom')
app.y_axis = d3.svg.axis()
    .scale(app.y)
    .orient('left')

app.svg = d3.select("body").append("svg")
    .attr("width", app.width + app.margin.left + app.margin.right)
    .attr("height", app.height + app.margin.top + app.margin.bottom)
    .append("g")
    .attr("transform", "translate(" + app.margin.left + "," + app.margin.top + ")")

d3.json xhr_url, (error, collection) ->
    app.x.domain(d3.extent(collection.features, (d) -> return d.properties.calculated_magnitude) ).nice()
    app.y.domain(d3.extent(collection.features, (d) -> return d.properties.depth )).nice()

    app.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + app.height + ")")
        .call(app.x_axis)
        .append("text")
        .attr("class", "label")
        .attr("x", app.width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("Magnitude")
    
    app.svg.append("g")
        .attr("class", "y axis")
        .call(app.y_axis)
        .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Depth")
    
    app.svg.selectAll(".dot")
        .data(collection.features)
        .enter().append("circle")
        .attr("class", "dot")
        .attr("r", 3.5)
        .attr("cx", (d) -> return app.x(d.properties.calculated_magnitude) )
        .attr("cy", (d) -> return app.y(d.properties.depth) )
        .style("fill", "#000")
