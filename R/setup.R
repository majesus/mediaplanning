#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Configuración básica
  if(is.na(getOption("repos")["CRAN"])) {
    options(repos = c(CRAN = "https://cran.rstudio.com/"))
  }

  # Paquetes necesarios (solo los esenciales)
  pkgs <- c("shiny", "bslib", "ggplot2", "dplyr", "plotly")

  # Instalar solo los que faltan
  missing_pkgs <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]

  if(length(missing_pkgs) > 0) {
    message("Instalando paquetes faltantes...")
    for(pkg in missing_pkgs) {
      message("Instalando ", pkg, "...")
      install.packages(pkg,
                       type = "binary",
                       quiet = TRUE,
                       dependencies = FALSE)  # Clave: dependencies = FALSE
    }
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
