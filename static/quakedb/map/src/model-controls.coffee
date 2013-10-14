root = @
if not root.app? then app = root.app = {} else app = root.app
if not app.models? then models = app.models = {} else models = app.models

class app.models.ControlModel extends Backbone.Model
	defaults:
		href: 'undefined'
		class_disp: 'undefined'
		class_ol: 'undefined'

	initialize: (options) ->
		@set 'sidebar', @createSidebar options

	createSidebar: (options) ->
		app.sidebarControl = (options) ->
		    options = options || {}

		    anchor = document.createElement 'a'
		    anchor.href = options.href
		    anchor.className = options.class_disp

		    $.side = {}
		    $.sidebar = 2

		    app.sidebar = (panels) ->
		        $.sidebar = panels
		        if panels == 1
		            $('#sidebar').animate
		                right: '-100%'
		        else if panels == 2
		            $('#sidebar').animate
		                right: '0%'
		              
		    toggle = (e) -> 
		        e.preventDefault()
		        if $.sidebar == 2
		            return app.sidebar 1
		        else
		            return app.sidebar 2

		    anchor.addEventListener 'click', toggle, false

		    element = document.createElement 'div'
		    element.className = options.class_ol
		    element.appendChild anchor

		    ol.control.Control.call @,
		        element: element,
		        target: options.target

		ol.inherits app.sidebarControl, ol.control.Control
		app.map.addControl new app.sidebarControl(options)

class app.models.ControlCollection extends Backbone.Collection
	model: app.models.ControlModel
