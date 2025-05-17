import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bottomSheet"]

  connect() {
    if (this.isOpen()) {
      this.open();
    }
  }

  isOpen() {
    return this.data.get("open") === "true";
  }

  open(event) {
    event?.preventDefault();

    const locationNameBottomSheet = document.getElementById("location-name-bottom-sheet");
    const locationName = document.getElementById("location-name");

    if (locationNameBottomSheet && locationName) {
      locationNameBottomSheet.innerText = locationName.innerText;
    }

    this.bottomSheetTarget.classList.remove("hidden");
    this.bottomSheetTarget.classList.add("flex");

    this.bottomSheetTarget.classList.remove("opacity-out");
    this.bottomSheetTarget.classList.add("opacity-in");

    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("slide-down");
    modalContent.classList.add("slide-up");

    if (this.isOpen()) {
      setTimeout(() => this.close(), 6000);
    }

    this.bottomSheetTarget.addEventListener('click', this.handleBackdropClick);
  }

  close(event) {
    if (event) event.preventDefault();

    this.bottomSheetTarget.classList.remove("opacity-in");
    this.bottomSheetTarget.classList.add("opacity-out");

    const modalContent = this.bottomSheetTarget.querySelector("div");
    modalContent.classList.remove("slide-up");
    modalContent.classList.add("slide-down");

    setTimeout(() => this.bottomSheetTarget.classList.add("hidden"), 300);

    this.bottomSheetTarget.removeEventListener('click', this.handleBackdropClick);

    if (this.isOpen()) {
      setTimeout(() => this.bottomSheetTarget.remove(), 300);
    }
  }

  handleBackdropClick = (event) => {
    if (event.target === this.bottomSheetTarget && !event.target.closest("#content")) {
      this.close(event);
    }
  }

  submit() {
    this.bottomSheetTarget.classList.add("hidden");
  }
}
