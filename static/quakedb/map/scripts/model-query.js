 // Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.models == null ? app.models = app.models = {} : app.models = app.models;

app.models.QueryArea = Backbone.Model.extend({
  defaults: {
  },
  initialize: function () {
  },
  makeQuery: function () {
  	return new L.Draw.Rectangle(app.map).enable();
  },
  getQueryBounds: function (callback) {
  	app.map.on("draw:created", function (query) {
  	  var layer = query.layer,
  	      bounds = layer.getBounds();
  	  callback(bounds);
  	})
  }
});