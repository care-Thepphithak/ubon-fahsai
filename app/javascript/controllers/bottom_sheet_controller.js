import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-sheet"
export default class extends Controller {
  static targets = ["bottomSheet"]
  
  connect() {
    console.log("Modal controller connected!");
  }

  open(event) {
    event.preventDefault();
    
    this.bottomSheetTarget.classList.remove("hidden");
    this.bottomSheetTarget.classList.add("flex");
    
    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("fade-out");
    modalContent.classList.add("fade-in");
  }

  close(event) {
    event.preventDefault();

    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("fade-in");
    modalContent.classList.add("fade-out");

    setTimeout(() => this.bottomSheetTarget.classList.add("hidden"), 300);
  }

  submit() {
    this.bottomSheetTarget.classList.add("hidden");
  }
}
