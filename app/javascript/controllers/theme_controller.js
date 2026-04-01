import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "crosspaste-theme"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.handleSystemChange = this.handleSystemChange.bind(this)
    this.applyTheme(document.documentElement.dataset.theme || "dawn")
    this.mediaQuery.addEventListener?.("change", this.handleSystemChange)
  }

  disconnect() {
    this.mediaQuery?.removeEventListener?.("change", this.handleSystemChange)
  }

  toggleFromInput(event) {
    this.applyTheme(event.target.checked ? "night" : "dawn", true)
  }

  handleSystemChange(event) {
    if (window.localStorage.getItem(STORAGE_KEY)) return
    this.applyTheme(event.matches ? "night" : "dawn")
  }

  applyTheme(theme, persist = false) {
    document.documentElement.dataset.theme = theme

    if (this.hasCheckboxTarget) {
      this.checkboxTarget.checked = theme === "night"
    }

    if (persist) {
      window.localStorage.setItem(STORAGE_KEY, theme)
    }
  }
}
