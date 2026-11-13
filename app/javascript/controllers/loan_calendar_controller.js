import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day", "selection"]
  static values = { requestUrl: String }

  connect() {
    this.selected = []
  }

  select(event) {
    const date = event.currentTarget.dataset.date

    if (this.selected.length === 2) {
      this.selected = []
    }

    this.selected.push(date)
    this.selected.sort()

    this.dayTargets.forEach((day) => {
      day.classList.toggle(
        "is-selected",
        this.selected.includes(day.dataset.date)
      )
    })

    if (this.selected.length === 1) {
      this.selectionTarget.textContent =
        "Ahora selecciona el día de término."
    } else {
      const [startDate, endDate] = this.selected

      window.location.href =
        `${this.requestUrlValue}?start_date=${startDate}&end_date=${endDate}`
    }
  }
}