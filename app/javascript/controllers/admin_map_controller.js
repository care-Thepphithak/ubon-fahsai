import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["map"]
  static values = {
    reports: Array
  }

  connect() {
    const map = L.map(this.mapTarget, {
      center: [15.2313, 104.8567],
      zoom: 13
    });

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    this.addLocateCurrentPositionButton(map);

    map.locate({
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0
    });

    map.on("locationfound", (e) => {
      map.flyTo(e.latlng, 13);
    });

    map.on("locationerror", () => {
      alert("Geolocation permission denied or unavailable.")
    });

    console.log(this.reportsValue)
    this.displayLocations(map)
  }

  displayLocations(map) {
    const customIcon = L.icon({
      iconUrl: customIconUrl,
      iconSize: [32, 37],
      iconAnchor: [16, 37],
      popupAnchor: [0, -28]
    })

    this.reportsValue.forEach(report => {
      L.marker([report.lat, report.long], { icon: customIcon }).addTo(map)
    });
  }

  addLocateCurrentPositionButton(map) {
    const locationButton = L.control({ position: 'bottomright' });

    locationButton.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
      const button = L.DomUtil.create('a', '', div);
      button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
      button.title = 'Show my location';
      button.style.width = '30px';
      button.style.height = '30px';
      button.style.fontSize = '20px';
      button.style.display = 'flex';
      button.style.alignItems = 'center';
      button.style.justifyContent = 'center';

      L.DomEvent.on(button, 'click', (e) => {
        L.DomEvent.preventDefault(e);
        map.locate();
      });

      return div;
    };

    locationButton.addTo(map);
  }
}
