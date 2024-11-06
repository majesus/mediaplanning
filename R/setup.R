#' Configurar MediaPlanR
#' @export
setup_mediaPlanR <- function() {
  message("Iniciando configuración de MediaPlanR...")

  # Guardar opciones originales
  old <- options()
  on.exit(options(old))

  # Forzar CRAN espejo específico y binarios
  options(repos = getOption("repos")["CRAN"])
  if (is.na(options()$repos["CRAN"])) {
    options(repos = c(CRAN = "https://cran.rstudio.com/"))
  }

  # Desactivar TODAS las actualizaciones y preguntas
  options(install.packages.compile.from.source = "never")
  options(install.packages.check.source = FALSE)
  options(checkBuilt = FALSE)
  options(askYesNo = FALSE)
  options(menu = FALSE)

  # Lista de paquetes necesarios con sus dependencias explícitas
  pkg_deps <- list(
    fastmap = "1.1.1",
    cachem = "1.0.8",
    shiny = "1.7.5",
    bslib = "0.5.1",
    ggplot2 = "3.4.4",
    dplyr = "1.1.3",
    plotly = "4.10.3"
  )

  # Instalar cada paquete individualmente con sus versiones específicas
  for(pkg in names(pkg_deps)) {
    if(!requireNamespace(pkg, quietly = TRUE)) {
      message(sprintf("Instalando %s versión %s ...", pkg, pkg_deps[[pkg]]))
      try({
        utils::install.packages(
          pkg,
          type = "binary",
          quiet = TRUE,
          dependencies = TRUE,
          ask = FALSE,
          checkBuilt = FALSE,
          INSTALL_opts = c("--no-docs", "--no-demo", "--no-test-load")
        )
      }, silent = TRUE)
    }
  }

  # Verificar instalaciones
  missing <- names(pkg_deps)[!sapply(names(pkg_deps), requireNamespace, quietly = TRUE)]
  if(length(missing) > 0) {
    stop("No se pudieron instalar los siguientes paquetes: ",
         paste(missing, collapse = ", "))
  }

  message("Configuración completada exitosamente.")

  # Cargar paquetes principales sin mensajes
  suppressMessages({
    library(shiny)
    library(bslib)
    library(ggplot2)
    library(dplyr)
    library(plotly)
  })
}

# Para instalar manualmente un solo paquete sin prompts:
install_package_no_prompt <- function(pkg) {
  options(install.packages.compile.from.source = "never",
          install.packages.check.source = FALSE,
          checkBuilt = FALSE,
          askYesNo = FALSE,
          menu = FALSE)

  utils::install.packages(
    pkg,
    type = "binary",
    quiet = TRUE,
    dependencies = TRUE,
    ask = FALSE,
    checkBuilt = FALSE,
    INSTALL_opts = c("--no-docs", "--no-demo", "--no-test-load")
  )
}
