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
  	if (contentTab.hasClass("hidden")) {
  	  contentTab.removeClass("hidden");
  	  contentTab.addClass("shown");
  	} else {
  	  contentTab.removeClass("shown");
  	  contentTab.addClass("hidden");
  	}
  }
});