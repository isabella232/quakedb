// Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;

// Make a map
app.map = L.map('map', {
  center: [35.024994, -111.820046],
  zoom: 7,
});

// Instantiate basemap model/view
app.baseMapView = new app.views.BaseMapView({
  model: new app.models.TileLayer({
    id: 'osm-basemap',
    serviceUrl: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    serviceType: 'WMS',
    active: true,
    detectRetina: true,
  })
}).render();

data = [
  new app.models.GeoJSONLayer({
  	id: "earthquakes",
  	layerName: "Earthquake Epicenters",
  	serviceUrl: "data/earthquakes.json",
  	serviceType: "WFS",
  	active: true,
  	layerOptions: {
	  pointToLayer: function (feature, latlng) {
	    markerOptions = {
	  	  radius: 10,
	  	  fillColor: "red",
	  	  color: "orange",
	  	};
	    return L.circleMarker(latlng, markerOptions);
	  },
	}
  }),
  new app.models.GeoJSONLayer({
  	id: "activefaults",
  	layerName: "Active Faults",
  	serviceUrl: "data/activefaults.json",
  	serviceType: "WFS",
  	active: true,
  	layerOptions: {}
  }),
  new app.models.GeoJSONLayer({
    id: "stations",
    layerName: "Seismo Stations",
    serviceUrl: "data/seismostations.json",
    serviceType: "WFS",
    active: true,
    layerOptions: {}
  })
];

app.dataLayerCollection = new app.models.LayerCollection(data);

app.layers = new app.views.dataLayerView({
  collection: app.dataLayerCollection,
}).render();