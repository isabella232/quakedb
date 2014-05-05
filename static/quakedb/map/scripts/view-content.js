 // Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.views == null ? app.views = app.views = {} : app.views = app.views;

app.views.ContentView = Backbone.View.extend({
  initialize: function (options) {
  	var view = this,
  	    controlEl = $("#content-control");
  	controlEl.click(function () {
  	  view.toggleContent(controlEl);
  	})
  },
  toggleContent: function (control) {
  	var contentTab = $("#content-tab");
  	if (contentTab.hasClass("hide-tab")) {
  	  contentTab.removeClass("hide-tab");
  	  contentTab.addClass("show-tab");
  	} else {
  	  contentTab.removeClass("show-tab");
  	  contentTab.addClass("hide-tab");
  	}
  }
});