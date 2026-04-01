import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  async copy() {
    await navigator.clipboard.writeText(this.textValue)
  }
}
