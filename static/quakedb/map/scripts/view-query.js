// Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.views == null ? app.views = app.views = {} : app.views = app.views;

app.views.QueryView = Backbone.View.extend({
  initialize: function () {
  },
  events: {
    "click": "drawQuery"
  },
  drawQuery: function () {
  	var model = this.model;
    model.makeQuery();
    
  },
  makeQuery: function () {
    this.makeQuery(function () {
      model.getBounds(function (featureGroup) {
        var layers = featureGroup.getLayers();
        console.log(layers);
      })
    })
  }
})