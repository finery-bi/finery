Stimulus.register("autosubmit", class extends Controller {
  call(event) {
    for (let e of this.element.elements) {
      if (e.name && $(e).val() == "") {
        return
      }
    }

    this.element.requestSubmit()
  }
})
