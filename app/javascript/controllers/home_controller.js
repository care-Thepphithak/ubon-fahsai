import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["currentLocation"];

  connect() {
    this.getCurrentLocation();
  }

  getCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        this.showCerrentLocation.bind(this),
        this.showError.bind(this)
      );
    } else {
      this.currentLocationTarget.innerHTML =
        "Geolocation is not supported by this browser.";
    }
  }

  async showCerrentLocation(position) {
    const lat = position.coords.latitude;
    const long = position.coords.longitude;
    const locationName = await this.getLocationName(lat, long);
    this.currentLocationTarget.innerHTML = locationName;
    // You can also use a reverse geocoding API to get the location name from lat and long
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

      // Split the string into an array, remove the last two elements, and join it back into a string
      const locationArray = locationString.split(" ");
      locationString = locationArray.slice(-2).join(" ");

      return locationString || "ไม่พบข้อมูลตำแหน่ง";
    } catch (error) {
      console.error("Error fetching location name:", error);
      return "ไม่พบข้อมูลตำแหน่ง";
    }
  }
}
