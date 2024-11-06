setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Configuración básica
  if(is.na(getOption("repos")["CRAN"])) {
    options(repos = c(CRAN = "https://cran.rstudio.com/"))
  }

  # Evitar instalación desde source si la versión binaria es más antigua
  options(install.packages.check.source = "no")
  options(install.packages.compile.from.source = "never")
  options(pkgType = "win.binary")

  # Paquetes necesarios
  pkgs <- c("shiny", "bslib", "ggplot2", "dplyr", "plotly")

  # Instalar solo los que faltan
  missing_pkgs <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]

  if(length(missing_pkgs) > 0) {
    message("Instalando paquetes faltantes...")
    install.packages(missing_pkgs,
                     type = "win.binary",
                     quiet = TRUE,
                     dependencies = FALSE)
  }

  # Cargar los paquetes necesarios
  suppressMessages({
    library(shiny)
    library(bslib)
    library(ggplot2)
    library(dplyr)
    library(plotly)
  })

  message("Configuración completada.")
}
