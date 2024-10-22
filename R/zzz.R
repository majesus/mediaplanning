.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\n",
    "=== mediaPlanR: Planificación y Análisis de Medios ===\n",
    "\nFunciones principales:\n",
    "\n1. Análisis de Reach y Frecuencia:",
    "\n   - reach_frequency(): Calcula alcance y frecuencia de una campaña",
    "\n   - calc_sainsbury(): Modelo Sainsbury para múltiples soportes",
    "\n   - calc_binomial(): Modelo Binomial para distribución de contactos",
    "\n   - calc_beta_binomial(): Modelo Beta-Binomial para distribución de contactos",
    "\n",
    "\n2. Optimización de Distribución:",
    "\n   - optimizar_d(): Optimiza parámetros para distribución de contactos",
    "\n   - optimizar_dc(): Optimiza distribución de contactos acumulada",
    "\n",
    "\nPara ver ejemplos de uso:",
    "\n   help(\"reach_frequency\")",
    "\n   help(\"calc_sainsbury\")",
    "\n   help(\"optimizar_d\")",
    "\n",
    "\nVersionión: ", utils::packageVersion(pkgname), "\n",
    "\n=================================================\n"
  )
}