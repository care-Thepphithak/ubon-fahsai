import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static values = { step: Number };
  static targets = ["step", "imagesInput", "previewImages", "locationContainer"]
  selectedFiles = [];

  connect() {
    this.showStep();

    console.log("Report controller is connected");
    
  }

  next(event) {
    event.preventDefault();
    if (this.stepValue < this.stepTargets.length - 1) {
      const currentStep = this.stepValue;
      const nextStep = this.stepTargets[currentStep + 1];

      nextStep.addEventListener('animationend', () => {
          if (currentStep === 0) {
            this.dispatch("initMap", { target: this.locationContainerTarget })
          }
        }, { once: true });

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
