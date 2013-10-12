root = @
if not root.app? then app = root.app = {} else app = root.app
if not app.views? then app.views = views = {} else views = app.views

class app.views.LayerView extends Backbone.View
	initialize: (options) ->

	render: () ->
		@collection.forEach (model) ->

	activeLayer: () ->
		for model in @collection.models
			return model if model.get 'active'