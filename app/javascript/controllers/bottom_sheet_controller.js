import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-sheet"
export default class extends Controller {
  static targets = ["bottomSheet"]
  
  connect() {
    console.log("Modal controller connected!");
  }

  open(event) {
    event.preventDefault();
    
    const locationNameBottomSheet = document.getElementById("location-name-bottom-sheet");
    const locationName = document.getElementById("location-name");

    if (locationNameBottomSheet && locationName) {
      locationNameBottomSheet.innerText = locationName.innerText;
    }
  
    this.bottomSheetTarget.classList.remove("hidden");
    this.bottomSheetTarget.classList.add("flex");
    
    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("slide-down");
    modalContent.classList.add("slide-up");
  }

  close(event) {
    event.preventDefault();

    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("slide-up");
    modalContent.classList.add("slide-down");

    setTimeout(() => this.bottomSheetTarget.classList.add("hidden"), 300);
  }

  submit() {
    this.bottomSheetTarget.classList.add("hidden");
  }
}
