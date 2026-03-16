import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "canvas", "result", "input", "cameraSection", "manualSection"]

  connect() {
    this.scanning = false
    this.stream = null
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" }
      })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.play()
      this.cameraSectionTarget.classList.remove("hidden")
      this.scanning = true
      this.scanFrame()
    } catch (err) {
      this.resultTarget.textContent = "Camera not available. Please use manual entry."
      this.manualSectionTarget.classList.remove("hidden")
    }
  }

  stopCamera() {
    this.scanning = false
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }
  }

  scanFrame() {
    if (!this.scanning) return

    const video = this.videoTarget
    const canvas = this.canvasTarget
    const ctx = canvas.getContext("2d")

    if (video.readyState === video.HAVE_ENOUGH_DATA) {
      canvas.width = video.videoWidth
      canvas.height = video.videoHeight
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height)

      // Simple QR detection via canvas - in production use a library like jsQR
      // For now, this provides the camera UI framework
    }

    requestAnimationFrame(() => this.scanFrame())
  }

  useManual() {
    this.stopCamera()
    this.cameraSectionTarget.classList.add("hidden")
    this.manualSectionTarget.classList.remove("hidden")
  }
}
