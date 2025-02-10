import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  static targets = ["map", "lat", "long"];


  connect() {
    console.log("Location controller is connected");
    if (!this.mapTarget) {
      console.error("Map element not found.");
      return;
    }
  }

  initMap = async () => {
    // Check if map is already initialized
    if (this.mapTarget._leaflet_id) {
      console.log("Map already initialized.");
      return;
    }

    console.log("Initializing map...");
    const map = L.map('map', {
      center: [15.2313, 104.8567],
      zoom: 13
    });

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap'
    }).addTo(map);

    this.locateUser(map);

    const locationButton = L.control({ position: 'bottomright' });

    locationButton.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
      const button = L.DomUtil.create('a', '', div);
      button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
      button.title = 'Show my location';
      button.style.width = '30px';
      button.style.height = '30px';
      button.style.fontSize = '20px';
      button.style.display = 'flex';
      button.style.alignItems = 'center';
      button.style.justifyContent = 'center';

      L.DomEvent.on(button, 'click', (e) => {
        L.DomEvent.preventDefault(e);
        this.locateUser(map);
      });

      return div;
    };

    map.on("dragend", () => {
      document.getElementById('location-name').innerHTML = "กำลังโหลด...";
      this.handleLatLongChange(map.getCenter().lat, map.getCenter().lng);

    });

    locationButton.addTo(map);
    console.log("Map initialized.");
  }

  async handleLatLongChange(lat, long){
    this.latTarget.value = lat;
    this.longTarget.value = long;
    console.log(`Latitude: ${lat}, Longitude: ${long}`);
    const locationName = await this.getLocationName(lat, long);
    document.getElementById('location-name').innerHTML = locationName;
  }

  async getLocationName(lat, lng) {
    try {
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&accept-language=th`);
      const data = await response.json();
      console.log(data); // เช็กข้อมูลที่ได้จาก API
  
      let locationString = data.display_name || ""; // 🔹 เปลี่ยนจาก const → let
  
      // กรองข้อมูลที่ไม่ต้องการ
      locationString = locationString
        .replace(/, /g, " ")   // เอา "," ออก
        .replace(/ประเทศไทย/g, "") // เอาคำว่า "ประเทศไทย" ออก
        .replace(/\d{5}/g, "")  // เอารหัสไปรษณีย์ 5 ตัวเลขออก
        .trim();               // ตัดช่องว่างหน้า-หลังออก
  
      console.log(locationString); // เช็กค่าหลังจากกรองแล้ว
  
      return locationString || "ไม่พบข้อมูลตำแหน่ง"; // ✅ ส่งค่ากลับ
    } catch (error) {
      console.error("Error fetching location name:", error);
      return "เกิดข้อผิดพลาดในการดึงข้อมูลตำแหน่ง";
    }
  }
  

  locateUser(map) {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by this browser.");
      return;
    }
    const loadingControl = L.control({ position: 'topright' });

    loadingControl.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control bg-white px-3 py-2 rounded-lg shadow-md');
      div.innerHTML = `
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-700">Getting location...</span>
            <i class="fa-solid fa-circle-notch fa-spin"></i>
          </div>
        `;
      return div;
    };

    loadingControl.addTo(map);

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;

        this.handleLatLongChange(lat, lng);
        map.flyTo([lat, lng], 16);
        map.removeControl(loadingControl);
    
        const locationName = await this.getLocationName(lat, lng);
        console.log(`คุณอยู่ที่: ${locationName}`);
        document.getElementById('location-name').innerHTML = locationName;

      }, () => {
        map.removeControl(loadingControl);
        alert("Geolocation permission denied or unavailable.")
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 30000
      }
    );
  }
}
