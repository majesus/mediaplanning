# Crear nuevo archivo R/setup.R en el repositorio
# Contenido del archivo setup.R:

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
      install.packages(pkg, dependencies = TRUE)
    }
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