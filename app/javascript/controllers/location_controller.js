import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  static targets = ["map", "lat", "long"];

  connect() {
    console.log("Location controller is connected");
    if (!this.mapTarget) {
      console.error("Map element not found.");
      return;
    }

    this.initializzedMap();
  }

  initializzedMap() {
    const map = L.map('map').setView([13.736717, 100.523186], 15);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

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
        this.locateUser(map);
      });

      return div;
    };

    map.on("dragend", () => {
      map.setView(map.getCenter(), map.getZoom());
      this.handleLatLongChange(map.getCenter().lat, map.getCenter().lng);
    });

    locationButton.addTo(map);
    this.locateUser(map);
  }

  handleLatLongChange(lat, long) {
    this.latTarget.value = lat;
    this.longTarget.value = long;
  }

  locateUser(map) {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;

          this.handleLatLongChange(lat, lng);
          map.setView([lat, lng], 15);

        }, () => alert("Geolocation permission denied or unavailable.")
      );

    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }

}
