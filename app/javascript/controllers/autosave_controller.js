import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "status"]
  static values = { url: String, debounce: { type: Number, default: 1000 } }

  connect() {
    this.timeout = null
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  schedule() {
    clearTimeout(this.timeout)
    this.setStatus("Editing…")
    this.timeout = setTimeout(() => this.save(), this.debounceValue)
  }

  async save() {
    const form = this.element.closest("form")
    if (!form) return

    const body = new FormData(form)

    body.delete("article[cover_image]")

    this.setStatus("Saving…")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json",
        },
        body,
      })

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      this.setStatus(data.status === "saved" ? `Saved at ${data.saved_at}` : "Save failed")
    } catch (error) {
      this.setStatus("Save failed — will retry on next change")
    }
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
