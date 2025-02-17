import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-map"
export default class extends Controller {
  static targets = ["map"]

  connect() {
    const map = L.map(this.mapTarget, {
      center: [15.2313, 104.8567],
      zoom: 13
    });

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);
  }
}
