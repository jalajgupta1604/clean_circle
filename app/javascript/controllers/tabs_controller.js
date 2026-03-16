import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: { type: String, default: "" } }

  connect() {
    if (this.activeValue) {
      this.show(this.activeValue)
    } else if (this.tabTargets.length > 0) {
      this.show(this.tabTargets[0].dataset.tabsId)
    }
  }

  select(event) {
    event.preventDefault()
    this.show(event.currentTarget.dataset.tabsId)
  }

  show(id) {
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabsId === id) {
        tab.classList.add("border-emerald-500", "text-emerald-600")
        tab.classList.remove("border-transparent", "text-gray-500")
      } else {
        tab.classList.remove("border-emerald-500", "text-emerald-600")
        tab.classList.add("border-transparent", "text-gray-500")
      }
    })

    this.panelTargets.forEach(panel => {
      panel.classList.toggle("hidden", panel.dataset.tabsId !== id)
    })
  }
}
