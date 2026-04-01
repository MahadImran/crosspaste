import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "count"]

  connect() {
    this.updateCount()
  }

  updateCount() {
    if (!this.hasTextareaTarget || !this.hasCountTarget) return
    this.countTarget.textContent = this.textareaTarget.value.length
  }

  async copy() {
    if (!this.hasTextareaTarget) return
    await navigator.clipboard.writeText(this.textareaTarget.value)
  }
}
