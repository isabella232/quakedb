// Create a global object to store all logic in
var root = this;
root.app == null ? app = root.app = {} : app = root.app;

// Make a map
app.map = L.map('map', {
  center: [33.742201427591546, -111.87500043600002],
  zoom: 6,
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
        var color,
	          markerOptions = {
              fillOpacity: 0.8,
              stroke: 0,
            }
        var mag = feature.properties.calculated_magnitude;
        if (0 < mag && mag <= 1) {
          color = "rgb(255,255,204)";
        } else if (1 < mag && mag <= 2) {
          color = "rgb(255,237,160)";
        } else if (2 < mag && mag <= 3) {
          color = "rgb(254,217,118)";
        } else if (3 < mag && mag <= 4) {
          color = "rgb(254,178,76)";
        } else if (4 < mag && mag <= 5) {
          color = "rgb(253,141,60)";
        } else if (5 < mag && mag <= 6) {
          color = "rgb(252,78,42)";
        } else if (6 < mag && mag <= 7) {
          color = "rgb(227,26,28)";
        } else if (7 < mag && mag <= 8) {
          color = "rgb(177,0,38)";
        }

        markerOptions.radius = mag * 5;
        markerOptions.color = markerOptions.fillColor = color;
	      return L.circleMarker(latlng, markerOptions);
	    },
	  }
  }),
  new app.models.GeoJSONLayer({
  	id: "activefaults",
  	layerName: "Active Faults",
  	serviceUrl: "data/activefaults.json",
  	serviceType: "WFS",
  	active: false,
    isExtent: true,
  	layerOptions: {
      style: function (feature) {
        var color,
          lineStyle = {
            weight: 3,
            fillOpacity: 0,
            opacity: 1,
          }
        var symbol = feature.properties.symbol;
        if (symbol == "2.13.2") {
          color = "rgb(37,177,0)";
        } else if (symbol == "2.13.3") {
          color = "rgb(0,36,177)";
        } else if (symbol == "2.13.4") {
          color = "rgb(139,0,177)";
        }

        lineStyle.color = color;
        return lineStyle;
      }
    }
  }),
  new app.models.GeoJSONLayer({
    id: "stations",
    layerName: "Seismo Stations",
    serviceUrl: "data/seismostations.json",
    serviceType: "WFS",
    active: false,
    useMarker: true,
    layerOptions: {
      pointToLayer: function (feature, latlng) {
        var icon = new L.divIcon({
          className: "custom-div-leaflet",
        });
        return L.marker(latlng, {icon: icon});
      }
    }
  })
];

app.dataLayerCollection = new app.models.LayerCollection(data);

app.layers = new app.views.DataLayerView({
  el: $("#dropmenu").first(),
  collection: app.dataLayerCollection,
}).render();

app.content = new app.views.ContentView().render();

app.query = new app.views.QueryView({
  el: $("#query-control").first(),
  model: new app.models.QueryArea(),
}).render();