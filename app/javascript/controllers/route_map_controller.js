import { Controller } from "@hotwired/stimulus"
import "leaflet"

export default class extends Controller {
  static values = {
    households: Array
  }

  connect() {
    if (!this.hasHouseholdsValue || this.householdsValue.length === 0) {
      this.element.innerHTML = '<div class="px-4 py-8 text-center text-sm text-gray-400">No household locations available to display on the map.</div>'
      return
    }

    const householdsWithCoords = this.householdsValue.filter(h => h.lat && h.lng)

    if (householdsWithCoords.length === 0) {
      this.element.innerHTML = '<div class="px-4 py-8 text-center text-sm text-gray-400">No coordinates available for households on this route.</div>'
      return
    }

    this.map = L.map(this.element).setView([0, 0], 13)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    const markers = []

    householdsWithCoords.forEach(household => {
      const color = this.markerColor(household.pickup_status)
      const icon = L.divIcon({
        className: "custom-marker",
        html: `<div style="background-color: ${color}; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>`,
        iconSize: [24, 24],
        iconAnchor: [12, 12],
        popupAnchor: [0, -12]
      })

      const marker = L.marker([household.lat, household.lng], { icon })
        .addTo(this.map)
        .bindPopup(`
          <div style="min-width: 150px;">
            <strong>${this.escapeHtml(household.address)}</strong><br>
            <span style="color: ${color}; font-weight: 600;">${this.statusLabel(household.pickup_status)}</span>
          </div>
        `)

      markers.push(marker)
    })

    if (markers.length > 0) {
      const group = L.featureGroup(markers)
      this.map.fitBounds(group.getBounds().pad(0.1))
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  markerColor(status) {
    switch (status) {
      case "completed":   return "#16a34a"
      case "scheduled":   return "#2563eb"
      case "in_progress": return "#2563eb"
      case "missed":      return "#dc2626"
      default:            return "#9ca3af"
    }
  }

  statusLabel(status) {
    switch (status) {
      case "completed":   return "Completed"
      case "scheduled":   return "Scheduled"
      case "in_progress": return "In Progress"
      case "missed":      return "Missed"
      default:            return "No Pickup Today"
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
