root = @
if not root.app? then app = root.app = {} else app = root.app
if not app.views? then app.views = views = {} else views = app.views

class app.views.OtherTableView extends Backbone.View
	initialize: () ->
		$(".panel").remove()
		@template = _.template $("#table").html()

	render: () ->
		@$el.append @template
			data: app.selected_data


class app.views.TableView extends Backbone.View
	render: () ->
		key_flag = false
		app.selected_data = []
		app.map.on ['click'], (evt) ->
			app.map.getFeatures
		        pixel: evt.getPixel()
		        layers: [app.dataLayerCollection.models[0].attributes.layer]
		        success: (feature) -> 
		        	capital_keys = []
		        	features = feature[0]
		        	attributes = features[0].getAttributes()
		        	keys = _.keys attributes
		        	capital_keys.push key.charAt(0).toUpperCase() + key.slice(1) for key in keys
		        	values = _.values attributes

		        	if not key_flag
			        	app.selected_data.push capital_keys
			        	key_flag = true

		            #app.selected_data.push features[0].getId()

					app.othertable = new app.views.OtherTableView
					    el: '#chart'
					app.othertable.render()