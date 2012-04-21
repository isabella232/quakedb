function filterByDate() {
	var startdate = $('#start-date-input').val();
	var enddate = $('#end-date-input').val();
	$.get("earthquakedata.geojson?daterange=" + startdate + "/" + enddate, function(response) {
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
		if (map._quakeLayer) { map.removeLayer(map._quakeLayer); }
		map._quakeLayer = jsonLayer;
		map.addLayer(jsonLayer);
	});
}