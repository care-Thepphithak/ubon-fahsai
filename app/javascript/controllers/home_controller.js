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
        this.distributePosition.bind(this),
        this.showError.bind(this)
      );
    } else {
      this.currentLocationTarget.innerHTML =
        "Geolocation is not supported by this browser.";
    }
  }

  async distributePosition(position) {
    const lat = position.coords.latitude;
    const long = position.coords.longitude;
    this.showTitleCurrentLocation(lat, long);
    this.showNumberNearestDistance(lat, long);
    this.updateReportDistances(lat, long);
  }

  async showTitleCurrentLocation(lat, long) {
    const locationName = await this.getLocationName(lat, long);
    this.currentLocationTarget.innerHTML = locationName;
  }

  async showNumberNearestDistance(lat, long) {
    const nearestDistance = this.calculateNearestDistance(lat, long, this.reportsValue);
    this.nearestDistanceTarget.innerHTML = isFinite(nearestDistance) ? nearestDistance.toFixed(2) : " -";
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

      distanceElement.classList.remove('min-h-[50px]', 'animate-pulse', 'bg-gray-300', 'rounded-md');
    });
  }

  async getLocationName(lat, lng) {
    try {
      const referer = ["https://ubon-fahsai-dev.odd.works", "https://ubon-fahsai-uat.odd.works"];
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`,
        {
          headers: {
            "Referer": referer
          }
        }
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
      tagTarget.innerHTML = tags.map(tag => `
        <div class="bg-gray-200 px-2 py-1 rounded-md">
          <span class="text-sm bg-gray-200 rounded-lg">${tag}</span>
        </div>
      `).join('');
    });
  }

}