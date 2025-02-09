import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static values = { step: Number };
  static targets = ["step", "map", "lat", "long", "imagesInput", "previewImages"]
  selectedFiles = [];

  connect() {
    this.showStep();

    console.log("Report controller is connected");
    if (!this.mapTarget) {
      console.error("No map element found in the DOM");
      return;
    }
    console.log("Map element found in the DOM");
    this.initializzedMap();
  }

  next(event) {
    event.preventDefault();
    if (this.stepValue < this.stepTargets.length - 1) {
      this.stepValue++;
      this.showStep();
    }
  }

  prev(event) {
    event.preventDefault();
    if (this.stepValue > 0) {
      this.stepValue--;
      this.showStep();
    }
  }

  showStep() {
    this.stepTargets.forEach((el, index) => {
      if (index === this.stepValue) {
        el.classList.add("fade-in");
        el.classList.remove("fade-out");
        setTimeout(() => {
          el.classList.remove("hidden");
        }, 300);
      } else {
        el.classList.add("fade-out");
        el.classList.remove("fade-in");
        setTimeout(() => {
          el.classList.add("hidden");
        }, 300);
      }
    });
  }

  initializzedMap() {
    const map = L.map('map').setView([13.736717, 100.523186], 13); // ค่าเริ่มต้น (กรุงเทพฯ)

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    // Add custom location control
    const locationButton = L.control({ position: 'bottomright' });

    locationButton.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
      const button = L.DomUtil.create('a', '', div);
      button.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>';
      button.href = '#';
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

    locationButton.addTo(map);
    this.locateUser(map);
  }

  handleLatLongChange(lat, long) {
    this.latTarget.value = lat;
    this.longTarget.value = long;
  }

  locateUser(map) {
    if (navigator.geolocation) {
      console.log("Geolocation API is available");

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          const customIcon = L.icon({
            // TODO: Find a better way to load the icon, currently it is loaded by line: 26 in application.html.erb
            iconUrl: customIconUrl,
            iconSize: [20, 30],
            iconAnchor: [10, 0],
            popupAnchor: [0, 0]
          });

          const marker = L.marker(map.getCenter(), { icon: customIcon })
            .addTo(map)
            .bindPopup("You are here!")
            .openPopup();;

          map.on("move", () => {
            setTimeout(() => marker.setLatLng(map.getCenter()), 150);
            let newLatLng = map.getCenter();
            this.handleLatLongChange(newLatLng.lat, newLatLng.lng);
            console.log("Map center moved to", newLatLng);
          });
          map.setView([lat, lng], 15);
        }, () => alert("Geolocation permission denied or unavailable.")
      );

    } else {
      alert("Geolocation is not supported by this browser.");
    }
  }

  toggleNextButton() {
    const nextButton = document.getElementById("upload-step-next");
    if (this.selectedFiles.length === 0) {
      nextButton.setAttribute("disabled", "true");
      nextButton.classList.add("opacity-50");
    } else {
      nextButton.removeAttribute("disabled");
      nextButton.classList.remove("opacity-50");
    }
  }
  
  handleImageUpload(event) {
    let files = Array.from(event.target.files);

    files = files.filter(file => !this.selectedFiles.some(f => f.name === file.name));

    this.selectedFiles.push(...files);

    if (this.selectedFiles.length > 4) {
      this.selectedFiles = this.selectedFiles.slice(0, 4);
    }

    this.renderPreview();
    this.toggleUploadButton();
    this.toggleNextButton();
  }

  removeImage(event) {
    const index = event.currentTarget.dataset.index;
    this.selectedFiles.splice(index, 1);
  
    this.renderPreview();
    this.toggleUploadButton();
    this.toggleNextButton();
  
    if (this.selectedFiles.length === 0) {
      this.imagesInputTarget.value = "";
    }
  }
  

  renderPreview() {
    const previewContainer = this.previewImagesTarget;
    previewContainer.innerHTML = "";

    if (this.selectedFiles.length === 0) {
      previewContainer.innerHTML = `
        <i class="min-w-64 h-96 bg-gray-100 rounded-lg flex items-center justify-center">
          <i class="fas fa-camera text-5xl text-gray-300"></i>
        </i>
      `;
    } else {
      this.selectedFiles.forEach((file, index) => {
        const reader = new FileReader();
        reader.onload = (e) => {
          const div = document.createElement("div");
          div.classList.add("relative");

          const img = document.createElement("img");
          img.src = e.target.result;
          img.classList.add("min-w-64", "h-96", "w-64", "object-cover", "rounded-lg", "shadow-md");

          const deleteButton = document.createElement("button");
          deleteButton.type = "button";
          deleteButton.classList.add("absolute", "h-7", "w-7", "cursor-pointer", "hover:scale-110", "top-2", "right-2", "bg-gray-100", "text-gray-500", "rounded-full");
          deleteButton.dataset.index = index;
          deleteButton.dataset.action = "click->report#removeImage";
          deleteButton.innerHTML = `<i class="fas fa-times"></i>`;

          div.appendChild(img);
          div.appendChild(deleteButton);
          previewContainer.appendChild(div);
        };
        reader.readAsDataURL(file);
      });
    }

    document.querySelector("p.text-gray-400").textContent = `เลือกแล้ว ${this.selectedFiles.length} รูปภาพ`;
  }

  toggleUploadButton() {
    const uploadButton = document.querySelector("label[for='report_images']");
    if (this.selectedFiles.length >= 4) {
      uploadButton.classList.add("opacity-50", "cursor-not-allowed");
      this.imagesInputTarget.disabled = true;
    } else {
      uploadButton.classList.remove("opacity-50", "cursor-not-allowed");
      this.imagesInputTarget.disabled = false;
    }
  }
}
