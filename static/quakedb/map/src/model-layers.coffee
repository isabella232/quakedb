root = @
if not root.app? then app = root.app = {} else app = root.app
if not app.models? then models = app.models = {} else models = app.models
if not app.data then data = app.data = {} else data = app.data

class app.models.LayerModel extends Backbone.Model
	defaults:
		id: 'undefined'
		name: 'undefined'
		description: 'undefined'
		service_url: 'undefined'
		namespace: 'undefined'
		active: 'undefined'
		layerOptions: 'undefined'

	initialize: (options) ->
		@set 'layer', @createLayer options

class app.models.GeoJSONLayer extends app.models.LayerModel
	createLayer: (options) ->	
		if options.service_url? and options.namespace?
			callback = @id + 'Data'
			xhr_url = options.service_url
			xhr_url += '?service=WFS&version=1.0.0&request=GetFeature&outputFormat=text/javascript'
			xhr_url += '&typeName=' + options.namespace
			xhr_url += '&format_options=callback:app.data.' + callback

			thisModel = @

			app.data[callback] = (data) ->
				thisData = []
				data.features.forEach (q) ->
					thisData.push Math.abs(q.properties.calculated_magnitude)
				min = Math.min.apply null,thisData
				max = Math.max.apply null,thisData
				scale = d3.scale.linear().domain([min,max]).range(d3.range(app.classes))

				ol.expr.register 'drawMagSize', () ->
				    feature = @
				    magnitude = feature.get 'calculated_magnitude'
				    Math.abs (magnitude+1)*6

				ol.expr.register 'drawColor', () ->
				    feature = @
				    magnitude = feature.get 'calculated_magnitude'
				    app.colors[(scale(magnitude)*8).toFixed()]

				layer = new ol.layer.Vector
					source: new ol.source.Vector
						parser: new ol.parser.GeoJSON()
						data: data
					style: options.layerOptions


				thisModel.set 'layer', layer

				if options.active then app.map.addLayer layer

			$.ajax
				url:xhr_url
				dataType:'jsonp'

class app.models.LayerCollection extends Backbone.Collection
	model: app.models.LayerModel