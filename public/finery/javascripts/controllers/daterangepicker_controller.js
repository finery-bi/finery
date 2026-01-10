Stimulus.register("daterangepicker", class extends Controller {
  connect() {
    const now = moment.tz(timeZone)
    const format = "YYYY-MM-DD"

    function toDate(time) {
      return moment.tz(time.format(format), timeZone)
    }
    function dateStr(daysAgo) {
      return now.clone().subtract(daysAgo || 0, "days").format(format)
    }
    function setTimeInputs(start, end) {
      $("#start_time").val(toDate(start).utc().format())
      $("#end_time").val(toDate(end).endOf("day").utc().format())
    }

    const datePicker = $(this.element).daterangepicker({
      ranges: {
        "Today": [dateStr(), dateStr()],
        "Last 7 Days": [dateStr(6), dateStr()],
        "Last 30 Days": [dateStr(29), dateStr()]
      },
      locale: {
        format: format
      },
      startDate: dateStr(29),
      endDate: dateStr(),
      opens: "right",
      alwaysShowCalendars: true
    },
    function(start, end) {
      setTimeInputs(start, end)
      this.element.dispatchEvent(new Event("change", { bubbles: true }))
    }.bind(this)).on("apply.daterangepicker", function(ev, picker) {
      setTimeInputs(picker.startDate, picker.endDate)
      $("#reportrange span").html(toDate(picker.startDate).format("MMMM D, YYYY") + " - " + toDate(picker.endDate).format("MMMM D, YYYY"))
    })

    const picker = datePicker.data("daterangepicker")
    if ($("#start_time").val().length > 0) {
      picker.setStartDate(moment.tz($("#start_time").val(), timeZone))
      picker.setEndDate(moment.tz($("#end_time").val(), timeZone))
      $(this.element).trigger("apply.daterangepicker", picker)
    } else {
      $(this.element).trigger("apply.daterangepicker", picker)
      this.element.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }
})
