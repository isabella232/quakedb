root = @
if not root.app? then app = root.app = {} else app = root.app

xhr_url = "http://data.usgin.org/arizona/ows?service=WFS&version=1.0.0&request=GetFeature&outputFormat=text/javascript&typeName=azgs:earthquakedata&outputformat=json"

app.dict = []

app.classes = 9
app.scheme_id = "YlOrRd"
app.scheme = colorbrewer[app.scheme_id][app.classes]

app.esri_aerial = new L.TileLayer 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'

app.map = new L.Map 'map',
    center: [33.867990, -111.985034]
    zoom: 7

app.map.addLayer app.esri_aerial

sidebarControl = L.Control.extend
    options:
        position: 'topleft'
    onAdd: (map) ->
        container = L.DomUtil.create('div','my-custom-control')
        container.title = 'Show me the money!'
        $(container).addClass 'glyphicon glyphicon-indent-right'
        return container
app.map.addControl(new sidebarControl())

magnitudeControl = L.Control.extend
    options:
        position: 'bottomleft'
    onAdd: (map) ->
        container = L.DomUtil.create('div', 'eq-magnitude-control')
        $(container).append '<div id="data-slider-eq-magnitude"></div>'
        return container
app.map.addControl(new magnitudeControl())

app.bbox_string = app.map.getBounds().toBBoxString()
app.bbox = app.bbox_string.split(',')
app.bbox_array = [[app.bbox[0],app.bbox[1]],[app.bbox[2],app.bbox[3]]]

app.svg = d3.select(app.map.getPanes().overlayPane).append 'svg'
app.g = app.svg.append('g').attr 'class', 'leaflet-zoom-hide'




app.graph_margin = {top:20, right:20, bottom:30, left:40}
app.graph_width = 450#960 - app.graph_margin.left - app.graph_margin.right
app.graph_height = 400#500 - app.graph_margin.top - app.graph_margin.bottom

app.graph_x = d3.scale.linear()
    .range([0, app.graph_width])
app.graph_y = d3.scale.linear()
    .range([app.graph_height, 0])
app.graph_x_axis = d3.svg.axis()
    .scale(app.graph_x)
    .orient('bottom')
app.graph_y_axis = d3.svg.axis()
    .scale(app.graph_y)
    .orient('left')

app.graph_svg = d3.select("#sidebar").append("svg")
    .attr("width", app.graph_width + app.graph_margin.left + app.graph_margin.right)
    .attr("height", app.graph_height + app.graph_margin.top + app.graph_margin.bottom)
    .append("g")
    .attr("transform", "translate(" + app.graph_margin.left + "," + app.graph_margin.top + ")")




d3.json xhr_url, (error, collection) ->




    app.graph_x.domain(d3.extent(collection.features, (d) -> return d.properties.calculated_magnitude) ).nice()
    app.graph_y.domain(d3.extent(collection.features, (d) -> return d.properties.depth )).nice()

    app.graph_svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + app.graph_height + ")")
        .call(app.graph_x_axis)
        .style("fill", "white")
        .append("text")
        .attr("class", "label")
        .attr("x", app.graph_width)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("Magnitude")
    
    app.graph_svg.append("g")
        .attr("class", "y axis")
        .call(app.graph_y_axis)
        .style("fill", "white")
        .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Depth")
    
    app.graph_svg.selectAll(".dot")
        .data(collection.features)
        .enter().append("circle")
        .attr("class", "dot")
        .attr("r", 3.5)
        .attr("cx", (d) -> return app.graph_x(d.properties.calculated_magnitude) )
        .attr("cy", (d) -> return app.graph_y(d.properties.depth) )
        .style("fill", "white")
        .style("opacity", 1)






    
    app.scaled_data = []
    collection.features.forEach (d) ->
        app.scaled_data.push(Math.abs(d.properties.calculated_magnitude))
    
    app.min_mag = d3.min(app.scaled_data)
    app.max_mag = d3.max(app.scaled_data)
    
    reset = () ->
        app.bottomLeft = project(app.bounds[0])
        app.topRight = project(app.bounds[1])
    
        app.svg.attr('width', app.topRight[0] - app.bottomLeft[0])
               .attr('height', app.bottomLeft[1] - app.topRight[1])
               .style('margin-left', app.bottomLeft[0] + 'px')
               .style('margin-top', app.topRight[1] + 'px')
    
        app.g.attr('transform', 'translate(' + -app.bottomLeft[0] + ',' + -app.topRight[1] + ')')

        app.feature.attr("cx",(d) -> return project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
                   .attr("cy",(d) -> return project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
#                   .attr("r",  (d) -> d.properties.calculated_magnitude*4)

        app.feature.attr 'd', app.path

    project = (x) ->
        app.point = app.map.latLngToLayerPoint(new L.LatLng(x[1], x[0]))
        return [app.point.x, app.point.y]

    setInterval = () ->
        d3.select(@)
            .style('stroke-width', 3)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease("linear-in")
            .duration(1)
            .attr("r", 20)
            
    outInterval = () ->
        d3.select(@)
            .style('stroke-width', 1)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease('linear-out')
            .duration(1)
            .attr("r", 5)

    app.bounds = app.bbox_array
    app.path = d3.geo.path().projection project

    console.log d3.range(app.classes)
    
    app.scale = d3.scale.linear()
        .domain([app.min_mag, app.max_mag])
        .range(d3.range(app.classes))

    app.feature = app.g.selectAll('circle')
        .data(collection.features)
        .enter().append('svg:circle')
        .attr('cx', (d) -> project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
        .attr('cy', (d) -> project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
        .attr('r', 5)
        .style('fill', (d) -> app.scheme[(app.scale(d.properties.calculated_magnitude) * 8).toFixed()])
        .style('stroke', app.scheme[app.classes - 1])
#        .attr('r', (d) -> d.properties.calculated_magnitude*4)
        .on('mouseover', setInterval)
        .on('mouseout', outInterval)
        
    app.map.on 'viewreset', reset
    reset()


    
    
    
$.asm = {};
$.asm.panels = 1;

sidebar = (panels) ->
    $.asm.panels = panels
    if panels == 1
        $('#sidebar').animate
            right:"-100%"
    else if panels == 2
        $('#sidebar').animate
            right:"0%"
    $('#sidebar').height($(window).height());

$('.my-custom-control').click () ->
    if $.asm.panels == 1
        return sidebar(2)
    else
        return sidebar(1)

myslide = $(() ->
    $('#data-slider-eq-magnitude').slider
        range:true
        min:0
        max:8
        values:[5,7.5]
        step:0.5
)