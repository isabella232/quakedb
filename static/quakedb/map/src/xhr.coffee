root = @
if not root.app? then app = root.app = {} else app = root.app

#d3.json app.seismo_url, (error, collection) ->
#    app.drawseismo(collection)

d3.json app.eq_url, (error, collection) ->

    app.drawgraph(collection)
    app.drawmap(collection)

    eq_magnitude_slider = $ () ->
        $('#data-slider-eq-magnitude').slider
            range:true
            min:app.min_mag
            max:app.max_mag
            values:[4.5, 7.5]
            step:0.5
            slide: (event, ui) ->
                minv = ui.values[0]
                maxv = ui.values[1]
                app.mag_filter(minv,maxv)
        
    date_slider = $ () ->
        $('#data-slider-date').slider
            range: true
            min:app.min_date
            max:app.max_date
            step:1
            slide: (event, ui) ->
                minv = ui.values[0]
                maxv = ui.values[1]
                app.date_filter(minv,maxv)