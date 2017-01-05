/*global L, geoff */

window.Route = function (url) {
  this.url = url;
};

window.Route.prototype.display = function (map, fitBounds) {
  var that = this;

  $.ajax(this.url, {
    dataType: "json",
    success: function(data) {
      _.each(data.features, function (feature) {
        if (feature.geometry.type === "LineString") {
          var layer = L.geoJson(feature, { style: that._getLineOptions() });
          layer.addTo(map);
          layer.bringToBack();
          if (fitBounds == true) {
            map.fitBounds(layer.getBounds());
          };
        }
      });
    }
  });
};

window.Route.prototype._getLineOptions = function () {
  return {
    stroke: true,
    color: "rgb(150, 0, 0)",
    weight: 2,
    opacity: 0.5,
    fill: false
  };
};
