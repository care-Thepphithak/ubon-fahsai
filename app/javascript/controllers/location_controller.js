import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  static targets = ["map", "lat", "long", "locationName"];


  connect() {
    console.log("Location controller is connected");
    if (!this.mapTarget) {
      console.error("Map element not found.");
      return;
    }
  }

  initMap = async () => {
    // Check if map is already initialized
    if (this.mapTarget._leaflet_id) {
      console.log("Map already initialized.");
      return;
    }

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
      document.getElementById('location-name').innerHTML = "กำลังหาตำแหน่ง...";
      this.handleLatLongChange(map.getCenter().lat, map.getCenter().lng);

    });

    locationButton.addTo(map);
    console.log("Map initialized.");
  }

  async handleLatLongChange(lat, long) {
    this.latTarget.value = lat;
    this.longTarget.value = long;

    this.disableConfirmButton();

    const locationName = await this.getLocationName(lat, long);
    document.getElementById('location-name').innerHTML = locationName;
    this.locationNameTarget.value = locationName;

    this.enableConfirmButton();
  }

  enableConfirmButton() {
    const confirmButton = document.getElementById('confirm');

    if (confirmButton) {
      confirmButton.removeAttribute('disabled');
      confirmButton.classList.remove('bg-gray-200', 'cursor-not-allowed');
      confirmButton.classList.add('hover:bg-[#FF6C64]');
    }
  }

  disableConfirmButton() {
    const confirmButton = document.getElementById('confirm');

    if (confirmButton) {
      confirmButton.setAttribute('disabled', 'true');
      confirmButton.classList.add('bg-gray-200', 'cursor-not-allowed');
      confirmButton.classList.remove('hover:bg-[#FF6C64]');

    }
  }

  async getLocationName(lat, lng) {
    try {
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`);
      const data = await response.json();

      let locationString = data.display_name || "";

      locationString = locationString
        .replace(/, /g, " ")
        .replace(/ประเทศไทย/g, "")
        .replace(/\d{5}/g, "")
        .trim();

      return locationString || "ไม่พบข้อมูลตำแหน่ง";
    } catch (error) {
      console.error("Error fetching location name:", error);
      return "ไม่พบข้อมูลตำแหน่ง";
    }
  }

  locateUser(map) {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by this browser.");
      return;
    }
    const loadingControl = L.control({ position: 'topright' });

    loadingControl.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control bg-white px-3 py-2 rounded-lg shadow-md');
      div.innerHTML = `
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-700">Getting location...</span>
            <i class="fa-solid fa-circle-notch fa-spin"></i>
          </div>
        `;
      return div;
    };

    loadingControl.addTo(map);

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;

        this.handleLatLongChange(lat, lng);
        map.flyTo([lat, lng], 16);
        map.removeControl(loadingControl);

      }, () => {
        map.removeControl(loadingControl);
        alert("Geolocation permission denied or unavailable.")
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 30000
      }
    );
  }
}
