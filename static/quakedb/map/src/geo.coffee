root = @
if not root.app? then app = root.app = {} else app = root.app

app.drawmap = (collection) ->

    app.scaled_data = []
    app.date_data = []
    collection.features.forEach (d) ->
        app.scaled_data.push(Math.abs(d.properties.calculated_magnitude))
        
        date = d.properties.date
        date2 = date.split('T')
        date3 = date2[0].split('-')
        date4 = date3[0] + date3[1] + date3[2]
        app.date_data.push Math.abs(date4)


    app.min_mag = d3.min(app.scaled_data)
    app.max_mag = d3.max(app.scaled_data)
    
    app.min_date = d3.min(app.date_data)
    app.max_date = d3.max(app.date_data)
    
    app.get_small = () ->
        app.map.g.selectAll('circle')
            .style('stroke-width', 1)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease('linear')
            .duration(1000)
            .attr("r", 5)
    
    app.get_big = () ->
        app.map.g.selectAll('circle')
            .style('stroke-width', 1)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease('linear')
            .duration(1000)
            .attr("r", (d) -> Math.abs(d.properties.calculated_magnitude*4))

    setInterval = () ->
        circle = d3.select(@)
        repeat = () ->
            circle = circle.transition()
            .ease('linear')
            .attr('rx', 9)
            .attr('ry', 9)
            .transition()
            .attr('rx', 2.5)
            .attr('ry', 2.5)
            .each('start', repeat)
        repeat()
    
    app.mag_g.attr('id', 'blow-up-mag-symbol')
        .append('ellipse')
        .attr('cx', 10)
        .attr('cy', 10)
        .attr('rx', 2.5)
        .attr('ry', 2.5)
        .style('fill', 'black')
        .transition()
        .duration(2000)
        .each(setInterval)

    $.mag_cnt = {}
    $.mag_cnt.size = 1
    
    mag_size = (count) ->
        $.mag_cnt.size = count
        if count == 1
            console.log '1'
            app.get_small()
        else if count == 2
            console.log '2'
            app.get_big()
        console.log count
        
    $('.magnitude-style-control').click () ->
        if $.mag_cnt.size == 1
            console.log $.mag_cnt.size
            return mag_size(2)
        else
            return mag_size(1)
            console.log $.mag_cnt.size

    app.reset = () ->
        if $.mag_cnt.size == 1
            app.bottomLeft = app.project(app.bounds[0])
            app.topRight = app.project(app.bounds[1])
        
            app.map.svg.attr('width', app.topRight[0] - app.bottomLeft[0])
                   .attr('height', app.bottomLeft[1] - app.topRight[1])
                   .style('margin-left', app.bottomLeft[0] + 'px')
                   .style('margin-top', app.topRight[1] + 'px')
        
            app.map.g.attr('transform', 'translate(' + -app.bottomLeft[0] + ',' + -app.topRight[1] + ')')
    
            app.feature.attr("cx",(d) -> return app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
                       .attr("cy",(d) -> return app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
                       .attr("r", 5)
    
            app.feature.attr 'd', app.path
        
        else if $.mag_cnt.size == 2
            app.bottomLeft = app.project(app.bounds[0])
            app.topRight = app.project(app.bounds[1])
        
            app.map.svg.attr('width', app.topRight[0] - app.bottomLeft[0])
                   .attr('height', app.bottomLeft[1] - app.topRight[1])
                   .style('margin-left', app.bottomLeft[0] + 'px')
                   .style('margin-top', app.topRight[1] + 'px')
        
            app.map.g.attr('transform', 'translate(' + -app.bottomLeft[0] + ',' + -app.topRight[1] + ')')
    
            app.feature.attr("cx",(d) -> return app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
                       .attr("cy",(d) -> return app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
                       .attr("r", (d) -> Math.abs(d.properties.calculated_magnitude*4))
    
            app.feature.attr 'd', app.path

    app.project = (x) ->
        app.point = app.map.latLngToLayerPoint(new L.LatLng(x[1], x[0]))
        return [app.point.x, app.point.y]

    app.setInterval = () ->
        d3.select(@)
            .style('stroke-width', 3)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease("linear-in")
            .duration(1)
            .attr("r", 20)
    
    app.outInterval = () ->
        d3.select(@)
            .style('stroke-width', 1)
            .style('stroke', app.scheme[app.classes - 1])
            .transition()
            .ease('linear-out')
            .duration(1)
            .attr("r", 5)

    app.bounds = app.bbox_array
    app.path = d3.geo.path().projection app.project

    app.scale = d3.scale.linear()
        .domain([app.min_mag, app.max_mag])
        .range(d3.range(app.classes))

    app.feature = app.map.g.selectAll('circle')
        .data(collection.features)
        .enter().append('svg:circle')
        .attr('cx', (d) -> app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0] )
        .attr('cy', (d) -> app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1] )
        .style('fill', (d) -> app.scheme[(app.scale(d.properties.calculated_magnitude) * 8).toFixed()])
        .style('stroke', app.scheme[app.classes - 1])
        .style('opacity', 0.5)
        .attr('r', (d) -> Math.abs(d.properties.calculated_magnitude*4))
#        .on('mouseover', app.setInterval)
#        .on('mouseout', outInterval)
        
    app.map.on 'viewreset', app.reset
    app.reset()
    
    get_mag = (d) -> return d.properties.calculated_magnitude
    
    app.mag_filter = (min,max) ->
        minv = min
        maxv = max
        d3.selectAll("circle").classed("selected", (d) -> return maxv >= get_mag(d) && get_mag(d) >= minv)
        selected = d3.selectAll(".selected")
        d3.selectAll("circle").style("display", "none")
        selected.style("display", "block")
    
    get_date = (d) ->
        date = d.properties.date
        date2 = date.split('T')
        date3 = date2[0].split('-')
        date4 = date3[0] + date3[1] + date3[2]
        return Math.abs(date4)

    app.date_filter = (min, max) ->
        minv = min
        maxv = max
        d3.selectAll("circle").classed("selected", (d) -> return maxv >= get_date(d) && get_date(d) >= minv)
        selected = d3.selectAll(".selected")
        d3.selectAll("circle").style("display", "none")
        selected.style("display", "block")

app.drawseismo = (collection) ->
    app.project = (x) ->
        app.point = app.map.latLngToLayerPoint(new L.LatLng(x[1], x[0]))
        return [app.point.x, app.point.y]
    
    app.path = d3.geo.path().projection app.project
    
    app.feature = app.map.g.selectAll('path')
        .data(collection.features)
        .enter().append('path')
        .attr('transform', (d) -> 'translate(' + (app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[0]) + ',' + (app.project([d.geometry.coordinates[0], d.geometry.coordinates[1]])[1]) + ')')
        .attr('d', d3.svg.symbol().type('diamond').size(75))
        .style('stroke', 'purple')
        .style('stroke-width', 2)
        .style('fill-opacity', 0)
