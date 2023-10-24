Stimulus.register("more", class extends Controller {
  static targets = [ "field", "show" ]

  connect() {
    this.fieldTargets.forEach((e) => { e.style.display = "none" })
    this.showTarget.classList.remove("d-none")
  }

  show(event) {
    this.fieldTargets.forEach((e) => { e.style.display = "block" })
    this.showTarget.classList.add("d-none")
  }
})
