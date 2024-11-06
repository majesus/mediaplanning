#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Guardar opciones originales
  old_opts <- options()
  on.exit(options(old_opts))

  # Configurar opciones para forzar binarios y evitar actualizaciones
  options(
    repos = c(CRAN = "https://cran.rstudio.com/"),
    install.packages.check.source = "no",
    install.packages.compile.from.source = "never",
    pkgType = "win.binary",
    menu.graphics = FALSE,
    askYesNo = FALSE
  )

  # Paquetes necesarios
  pkgs <- c("shiny", "bslib", "ggplot2", "dplyr", "plotly")

  # Instalar SOLO los paquetes que faltan (sin actualizar los existentes)
  missing_pkgs <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]

  if(length(missing_pkgs) > 0) {
    message("Instalando paquetes faltantes: ", paste(missing_pkgs, collapse = ", "))
    for(pkg in missing_pkgs) {
      tryCatch({
        utils::install.packages(pkg,
                                type = "win.binary",
                                quiet = TRUE,
                                dependencies = FALSE,  # No instalar dependencias extras
                                ask = FALSE,          # No preguntar nada
                                force = FALSE)        # No forzar reinstalación
      }, error = function(e) {
        warning("No se pudo instalar ", pkg, ": ", e$message)
      })
    }
  }

  # Verificar que tenemos todos los paquetes necesarios
  still_missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if(length(still_missing) > 0) {
    stop("No se pudieron instalar los siguientes paquetes: ",
         paste(still_missing, collapse = ", "))
  }

  # Cargar los paquetes sin mensajes
  suppressMessages({
    library(shiny)
    library(bslib)
    library(ggplot2)
    library(dplyr)
    library(plotly)
  })

  message("Configuración completada exitosamente.")
}
