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

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    map.locate({ setView: true, maxZoom: 13 });

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
}
