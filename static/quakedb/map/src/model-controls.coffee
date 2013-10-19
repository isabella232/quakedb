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
		@set 'draw', @createDraw options

	createSidebar: (options) ->
		if options.id is 'sidebar'
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


	createDraw: (options) ->
		if options.id is 'draw'
			app.drawControl = (options) ->
				options = options || {}

				anchor = document.createElement 'a'
				anchor.href = options.href
				anchor.className = options.class_disp

				doDraw = () ->
					app.drawing = 'active'
					$ ->
					    $map = $ "#map"
					    $select = $('<div>').addClass 'select-box'

					    $map.on 'mousedown', (e) ->
					        click_y = e.pageY
					        click_x = e.pageX

					        $select.css
					            'top':click_y
					            'left':click_x
					            'width':0
					            'height':0

					        $select.appendTo $map

					        $map.on 'mousemove', (e) ->
					            move_x = e.pageX
					            move_y = e.pageY
					            width = Math.abs move_x - click_x
					            height = Math.abs move_y - click_y

					            new_x = move_x < click_x ? click_x - width : click_x
					            new_y = move_y < click_y ? click_y - height : click_y

					            $select.css
					                'width':width
					                'height':height
					                'top':new_y
					                'left':new_x

					        .on 'mouseup', (e) ->
					            $map.off 'mousemove'
					            $select.remove()

				anchor.addEventListener 'click', doDraw, false
				
				element = document.createElement 'div'
				element.className = options.class_ol
				element.appendChild anchor

				ol.control.Control.call @,
			        element: element,
			        target: options.target

			ol.inherits app.drawControl, ol.control.Control
			app.map.addControl new app.drawControl(options)

class app.models.ControlCollection extends Backbone.Collection
	model: app.models.ControlModel
