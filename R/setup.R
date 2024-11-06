#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Desactivar las actualizaciones automáticas
  if(!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", type = "binary", dependencies = FALSE, quiet = TRUE)
  }

  # Instalar versiones específicas de los paquetes de dependencia
  suppressWarnings({
    remotes::install_version("fastmap", version = "1.1.1", type = "binary", dependencies = FALSE, quiet = TRUE)
    remotes::install_version("cachem", version = "1.0.8", type = "binary", dependencies = FALSE, quiet = TRUE)
    remotes::install_version("shiny", version = "1.7.5", type = "binary", dependencies = FALSE, quiet = TRUE)
  })

  # Lista del resto de paquetes con versiones específicas
  pkg_versions <- c(
    "bslib" = "0.5.1",
    "ggplot2" = "3.4.4",
    "dplyr" = "1.1.3",
    "plotly" = "4.10.3",
    "tidyr" = "1.3.0",
    "tibble" = "3.2.1",
    "purrr" = "1.0.2",
    "magrittr" = "2.0.3",
    "scales" = "1.2.1",
    "DT" = "0.31",
    "readr" = "2.1.4"
  )

  # Instalar cada paquete solo si no está instalado
  for(pkg in names(pkg_versions)) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      message("Instalando ", pkg, " versión ", pkg_versions[pkg], "...")
      suppressWarnings({
        remotes::install_version(pkg,
                                 version = pkg_versions[pkg],
                                 type = "binary",
                                 dependencies = FALSE,
                                 quiet = TRUE)
      })
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

#' @export
run_mediaPlanR <- function(app = c("beta", "aud", "reach")) {
  app <- match.arg(app)
  if(!requireNamespace("shiny", quietly = TRUE) ||
     !requireNamespace("bslib", quietly = TRUE)) {
    setup_mediaPlanR()
  }
  switch(app,
         "beta" = run_beta_binomial_explorer(),
         "aud" = run_aud_util_explorer(),
         "reach" = run_reach_converg_explorer())
}
