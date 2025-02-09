import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-sheet"
export default class extends Controller {
  static targets = ["bottomSheet"]
  connect() {
    console.log("Modal controller connected!");
  }

  open() {
    this.bottomSheetTarget.classList.remove("hidden");
    this.bottomSheetTarget.classList.add("flex"); 
  }

  close() {
    this.bottomSheetTarget.classList.add("hidden");
  }
}
