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
		app.selected_data = []
		app.map.on ['click'], (evt) ->
			app.map.getFeatures
		        pixel: evt.getPixel()
		        layers: [app.dataLayerCollection.models[0].attributes.layer]
		        success: (feature) -> 
		            features = feature[0]
		            app.selected_data.push features[0].getId()

					app.othertable = new app.views.OtherTableView
					    el: '#chart'
					app.othertable.render()