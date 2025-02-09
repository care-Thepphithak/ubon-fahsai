import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  static targets = ["map", "lat", "long"];

  connect() {
    console.log("Location controller is connected");
    if (!this.mapTarget) {
      console.error("No map element found in the DOM");
      return;
    }
    console.log("Map element found in the DOM");
    this.initializzedMap();
  }

  initializzedMap() {
    const map = L.map('map').setView([13.736717, 100.523186], 13); // ค่าเริ่มต้น (กรุงเทพฯ)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    const customIcon = L.icon({
      // TODO: Find a better way to load the icon, currently it is loaded by line: 26 in application.html.erb
      iconUrl: customIconUrl,
      iconSize: [20, 30],
      iconAnchor: [10, 0],
      popupAnchor: [0, 0]
    });

    // Add custom location control
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
        this.locateUser(map, marker);
      });

      return div;
    };

    map.on("dragend", () => {
      console.log("on dragend called");

      let newLatLng = map.getCenter();

      setTimeout(() => {
        marker.setLatLng(newLatLng);
        map.setView([newLatLng.lat, newLatLng.lng], 15);
      }, 150);

      this.handleLatLongChange(newLatLng.lat, newLatLng.lng);
      console.log("Map center moved to", newLatLng);
    });

    locationButton.addTo(map);
    this.locateUser(map, marker);
  }

  handleLatLongChange(lat, long) {
    this.latTarget.value = lat;
    this.longTarget.value = long;
  }

  locateUser(map, marker) {
    if (navigator.geolocation) {
      console.log("Geolocation API is available");

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;

          this.handleLatLongChange(lat, lng);
          marker.setLatLng([lat, lng]);
          map.setView([lat, lng], 15);

        }, () => alert("Geolocation permission denied or unavailable.")
      );

    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }

}
