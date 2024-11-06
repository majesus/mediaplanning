#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function(load_packages = FALSE) {
  message("Iniciando configuración de MediaPlanR...")

  # Desactivar actualizaciones
  options(repos = NULL)

  # Lista de paquetes necesarios
  pkgs <- c("shiny", "bslib", "ggplot2", "dplyr", "plotly")

  # Verificar qué paquetes faltan
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]

  if(length(missing) > 0) {
    message("Se necesitan instalar los siguientes paquetes: ",
            paste(missing, collapse = ", "))
    message("\nPor favor:")
    message("1. Guarde su trabajo")
    message("2. Reinicie R (Session > Restart R)")
    message("3. Ejecute: install.packages(c('", paste(missing, collapse = "', '"),
            "'), repos = 'https://cran.rstudio.com/', type = 'win.binary')")
    message("4. Vuelva a ejecutar setup_mediaPlanR()")
    return(FALSE)
  }

  if(load_packages) {
    # Cargar paquetes solo si se solicita explícitamente
    suppressMessages({
      library(shiny)
      library(bslib)
      library(ggplot2)
      library(dplyr)
      library(plotly)
    })
  }

  message("Configuración completada.")
  return(TRUE)
}
