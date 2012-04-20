function init(){
	var map = new L.Map("map");
	/* ESRI tiled service example: */
	var natGeoLayer = new L.TileLayer.ESRI("http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer");
	
	var center = new L.LatLng(34.1618, -111.53332);
	map.setView(center, 7).addLayer(natGeoLayer);
	
	$.get("earthquakedata.geojson", function(response) {
		var jsonLayer = new L.GeoJSON(null, {
			pointToLayer: function(latlng) { return new L.CircleMarker(latlng); }		
		});
		for (f in response.features) { jsonLayer.addGeoJSON(response.features[f]); }
		map.addLayer(jsonLayer);
	})
}