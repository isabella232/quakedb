// Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.views == null ? app.views = app.views = {} : app.views = app.views;

// Render the basemap
app.views.BaseMapView = Backbone.View.extend({
  initialize: function (options) {
  	var active = this.findActiveModel();
  	app.map.addLayer(active.get('layer'));
  },
  findActiveModel: function () {
  	if (this.model.get('active')) return this.model;
  }
});

app.views.dataLayerView = Backbone.View.extend({
  initialize: function (options) {
    this.addDataToLayer();
    this.findActiveLayers();
  },
  findActiveLayers: function () {
    this.collection.each(function (model) {
      if (model.get("active")) model.get("layer").addTo(app.map);
    });
  },
  addDataToLayer: function () {
    this.collection.each(function (model) {
      var layer = model.get("layer");
      model.getJSON(function (data) {
        layer.addData(data);
      })     
    })
  }
});