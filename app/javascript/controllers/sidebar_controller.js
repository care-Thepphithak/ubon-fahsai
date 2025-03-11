import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  toggle() {
    if (this.sidebarTarget.classList.contains("-translate-x-full")) {
      this.sidebarTarget.classList.remove("-translate-x-full")
      this.backdropTarget.classList.remove("opacity-0", "invisible")
      this.backdropTarget.classList.add("opacity-50")
      setTimeout(() => {
        this.backdropTarget.setAttribute("data-action", "click->sidebar#toggle")
      }, 300)
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
      this.backdropTarget.classList.remove("opacity-50")
      this.backdropTarget.classList.add("opacity-0")
      this.backdropTarget.removeAttribute("data-action")

      setTimeout(() => {
        this.backdropTarget.classList.add("invisible")
      }, 300)
    }
  }
}
