import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["map", "modal", "reports", "fireImages", "locationName", "severityLevel", "createdAt", "description"]
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

    this.displayLocations(map)
    this.subscribeToReportChannel(map);
  }

  displayLocations(map) {
    this.reportsValue.forEach(report => {
      const customIcon = L.icon({
        iconUrl: this.createColoredMarker(report.severity_color),
        iconSize: [32, 37],
        iconAnchor: [16, 37],
        popupAnchor: [0, -28]
      });

      const marker = L.marker([report.lat, report.long], { icon: customIcon }).addTo(map);
      marker.on('click', () => {
        this.openModal(report);
      });
      marker.on('mouseover', () => {
        marker.bindPopup(report.location_name).openPopup();
        marker.setIcon(L.icon({
          iconUrl: this.createColoredMarker(report.severity_color),
          iconSize: [42, 47],
          iconAnchor: [21, 47],
          popupAnchor: [0, -28]
        }));
      });
      marker.on('mouseout', () => {
        marker.closePopup();
        marker.setIcon(L.icon({
          iconUrl: this.createColoredMarker(report.severity_color),
          iconSize: [32, 37],
          iconAnchor: [16, 37],
          popupAnchor: [0, -28]
        }));
      });
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

  openModal(report) {
    // Create images in div (fireImages)
    this.fireImagesTarget.innerHTML = "";
    report.images_urls.forEach(imageKey => {
      const img = document.createElement('img');
      // Build URL via minio proxy endpoint
      img.src = `/minio/${encodeURIComponent(imageKey)}`;
      if (report.images_urls.length === 1) {
        img.classList.add('w-full', 'h-64', 'object-cover', 'rounded-lg');
      } else {
        img.classList.add('w-96', 'h-64', 'object-cover', 'rounded-lg', 'mr-2');
      }
      this.fireImagesTarget.appendChild(img);
    });
  
    this.locationNameTarget.innerHTML = report.location_name;
    this.severityLevelTarget.innerHTML = report.severity_level;
    this.createdAtTarget.innerHTML = report.time_ago_message;
    this.descriptionTarget.innerHTML = report.description;
    this.modalTarget.classList.remove('hidden');
  }

  closeModal() {
    this.modalTarget.classList.add('hidden');
  }

  modifyModalContent(event) { }

  createColoredMarker(color) {
    return `data:image/svg+xml;base64,${btoa(`
      <svg width="40" height="46" viewBox="0 0 30 36" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.27344 35.0512C1.092 31.0038 -0.798717 27.1728 0.282262 21.9405C1.08029 18.077 3.69339 14.9336 3.94394 11.0775C5.06018 13.1088 5.52659 14.5736 5.65132 16.6963C9.20151 12.3466 11.5475 6.32517 11.6865 0C11.6865 0 20.9334 5.43323 21.5402 13.6402C22.3362 11.9486 22.7369 9.26193 21.9409 7.5207C24.329 9.26202 38.3067 24.7203 20.0476 35.0512C23.4805 28.367 20.9332 19.3479 14.9728 15.1825C15.3709 16.9736 14.673 23.6538 12.036 26.5892C12.7667 21.6845 11.3409 19.6105 11.3409 19.6105C11.3409 19.6105 10.8515 22.3578 8.95276 25.133C7.2189 27.6673 6.01752 30.357 8.27344 35.0512Z" fill="${color}"/>
      </svg>
    `)}`;
  }


  subscribeToReportChannel(map) {
    const consumer = createConsumer();

    this.channel = consumer.subscriptions.create("ReportChannel", {
      received: (data) => {
        this.handleNewReport(data.message, map);
      }
    });
  }

  handleNewReport(report, map) {
    const customIcon = L.icon({
      iconUrl: this.createColoredMarker(report.severity_color),
      iconSize: [32, 37],
      iconAnchor: [16, 37],
      popupAnchor: [0, -28]
    });

    const marker = L.marker([report.lat, report.long], { icon: customIcon }).addTo(map);
    marker.on('click', () => {
      this.openModal(report);
    });
  }
}
