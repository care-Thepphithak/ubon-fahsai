import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static targets = ["map", "imagesInput", "previewImages"]

  connect() {
    console.log("Report controller is connected");
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

    if (navigator.geolocation) {
      console.log("Geolocation API is available");

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          const customIcon = L.icon({
            iconUrl: customIconUrl, // ใช้ตัวแปรจาก Rails
            iconSize: [20, 30],
            iconAnchor: [10, 0],
            popupAnchor: [0, 0]
          });

          const marker = L.marker(map.getCenter(), { icon: customIcon })
            .addTo(map)
            .bindPopup("You are here!")
            .openPopup();;

          map.on("move", function () {
            marker.setLatLng(map.getCenter());
            console.log("Map center moved to", map.getCenter());
          });
          map.setView([lat, lng], 15);
        }, () => alert("Geolocation permission denied or unavailable.")
      );

    } else {
      alert("Geolocation is not supported by this browser.");
    }

  }

  // Handle images Input
  
}
