import { Controller } from "@hotwired/stimulus"

// Muestra las fechas de disponibilidad solo cuando la modalidad es "préstamo"
export default class extends Controller {
  static targets = ["modality", "dates"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isLoan = this.modalityTarget.value === "loan"
    this.datesTarget.hidden = !isLoan
    // Si no es préstamo, se borran las fechas para que no se guarden
    if (!isLoan) {
      this.datesTarget.querySelectorAll("input[type=date]").forEach((input) => { input.value = "" })
    }
  }
}