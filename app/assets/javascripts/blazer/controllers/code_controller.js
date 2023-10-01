Stimulus.register("code", class extends Controller {
  connect() {
    if (code.innerText.length < 10000) {
      hljs.highlightElement(this.element)
    }
  }
})
