Stimulus.register("datepicker", class extends Controller {
  static targets = [ "input", "span" ]

  connect() {
    const now = moment.tz(timeZone)
    const format = "YYYY-MM-DD"

    function toDate(time) {
      return moment.tz(time.format(format), timeZone)
    }

    const datePicker = $(this.element).daterangepicker({
      singleDatePicker: true,
      locale: { format: format },
      autoUpdateInput: false,
      autoApply: true,
      startDate: this.inputTarget.value.length > 0 ? moment.tz(this.inputTarget.value, timeZone) : now
    })

    // hack to start with empty date
    datePicker.on("apply.daterangepicker", (ev, picker) => {
      this.spanTarget.innerHTML = toDate(picker.startDate).format("MMMM D, YYYY")
      this.inputTarget.value = toDate(picker.startDate).utc().format()
      this.element.dispatchEvent(new Event("change", { bubbles: true }))
    })

    if (this.inputTarget.value.length > 0) {
      this.spanTarget.innerHTML = toDate(datePicker.data("daterangepicker").startDate).format("MMMM D, YYYY")
    }
  }
})
