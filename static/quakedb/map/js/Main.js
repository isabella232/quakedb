var map;

function init(){
	map = new L.Map("map");
	/* ESRI tiled service example: */
	var natGeoLayer = new L.TileLayer.ESRI("http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer");
	
	/* Build a legendPanel */
	var sidePanel = new L.Control.Panel({
		id: "side-panel",
		width: 400,
		template: new JadeContent("/static/quakedb/map/templates/sidepanel.jade"),
	});
	
	var center = new L.LatLng(34.1618, -111.53332);
	map.setView(center, 7).addLayer(natGeoLayer).addControl(sidePanel);
	
	$.get("earthquakedata.geojson?depth=6", function(response) {
		var jsonLayer = new L.GeoJSON(null, {
			pointToLayer: function(latlng) { return new L.CircleMarker(latlng); },
			popupObj: new JadeContent("/static/quakedb/map/templates/quake.jade")
		});
		jsonLayer.on("featureparse", function(f) {
			f.layer.on("click", function(evt) {
				f.layer._map.openPopup(jsonLayer.options.popupObj.generatePopup(f, { maxWidth: 530, centered: false }));
			});
		});
		for (f in response.features) { jsonLayer.addGeoJSON(response.features[f]); }
		map._quakeLayer = jsonLayer;
		map.addLayer(jsonLayer);
		sidePanel.show({ properties: null });
	});
}