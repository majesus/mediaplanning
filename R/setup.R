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

  # Verificar y actualizar paquetes
  for(pkg in required_packages) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      message("Instalando ", pkg, "...")
      # Forzar instalación binaria
      options(install.packages.check.source = "no")
      tryCatch({
        install.packages(pkg,
                         type = "binary",
                         dependencies = TRUE,
                         quiet = TRUE)
      }, error = function(e) {
        # Si falla la instalación binaria, intentar con source como respaldo
        message("No se pudo instalar versión binaria de ", pkg, ". Intentando con source...")
        install.packages(pkg,
                         type = "source",
                         dependencies = TRUE,
                         quiet = TRUE)
      })
      options(install.packages.check.source = "both")
    }
  }

  # Verificar instalación exitosa
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  if (length(missing_packages) > 0) {
    warning("No se pudieron instalar los siguientes paquetes: ",
            paste(missing_packages, collapse = ", "))
  }

  # Cargar paquetes principales
  suppressMessages({
    library(shiny)
    library(bslib)
    library(ggplot2)
    library(dplyr)
    library(plotly)
  })

  message("Configuración completada. MediaPlanR está listo para usar.")
}

#' Ejecutar Aplicaciones de MediaPlanR
#' @param app character: Nombre de la aplicación a ejecutar ("beta", "aud", o "reach")
#' @export
run_mediaPlanR <- function(app = c("beta", "aud", "reach")) {
  app <- match.arg(app)

  # Verificar que todo esté instalado
  if(!requireNamespace("shiny", quietly = TRUE) ||
     !requireNamespace("bslib", quietly = TRUE)) {
    setup_mediaPlanR()
  }

  # Ejecutar la app seleccionada
  switch(app,
         "beta" = run_beta_binomial_explorer(),
         "aud" = run_aud_util_explorer(),
         "reach" = run_reach_converg_explorer())
}
