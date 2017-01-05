window.MapManager = function (id, summit) {
  this.id = id;
  this.routes = [];
  this.summit = summit;
};

window.MapManager.prototype.bootstrap = function () {
  this.map = new L.Map(this.id, { scrollWheelZoom: false, attributionControl: false })
    .addLayer(new L.TileLayer("https://{s}.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=4973182ea707498c9dce9d6504b1f9fe",
      {
        detectRetina: true,
        attribution: "Base map by <a href='http://www.openstreetmap.org/'>OpenStreetMap</a> (<a href='http://www.openstreetmap.org/copyright' title='ODbL'>ODbL</a>)"
      }));
};

window.MapManager.prototype.addRoute = function (route, fitBounds) {
  route.display(this.map, fitBounds);
};

window.MapManager.prototype.centreOnSummit = function (summit) {
  this.map.setView(new L.LatLng(summit[1], summit[0]), 14)
}
