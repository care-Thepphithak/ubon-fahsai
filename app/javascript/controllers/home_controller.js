import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currentLocation", "nearestDistance", "reports", "tag", "distance"];
  static values = {
    reports: Array
  }

  async connect() {
    this.getCurrentLocation();
    this.renderTags();
  }

  getCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        this.showCurrentLocation.bind(this),
        this.showError.bind(this)
      );
    } else {
      this.currentLocationTarget.innerHTML =
        "Geolocation is not supported by this browser.";
    }
  }

  async showCurrentLocation(position) {
    const lat = position.coords.latitude;
    const long = position.coords.longitude;
    const locationName = await this.getLocationName(lat, long);
    this.currentLocationTarget.innerHTML = locationName;

    const nearestDistance = this.calculateNearestDistance(lat, long, this.reportsValue);
    this.nearestDistanceTarget.innerHTML = `${nearestDistance.toFixed(2)}`;
  
    // Remove the specified classes
    this.nearestDistanceTarget.classList.remove('min-h-[40px]', 'animate-pulse', 'bg-gray-300', 'rounded-md');
  

    this.updateReportDistances(lat, long);
  }

  async getLocationName(lat, lng) {
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`
      );
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

  calculateNearestDistance(lat, long, reports) {
    const toRad = (value) => (value * Math.PI) / 180;
    const earthRadiusKm = 6371;

    let nearestDistance = Infinity;

    reports.forEach((report) => {
      const dLat = toRad(report.lat - lat);
      const dLong = toRad(report.long - long);

      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat)) *
          Math.cos(toRad(report.lat)) *
          Math.sin(dLong / 2) *
          Math.sin(dLong / 2);

      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      const distance = earthRadiusKm * c;

      if (distance < nearestDistance) {
        nearestDistance = distance;
      }
    });

    return nearestDistance;
  }

    updateReportDistances(lat, long) {
    const toRad = (value) => (value * Math.PI) / 180;
    const earthRadiusKm = 6371;
  
    this.reportsValue.forEach((report, index) => {
      const dLat = toRad(report.lat - lat);
      const dLong = toRad(report.long - long);
  
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat)) *
          Math.cos(toRad(report.lat)) *
          Math.sin(dLong / 2) *
          Math.sin(dLong / 2);
  
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      const distance = earthRadiusKm * c;
  
      const distanceElement = this.distanceTargets[index];
      distanceElement.innerHTML = `${distance.toFixed(2)} <span class="text-sm text-end">กม.</span>`;
  
      // Remove the specified classes
      distanceElement.classList.remove('min-h-[50px]', 'animate-pulse', 'bg-gray-300', 'rounded-md');
    });
  }

  showError(error) {
    switch (error.code) {
      case error.PERMISSION_DENIED:
        this.currentLocationTarget.innerHTML =
          "User denied the request for Geolocation.";
        break;
      case error.POSITION_UNAVAILABLE:
        this.currentLocationTarget.innerHTML =
          "Location information is unavailable.";
        break;
      case error.TIMEOUT:
        this.currentLocationTarget.innerHTML =
          "The request to get user location timed out.";
        break;
      case error.UNKNOWN_ERROR:
        this.currentLocationTarget.innerHTML = "An unknown error occurred.";
        break;
    }
  }

  renderTags() {
    this.tagTargets.forEach((tagTarget, index) => {
      const report = this.reportsValue[index];
      const tags = JSON.parse(report.tags) || [];
      tagTarget.innerHTML = tags.slice(0, 3).map(tag => `
        <div class="bg-gray-200 px-2 py-1 rounded-md">
          <span class="text-sm bg-gray-200 px-2 py-1 rounded-lg">${tag}</span>
        </div>
      `).join('');
    });
  }

}