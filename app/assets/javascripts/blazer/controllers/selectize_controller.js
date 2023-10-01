Stimulus.register("selectize", class extends Controller {
  connect() {
    $(this.element).selectize({
      create: true,
      onChange: function() { this.$input[0].dispatchEvent(new Event("change", { bubbles: true })) },
    })
  }
})
