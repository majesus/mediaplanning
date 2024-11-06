#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function(timeout = 60) {
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

  # Configurar opciones
  old_options <- options()
  on.exit(options(old_options))

  options(
    install.packages.check.source = "no",
    install.packages.compile.from.source = "never",
    pkgType = "binary",
    timeout = timeout
  )

  # Función para instalar un solo paquete con timeout
  install_with_timeout <- function(pkg) {
    message("Intentando instalar ", pkg, "...")

    # Usar setTimeLimit para establecer un límite de tiempo
    result <- NULL
    tryCatch({
      setTimeLimit(elapsed = timeout, transient = TRUE)
      install.packages(pkg,
                       type = "binary",
                       dependencies = TRUE,
                       quiet = TRUE,
                       ask = FALSE,
                       force = TRUE)
      result <- TRUE
    }, error = function(e) {
      message("Error o timeout al instalar ", pkg, ": ", e$message)
      result <- FALSE
    }, finally = {
      setTimeLimit(cpu = Inf, elapsed = Inf)
    })
    return(result)
  }

  # Instalar paquetes
  for(pkg in required_packages) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      success <- install_with_timeout(pkg)
      if(!success) {
        warning("No se pudo instalar ", pkg, " dentro del tiempo límite.")
      }
    }
  }

  # Verificar instalaciones
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  if (length(missing_packages) > 0) {
    warning("Paquetes faltantes: ", paste(missing_packages, collapse = ", "))
    message("Sugerencia: Intenta instalar estos paquetes manualmente con:")
    message('install.packages(c("', paste(missing_packages, collapse = '", "'), '"), type = "binary")')
  } else {
    # Cargar paquetes principales solo si todo está instalado
    suppressMessages({
      library(shiny)
      library(bslib)
      library(ggplot2)
      library(dplyr)
      library(plotly)
    })
    message("Configuración completada exitosamente.")
  }
}
