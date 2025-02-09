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
  }

  initMap = async ()  => {
    const delay = ms => new Promise(res => setTimeout(res, ms));
    await delay(300);

    console.log("Initializing map...");
    const map = L.map('map', {
      center: [15.2313, 104.8567],
      zoom: 13
    });

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    this.locateUser(map);

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
      this.handleLatLongChange(map.getCenter().lat, map.getCenter().lng);
    });

    locationButton.addTo(map);
    console.log("Map initialized.");
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
          map.flyTo([lat, lng], 16);

        }, () => alert("Geolocation permission denied or unavailable.")
      );

    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }
}
