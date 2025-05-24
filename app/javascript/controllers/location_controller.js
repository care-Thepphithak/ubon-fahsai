import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["map", "lat", "long", "locationName", "submitReport", "areaId"];
  static values = {
    userAreas: Array,
  };

  connect() {
    if (!this.mapTarget) {
      console.error("Map element not found.");
      return;
    }
    this.addCustomEventListeners();
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.handleTurboStream.bind(this));
  }

  addCustomEventListeners() {
    document.addEventListener("turbo:before-stream-render", this.handleTurboStream.bind(this));
  }

  handleTurboStream(event) {
    const turboStream = event.detail.newStream;
    if (turboStream.target === "location-name") {
      document.getElementById("location-name").classList.remove("line-clamp-1");
    }
  }

  initMap = async () => {
    if (this.mapTarget._leaflet_id) {
      return;
    }
    const map = L.map("map", {
      center: [15.2313, 104.8567],
      zoom: 13,
    });

    this.map = map;
    this.createUserArea(map);

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap",
    }).addTo(map);

    this.locateUser(map);
    const locationButton = L.control({ position: "bottomright" });
    locationButton.onAdd = () => {
      const div = L.DomUtil.create("div", "leaflet-bar leaflet-control");
      const button = L.DomUtil.create("a", "flex items-center justify-center w-7 h-7 text-2xl", div);
      button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
      button.title = "Show my location";

      L.DomEvent.on(button, "click", (e) => {
        L.DomEvent.preventDefault(e);
        this.locateUser(map);
      });

      return div;
    };

    map.on("dragend", () => {
      document.getElementById("location-name").innerHTML = "กำลังหาตำแหน่ง...";
      this.handleLatLongChange(map.getCenter().lat, map.getCenter().lng);
    });

    locationButton.addTo(map);
  };

  createUserArea(map) {
    this.userAreasCoordinates = this.userAreasValue.map((area) => {
      const areaId = Object.keys(area);
      return area[areaId];
    });

    this.userAreasValue.forEach((area) => {
      const areaId = Object.keys(area);
      const polygon = L.polygon(area[areaId], { fillOpacity: 0 }).addTo(map);
      map.on('moveend', () => polygon.redraw());
      map.on('zoomend', () => polygon.redraw());
      map.on('movestart', () => polygon.bringToFront());
    });
  }

  isInsideArea(lat, lng) {
    return this.userAreasCoordinates.some(area => this.isMarkerInsidePolygon(lat, lng, area));
  }

  isMarkerInsidePolygon(lat, lng, poly) {
    let inside = false;
    for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      const [xi, yi] = poly[i];
      const [xj, yj] = poly[j];
      const intersect = (yi > lng) !== (yj > lng) && (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  async handleLatLongChange(lat, long) {
    this.latTarget.value = lat;
    this.longTarget.value = long;
    const isInside = this.isInsideArea(lat, long);

    if (!isInside) {
      this.disableSubmitButton();
      document.getElementById("location-name").innerHTML = "ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ";
      return;
    }

    const selectedArea = this.userAreasValue.filter(area => this.isMarkerInsidePolygon(lat, long, area[Object.keys(area)]));
    this.areaIdTarget.value = selectedArea.flatMap(area => Object.keys(area));

    this.disableSubmitButton();
    const locationName = await this.getLocationName(lat, long);
    document.getElementById("location-name").innerHTML = locationName;
    this.locationNameTarget.value = locationName;
    this.enableSubmitButton();
  }

  enableSubmitButton() {
    const confirmButton = document.getElementById("submit");
    if (confirmButton) {
      confirmButton.removeAttribute("disabled");
      confirmButton.classList.remove("bg-gray-200", "cursor-not-allowed");
      confirmButton.classList.add("bg-primary", "hover:bg-primary-hover");
    }
  }

  disableSubmitButton() {
    const confirmButton = document.getElementById("submit");
    if (confirmButton) {
      confirmButton.setAttribute("disabled", "true");
      confirmButton.classList.add("bg-gray-200", "cursor-not-allowed");
      confirmButton.classList.remove("bg-primary", "hover:bg-primary-hover");
    }
  }

  async getLocationName(lat, lng) {
    try {
      const referer = ["https://ubon-fahsai-dev.odd.works", "https://ubon-fahsai-uat.odd.works"];
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`, {
          headers: {
            "Referer": referer,
          }
      });
      const data = await response.json();
      let locationString = data.display_name || "";
      locationString = locationString.replace(/, /g, " ").replace(/ประเทศไทย/g, "").replace(/\d{5}/g, "").trim();
      return locationString || "ไม่พบข้อมูลตำแหน่ง";
    } catch (error) {
      console.error("Error fetching location name:", error);
      return "ไม่พบข้อมูลตำแหน่ง";
    }
  }

  createLoadingControl() {
  const loadingControl = L.control({ position: "topright" });
  loadingControl.onAdd = () => {
    const div = L.DomUtil.create(
      "div",
      "leaflet-bar leaflet-control bg-white px-3 py-2 rounded-lg shadow-md"
    );
    div.innerHTML = `
      <div class="flex items-center gap-2" data-testid="location-loading">
        <span class="text-sm text-gray-700">กำลังหาตำแหน่ง...</span>
        <i class="fa-solid fa-circle-notch fa-spin"></i>
      </div>
    `;
    return div;
  };
  return loadingControl;
}

  locateUser(map) {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by this browser.");
      return;
    }
    const loadingControl = this.createLoadingControl();
    loadingControl.addTo(map);
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        this.handleLatLongChange(lat, lng);
        map.flyTo([lat, lng], 16);
        map.removeControl(loadingControl);
      },
      () => {
        map.removeControl(loadingControl);
        const locationName = document.getElementById("location-name")
        locationName.classList.remove("line-clamp-1");
        locationName.innerHTML = "ไม่สามารถหาตำแหน่งได้ กรุณาให้สิทธิ์เข้าถึงตำแหน่ง และลองใหม่อีกครั้ง";
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 30000,
      }
    );
  }
}
