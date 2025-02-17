import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report"
export default class extends Controller {
  static values = { step: Number };
  static targets = ["step", "imagesInput", "previewImages", "previewDetailImages", "locationContainer",
                    "tagContainer", "severitySlider", "severityLabel", "severityInput"
                   ];
  selectedFiles = [];
  selectedTags = [];
  severityLevel = "ปานกลาง";

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

    this.updateInputFiles();

    this.renderPreview();
    this.toggleUploadButton();
    this.toggleNextButton();
  }

  removeImage(event) {
    const index = event.currentTarget.dataset.index;
    this.selectedFiles.splice(index, 1);

    this.updateInputFiles();

    this.renderPreview();
    this.toggleUploadButton();
    this.toggleNextButton();

    if (this.selectedFiles.length === 0) {
      this.imagesInputTarget.value = "";
    }
  }

  updateInputFiles() {
    const dataTransfer = new DataTransfer();

    this.selectedFiles.forEach(file => {
      dataTransfer.items.add(file);
    });

    this.imagesInputTarget.files = dataTransfer.files;
  }

  renderPreview() {
    const previewContainer = this.previewImagesTarget;
    const detailPreviewContainer = this.previewDetailImagesTarget;
    previewContainer.innerHTML = "";
    detailPreviewContainer.innerHTML = "";

    if (this.selectedFiles.length === 0) {
      previewContainer.innerHTML = `
        <i class="min-w-64 h-72 bg-white rounded-lg flex items-center justify-center">
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
          img.classList.add("min-w-64", "h-72", "w-64", "object-cover", "rounded-lg", "shadow-md");

          const deleteButton = document.createElement("button");
          deleteButton.type = "button";
          deleteButton.classList.add("absolute", "h-7", "w-7", "cursor-pointer", "hover:scale-110", "top-2", "right-2", "bg-gray-100", "text-gray-500", "rounded-full");
          deleteButton.dataset.index = index;
          deleteButton.dataset.action = "click->report#removeImage";
          deleteButton.innerHTML = `<i class="fas fa-times"></i>`;

          div.appendChild(img);
          div.appendChild(deleteButton);
          previewContainer.appendChild(div);

          const detailDiv = document.createElement("div");

          const detailImg = document.createElement("img");
          detailImg.src = e.target.result;
          detailImg.classList.add("min-w-48", "h-52", "w-48", "object-cover", "rounded-lg", "shadow-md");

          detailDiv.appendChild(detailImg);
          detailPreviewContainer.appendChild(detailDiv);
        };
        reader.readAsDataURL(file);
      });
    }

    document.querySelector("p.text-gray-400").textContent = `เลือกแล้ว ${this.selectedFiles.length} รูปภาพ`;
  }


  toggleUploadButton() {
    const uploadButton = document.querySelector("label[for='report_images']");
    if (this.selectedFiles.length >= 4) {
      uploadButton.classList.add("hidden", "cursor-not-allowed");
    } else {
      uploadButton.classList.remove("hidden", "cursor-not-allowed");
      uploadButton.classList.add("cursor-pointer", "fade-in");
    }
  }

  toggleTag(event) {
    const tag = event.target.dataset.tag;
  
    if (this.selectedTags.includes(tag)) {
      this.selectedTags = this.selectedTags.filter(t => t !== tag);
      event.target.classList.remove("bg-[#FF6C64]", "text-white");
      event.target.classList.add("bg-gray-200", "text-gray-700");
    } else {
      this.selectedTags.push(tag);
      event.target.classList.remove("bg-gray-200", "text-gray-700");
      event.target.classList.add("bg-[#FF6C64]", "text-white");
    }
    document.querySelector("input[name='report[tags]']").value = JSON.stringify(this.selectedTags);
  }
  

  updateSeverity(event) {
    const value = event.target.value;
    if (value <= 20) {
      this.severityLevel = "เล็กน้อย";
    } else if (value <= 40) {
      this.severityLevel = "ปานกลาง";
    } else if (value <= 60) {
      this.severityLevel = "รุนแรง";
    } else if (value <= 80) {
      this.severityLevel = "รุนแรงมาก";
    } else {
      this.severityLevel = "วิกฤติ";
    }
    this.severityLabelTarget.textContent = this.severityLevel;
    this.severityInputTarget.value = this.severityLevel;
  }
}
