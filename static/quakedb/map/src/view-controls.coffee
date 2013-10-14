root = @
if not root.app? then app = root.app = {} else app = root.app
if not app.views? then app.views = views = {} else views = app.views

class app.views.ControlView extends Backbone.View
	intialize: (options) ->

	render: () ->
		@collection.forEach (model) ->