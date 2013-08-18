root = @
if not root.app? then app = root.app = {} else app = root.app

xhr_url = "http://data.usgin.org/arizona/ows?service=WFS&version=1.0.0&request=GetFeature&outputFormat=text/javascript&typeName=azgs:earthquakedata&outputformat=json"

app.osm_aerial = new L.TileLayer 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'

app.map = new L.Map 'map',
    center: [33.867990, -111.985034]
    zoom: 7

app.map.addLayer app.osm_aerial

app.svg = d3.select(app.map.getPanes().overlayPane).append 'svg'
app.g = app.svg.append('g').attr 'class', 'leaflet-zoom-hide'

d3.json xhr_url, (error, collection) ->
    console.log collection.features
    reset = () ->
        app.bottomLeft = project(app.bounds[0])
        app.topRight = project(app.bounds[1])
    
        app.svg.attr('width', app.topRight[0] - app.bottomLeft[0])
               .attr('height', app.bottomLeft[1] - app.topRight[1])
               .style('margin-left', app.bottomLeft[0] + 'px')
               .style('margin-top', app.topRight[1] + 'px')
    
        app.g.attr('transform', 'translate(' + -app.bottomLeft[0] + ',' + -app.topRight[1] + ')')
        
        app.feature.attr 'd', app.path

    project = (x) ->
        app.point = app.map.latLngToLayerPoint(new L.LatLng(x[1], x[0]))
        return [app.point.x, app.point.y]

    app.bounds = d3.geo.bounds collection
    console.log app.bounds
    app.path = d3.geo.path().projection project
    
    app.feature = app.g.selectAll('path')
        .data(collection.features)
        .enter().append('path')
        .attr('cx', (d) -> project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
        .attr('cy', (d) -> project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
        .attr('r', (d) -> if (d.properties.calculated_magnitude > 5) then return 20)
        .style('fill', (d) -> if (d.properties.calculated_magnitude > 5) then return 'red' else 'blue')
        .style('stroke', 'red')
        
    app.map.on 'viewreset', reset
    reset()

"""
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
"""