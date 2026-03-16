import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "sidebar"]

  toggle() {
    if (this.overlayTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.sidebarTarget.classList.remove("-translate-x-full")
    })
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)
  }
}
