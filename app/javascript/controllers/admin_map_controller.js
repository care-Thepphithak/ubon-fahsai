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
    const loadingControl = L.control({ position: 'topright' });

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    this.addLocateCurrentPositionButton(map, loadingControl);
    this.addLoadingLocationMessage(map, loadingControl);

    map.locate({
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 30000
    });

    map.on("locationfound", (e) => {
      map.flyTo(e.latlng, 13);
      this.removeLoadingLocationMessage(map, loadingControl);
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

  addLocateCurrentPositionButton(map, loadingControl) {
    const locationButton = L.control({ position: 'bottomright' });

    locationButton.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
      const button = L.DomUtil.create('button', 'bg-white', div);
      button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
      button.title = 'Show my location';
      button.style.width = '30px';
      button.style.height = '30px';
      button.style.fontSize = '20px';
      button.style.display = 'flex';
      button.style.alignItems = 'center';
      button.style.justifyContent = 'center';

      L.DomEvent.on(button, 'click', (e) => {
        this.addLoadingLocationMessage(map, loadingControl);
        L.DomEvent.preventDefault(e);
        map.locate();
      });

      return div;
    };

    locationButton.addTo(map);
  }

  addLoadingLocationMessage(map, loadingControl) {
    loadingControl.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control bg-white px-3 py-2 rounded-lg shadow-md');
      div.innerHTML = `
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-700">กำลังหาตำแหน่ง...</span>
            <i class="fa-solid fa-circle-notch fa-spin"></i>
          </div>
        `;
      return div;
    };

    loadingControl.addTo(map);
  }

  removeLoadingLocationMessage(map, loadingControl) {
    map.removeControl(loadingControl);
  }
}
