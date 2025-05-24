import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["map", "modal", "reports", "fireImages", "locationName", "severityLevel", "createdAt", "description", "topDistricts", "areaButton", "areaSelect"];
  static values = {
    reports: Array,
    oldLat: String,
    oldLong: String
  }

  connect() {
    this.initMap();
    this.setupGeolocationHandling();
    this.displayLocations(this.map);
    this.subscribeToReportChannel(this.map);
  }

  initMap() {
    const map = L.map(this.mapTarget, {
      center: [15.2313, 104.8567],
      zoom: 13
    });

    const loadingControl = L.control({ position: 'topright' });
    this.map = map;
    this.loadingControl = loadingControl;

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    this.addLocateCurrentPositionButton(map, loadingControl);
    this.addLoadingLocationMessage(map, loadingControl);
  }

  setupGeolocationHandling() {
    this.map.locate({
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 30000
    });

    this.map.on("locationfound", (e) => {
      this.map.flyTo(e.latlng, 13);
      this.oldLatValue = e.latlng.lat;
      this.oldLongValue = e.latlng.lng;
      this.removeLoadingLocationMessage(this.map, this.loadingControl);
    });

    this.map.on("locationerror", () => {
      this.removeLoadingLocationMessage(this.map, this.loadingControl);
      // TODO: Show error message with more aesthetic way
      console.log("Geolocation permission denied or unavailable.");
    });
  }

  toggleAreaPolygon(event) {
    const button = event.currentTarget;
    const isSelected = button.classList.contains('bg-primary');

    this.resetToggleAreaMenu();

    if (!isSelected) {
      this.selectAreaButton(button);
    } else {
      this.deselectAreaButton();
    }
  }

  selectAreaButton(button) {
    const districtName = button.dataset.district;
    const matchingOption = Array.from(this.areaSelectTarget.options)
      .find(option => option.text.trim() === districtName);

    if (matchingOption) {
      this.areaSelectTarget.value = matchingOption.value;
      this.areaSelectTarget.dispatchEvent(new Event('change'));
    }

    button.classList.remove('bg-white', 'hover:bg-gray-50');
    button.classList.add('bg-primary');
    button.querySelectorAll('p').forEach(p => p.classList.add('text-white'));
  }

  deselectAreaButton() {
    this.areaSelectTarget.value = '';
    this.areaSelectTarget.dispatchEvent(new Event('change'));
  }

  resetToggleAreaMenu() {
    this.areaButtonTargets.forEach(btn => {
      btn.classList.remove('bg-primary', 'text-white');
      btn.classList.add('bg-white', 'hover:bg-gray-50');
      btn.querySelectorAll('p').forEach(p => p.classList.remove('text-white'));
    });
  }

  drawAreaPolygon(event) {
    this.resetToggleAreaMenu();
    this.clearPolygons();

    const selectedOption = event.target.selectedOptions[0];
    if (!selectedOption.value) return;

    const coordinates = JSON.parse(selectedOption.dataset.coordinates);
    if (!coordinates) return;

    this.drawPolygon(coordinates);
  }

  clearPolygons() {
    this.map.eachLayer((layer) => {
      if (layer instanceof L.Polygon) {
        this.map.removeLayer(layer);
      }
    });
  }

  drawPolygon(coordinates) {
    const polygon = L.polygon(coordinates, {
      fillOpacity: 0.08,
      color: '#FF6159',
      weight: 2
    }).addTo(this.map);

    this.map.fitBounds(polygon.getBounds());
  }

  displayLocations(map) {
    if (!this.markerMap) {
      this.markerMap = new Map();
    }

    this.reportsValue.forEach(report => {
      if (this.markerMap.has(report.id)) {
        return;
      }

      const marker = this.createMarker(report, map);
      this.markerMap.set(report.id, marker);
      this.addMarkerEventListeners(marker, report);
    });
  }

  createMarker(report, map) {
    const customIcon = L.icon({
      iconUrl: this.createColoredMarker(report.severity_color),
      iconSize: [32, 37],
      iconAnchor: [16, 37],
      popupAnchor: [0, -28]
    });

    return L.marker([report.lat, report.long], { icon: customIcon }).addTo(map);
  }

  addMarkerEventListeners(marker, report) {
    marker.on('click', () => {
      this.openModal(report);
    });

    marker.on('mouseover', () => {
      marker.bindPopup(report.location_name).openPopup();
      marker.setIcon(this.createLargeIcon(report.severity_color));
    });

    marker.on('mouseout', () => {
      marker.closePopup();
      marker.setIcon(this.createStandardIcon(report.severity_color));
    });
  }

  createLargeIcon(color) {
    return L.icon({
      iconUrl: this.createColoredMarker(color),
      iconSize: [42, 47],
      iconAnchor: [21, 47],
      popupAnchor: [0, -28]
    });
  }

  createStandardIcon(color) {
    return L.icon({
      iconUrl: this.createColoredMarker(color),
      iconSize: [32, 37],
      iconAnchor: [16, 37],
      popupAnchor: [0, -28]
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
    this.renderImages(report.image_urls);
    this.updateModalContent(report);
    this.modalTarget.classList.remove('hidden');
  }

  renderImages(imageUrls) {
    this.fireImagesTarget.innerHTML = "";
    imageUrls.forEach(image => {
      const img = document.createElement('img');
      img.src = image;

      if (imageUrls.length === 1) {
        img.classList.add('w-full', 'h-64', 'object-cover', 'rounded-lg');
      } else {
        img.classList.add('w-96', 'h-64', 'object-cover', 'rounded-lg', 'mr-2');
      }

      this.fireImagesTarget.appendChild(img);
    });
  }

  updateModalContent(report) {
    this.locationNameTarget.innerHTML = report.location_name;
    this.severityLevelTarget.innerHTML = report.severity_level;
    this.createdAtTarget.innerHTML = report.time_ago_message;
    this.descriptionTarget.innerHTML = report.description || "ไม่มีข้อมูล";
  }

  closeModal() {
    this.modalTarget.classList.add('opacity-out-50');
    setTimeout(() => {
      this.modalTarget.classList.remove('opacity-out-50');
      this.modalTarget.classList.add('hidden');
    }, 300);
  }

  createColoredMarker(color) {
    const svgData = `
      <svg width="40" height="46" viewBox="0 0 30 36" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.27344 35.0512C1.092 31.0038 -0.798717 27.1728 0.282262 21.9405C1.08029 18.077 3.69339 14.9336 3.94394 11.0775C5.06018 13.1088 5.52659 14.5736 5.65132 16.6963C9.20151 12.3466 11.5475 6.32517 11.6865 0C11.6865 0 20.9334 5.43323 21.5402 13.6402C22.3362 11.9486 22.7369 9.26193 21.9409 7.5207C24.329 9.26202 38.3067 24.7203 20.0476 35.0512C23.4805 28.367 20.9332 19.3479 14.9728 15.1825C15.3709 16.9736 14.673 23.6538 12.036 26.5892C12.7667 21.6845 11.3409 19.6105 11.3409 19.6105C11.3409 19.6105 10.8515 22.3578 8.95276 25.133C7.2189 27.6673 6.01752 30.357 8.27344 35.0512Z" fill="${color}"/>
      </svg>
    `;

    return `data:image/svg+xml;base64,${btoa(svgData)}`;
  }

  subscribeToReportChannel(map) {
    const consumer = createConsumer();

    this.channel = consumer.subscriptions.create("ReportChannel", {
      received: (data) => {
        this.handleNewReport(data.message, data.top_districts, map);
      }
    });
  }

  handleNewReport(report, topDistricts, map) {
    this.updateTopDistricts(topDistricts);
    this.addNewReport(report, map);
  }

  updateTopDistricts(topDistricts) {
    const districtButtons = topDistricts.map(location => this.createDistrictButton(location));
    this.topDistrictsTarget.innerHTML = districtButtons.join("");
  }

  createDistrictButton(location) {
    return `<button 
        class="flex bg-white rounded-lg px-3 py-1 justify-between text-start hover:bg-gray-50 transition-all cursor-pointer" 
        data-action="click->admin-map#toggleAreaPolygon"
        data-admin-map-target="areaButton"
        data-district="${location.district}">
        <p class="w-[60%] text-gray-600 text-base line-clamp-1">${location.district}</p>
        <p class="text-[#FF392F]">${location.district_count} จุด</p>
    </button>`;
  }

  addNewReport(report, map) {
    this.reportsValue = [...this.reportsValue, report];
    this.displayLocations(map);
  }

  setViewByList(event) {
    event.preventDefault();
    const latValue = event.currentTarget.dataset.lat;
    const longValue = event.currentTarget.dataset.long;

    if (this.oldLatValue === latValue && this.oldLongValue === longValue) {
      return;
    }

    const flyDuration = this.calculateFlyDuration(
      parseFloat(this.oldLatValue || latValue),
      parseFloat(this.oldLongValue || longValue),
      parseFloat(latValue),
      parseFloat(longValue)
    );

    this.oldLatValue = latValue;
    this.oldLongValue = longValue;

    this.map.flyTo([latValue, longValue], 18, {
      animate: true,
      duration: flyDuration
    });
  }

  calculateFlyDuration(oldLat, oldLong, newLat, newLong) {
    const R = 6371;
    const dLat = (newLat - oldLat) * Math.PI / 180;
    const dLon = (newLong - oldLong) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 +
      Math.cos(oldLat * Math.PI / 180) * Math.cos(newLat * Math.PI / 180) *
      Math.sin(dLon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return distance > 100 ? 3 : 1;
  }
}