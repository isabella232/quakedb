// Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.views == null ? app.views = app.views = {} : app.views = app.views;

// Render the basemap
app.views.BaseMapView = Backbone.View.extend({
  initialize: function (options) {
  	active = this.findActiveModel();
  	app.map.addLayer(active.get('layer'));
  },
  render: function () {},
  findActiveModel: function () {
  	if (this.model.get('active')) return this.model;
  }
});

app.views.dataLayerView = Backbone.View.extend({
  initialize: function (options) {
  	this.findActiveLayers();
  },
  render: function () {},
  findActiveLayers: function () {
    this.collection.each(function (model) {
      if (model.get("active")) {
      	setTimeout(function () {app.map.addLayer(model.get("layer"));}, 3000);
      }
    })
  }
});