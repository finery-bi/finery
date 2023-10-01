Stimulus.register("unsaved", class extends Controller {
  changed = false

  check(event) {
    if (this.changed) {
      event.preventDefault()
      return (event.returnValue = "")
    }
  }

  clear(event) {
    if (this.changed) {
      window.removeEventListener("beforeunload", this.check.bind(this), { capture: true })
      this.changed = false
    }
  }

  set(event) {
    if (!this.changed) {
      window.addEventListener("beforeunload", this.check.bind(this), { capture: true })
      this.changed = true
    }
  }
})
