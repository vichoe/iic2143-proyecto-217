import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "previous", "next"]

  connect() {
    this.resizeObserver = new ResizeObserver(() => this.update())
    this.resizeObserver.observe(this.trackTarget)
    this.update()
  }

  disconnect() {
    this.resizeObserver.disconnect()
  }

  previous() {
    this.move(-1)
  }

  next() {
    this.move(1)
  }

  move(direction) {
    const track = this.trackTarget
    const reducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches

    track.scrollBy({
      left: direction * track.clientWidth * 0.8,
      behavior: reducedMotion ? "instant" : "smooth"
    })
  }

  update() {
    const track = this.trackTarget
    const maximum = track.scrollWidth - track.clientWidth
    const overflows = maximum > 2

    this.previousTarget.hidden = !overflows
    this.nextTarget.hidden = !overflows

    this.previousTarget.disabled = track.scrollLeft <= 2
    this.nextTarget.disabled =
      !overflows || track.scrollLeft >= maximum - 2
  }
}