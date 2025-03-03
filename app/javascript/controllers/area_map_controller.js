import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    static targets = ["map"]
  
    connect() {
      const map = L.map(this.mapTarget, {
        center: [15.2313, 104.8567],
        zoom: 13
      });
      const loadingControl = L.control({ position: 'topright' });
      this.map = map;
  
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
        this.oldLatValue = e.latlng.lat;
        this.oldLongValue = e.latlng.lng;
        this.removeLoadingLocationMessage(map, loadingControl);
      });
  
      map.on("locationerror", () => {
        this.removeLoadingLocationMessage(map, loadingControl);
        console.log("Geolocation permission denied or unavailable.");
      });
  
      
    }
    
}