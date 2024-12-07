if (!document.documentElement.dataset.bsTheme) {
  function updateBsTheme() {
    document.documentElement.dataset.bsTheme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", updateBsTheme)
  updateBsTheme()
}
