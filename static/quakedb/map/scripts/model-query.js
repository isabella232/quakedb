 // Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;
app.models == null ? app.models = app.models = {} : app.models = app.models;

app.models.QueryArea = Backbone.Model.extend({
  defaults: {

  },
  initialize: function () {
  	
  }
})