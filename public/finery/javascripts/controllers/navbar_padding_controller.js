Stimulus.register("navbar-padding", class extends Controller {
  static targets = [ "navbar" ]

  connect() {
    this.element.style.paddingTop = (this.navbarTarget.clientHeight || 0) + "px"
  }
})
