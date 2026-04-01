import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  normalize() {
    if (!this.hasInputTarget) return
    this.inputTarget.value = this.inputTarget.value.toLowerCase().replace(/[^a-z0-9]/g, "").slice(0, 6)
  }
}
