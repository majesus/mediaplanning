#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Lista de paquetes requeridos
  required_packages <- c(
    "shiny",
    "bslib",
    "ggplot2",
    "dplyr",
    "plotly",
    "tidyr",
    "tibble",
    "purrr",
    "magrittr",
    "scales",
    "DT",
    "readr",
    "devtools"
  )

  # Configurar opciones para evitar actualizaciones y usar binarios
  old_options <- options()
  on.exit(options(old_options))

  options(
    install.packages.check.source = "no",
    install.packages.compile.from.source = "never",
    pkgType = "binary",
    repos = c(CRAN = "https://cran.rstudio.com/")
  )

  # Verificar e instalar SOLO los paquetes faltantes
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

  if(length(missing_packages) > 0) {
    message("Instalando paquetes faltantes...")
    utils::install.packages(missing_packages,
                            dependencies = TRUE,
                            type = "binary",
                            quiet = TRUE,
                            ask = FALSE,
                            upgrade = "never")  # Esto es clave - nunca actualizar
  }

  # Cargar paquetes principales sin verificar actualizaciones
  suppressMessages({
    library(shiny)
    library(bslib)
    library(ggplot2)
    library(dplyr)
    library(plotly)
  })

  message("Configuración completada. MediaPlanR está listo para usar.")
}
