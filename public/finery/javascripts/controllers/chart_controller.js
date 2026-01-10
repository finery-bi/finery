(function() {

const CHARTS = {
  scatter: { titles: true, legend: false },
  line2: { type: "line" },
  bar2: { type: "bar" },
  pie: { noScales: true },
}

// http://there4.io/2012/05/02/google-chart-color-list/
const COLORS = [[
  "#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC", "#0099C6",
  "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499", "#22AA99", "#AAAA11",
  "#6633CC", "#E67300", "#8B0707", "#329262", "#5574A6", "#651067"
], [
  "#193366", "#6e1c08", "#7f4c00", "#084b0c", "#4c004c", "#1d1e56", "#004c63",
  "#7a1637", "#335500", "#5c1616", "#18314a", "#4c224c", "#10554c", "#555508",
  "#321966", "#733900", "#450303", "#184930", "#2a3953", "#320833"
]];

const TIMES = {
  year: { step: 365, tooltip: "yyyy" },
  month: { step: 30, tooltip: "MMM yyyy", diff: 365 },
  day: { step: 1, tooltip: "PP", diff: 180 },
  hour: { step: 1.0 / 24, tooltip: "MMM d, h a", diff: 10 },
  minute: { step: 1.0 / 24 / 60, tooltip: "h:mm a", diff: 0.5 }
}

const BORDER_COLOR = ["#dee2e6", "#495057"]
const TARGET_COLOR = ["#109618", "#084b0c"]
const FORECAST_COLOR = ["#54a3ee", "#0e5292"]

Stimulus.register("chart", class extends Controller {
  static values = {
    type: String,
    forecast: Boolean,
    annotations: Array,
  }

  static colors;
  static borderColor;
  static targetStyle;
  static forecastStyle;

  connect() {
    this.updateTheme()

    const chart = { type: this.typeValue, ...CHARTS[this.typeValue] }
    const data = JSON.parse(this.element.textContent)
    const datasets = data.datasets.map((d, i) => ({ ...d, ...this.defaults(chart, i, d.label) }))

    let scale = {}
    if (data.column_types[0] == "time") {
      const time = this.parseTime(datasets)
      scale.type = "time"
      scale.time = {
        unit: time.unit,
        minUnit: time.minUnit,
        tooltipFormat: TIMES[time.minUnit].tooltip,
      }
      for (let i = 0; i < datasets.length; ++i) {
        datasets[i].data = time.data[i]
      }
    }

    new Chart(this.element, {
      type: chart.type,
      data: { datasets, labels: data.labels },
      options: {
        animation: false,
        interaction: { mode: "nearest" },
        maintainAspectRatio: false,
        plugins: {
          tooltip: { displayColors: false },
          legend: { display: chart.legend },
          annotation: { drawTime: "beforeDatasetsDraw", annotations: this.annotationsValue },
        },
        scales: chart.noScales ? {} : {
          y: {
            ticks: { maxTicksLimit: 4 },
            title: { font: { size: 16 }, color: "#333", text: data.y, display: chart.titles },
            grid: {},
          },
          x: {
            grid: { drawOnChartArea: false},
            title: { font: { size: 16 }, color: "#333", text: data.x, display: chart.titles },
            ticks: { callback: this.labelCallback(this.element, datasets[0].data.length) },
            ...scale
          },
        },
      },
    })
  }

  defaults(chart, index, label) {
    if (this.forecastValue && index == 1) { return this.forecastStyle }
    if (chart.type == "pie") { return { borderColor: "rgba(255, 255, 255, 0.2)", backgroundColor: this.colors } }
    if (label == "target") { return this.targetStyle }

    return {
      backgroundColor: this.colors[index],
      borderColor: this.colors[index],
      borderWidth: 2,
      fill: false,
      pointBackgroundColor: this.colors[index],
      pointHitRadius: 50,
      pointHoverBackgroundColor: this.colors[index],
      tension: 0.4,
    }
  }

  parseTime(datasets) {
    let uMinute = false
    let uHour = false
    let uDay = false
    let uMonth = false

    let min = Number.POSITIVE_INFINITY
    let max = Number.NEGATIVE_INFINITY
    let data = new Array(datasets.length)
    for (let i = 0; i < datasets.length; ++i) {
      data[i] = new Array(datasets[i].data.length)
      for (let j = 0; j < data[i].length; ++j) {
        const d = new Date(datasets[i].data[j].x)
        if (d < min) { min = d }
        if (d > max) { max = d }
        uMinute ||= d.getUTCMinutes() !== 0
        uHour ||= d.getUTCHours() !== 0
        uDay ||= d.getUTCDate() !== 1
        uMonth ||= d.getUTCMonth() !== 0

        data[i][j] = { x: d, ...datasets[i].data[j] }
      }
    }
    const minUnit = uMinute ? "minute" : uHour ? "hour" : uDay ? "day" : uMonth? "month" : "year"

    const dayDiff = (max - min) / (24 * 60 * 60 * 1000.0)
    if (dayDiff > TIMES.minute.diff) { uMinute = false }
    if (dayDiff > TIMES.hour.diff) { uHour = false }
    if (dayDiff > TIMES.day.diff) { uDay = false }
    const unit = uMinute ? "minute" : uHour ? "hour" : uDay ? "day" : uMonth? "month" : "year"

    return { data, minUnit, unit }
  }

  labelCallback(element, length) {
    const maxLabelSize = Math.min(25, Math.max(10, Math.ceil(element.offsetWidth / 4.0 / length)))
    return function(value, index, ticks) {
      const str = "" + this.getLabelForValue(value)
      if (str.length > maxLabelSize) {
        return str.substring(0, maxLabelSize - 2) + "...";
      } else {
        return str;
      }
    }
  }

  updateTheme() {
    const theme = document.documentElement.dataset.bsTheme == "dark" ? 1 : 0
    this.colors = COLORS[theme]
    this.borderColor = BORDER_COLOR[theme]
    this.targetStyle = { pointStyle: "line", pointBorderWidth: 0, hitRadius: 5, borderColor: TARGET_COLOR[theme], pointBackgroundColor: TARGET_COLOR[theme], backgroundColor: TARGET_COLOR[theme], pointHoverBackgroundColor: TARGET_COLOR[theme] }
    this.forecastStyle = { borderDash: [8], borderColor: FORECAST_COLOR[theme], pointBackgroundColor: FORECAST_COLOR[theme], backgroundColor: FORECAST_COLOR[theme], pointHoverBackgroundColor: FORECAST_COLOR[theme] }
  }
})

}())
