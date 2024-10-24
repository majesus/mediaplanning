.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\n",
    "=== mediaPlanR: Planificación y Análisis de Medios ===\n",
    "\nFunciones principales:\n",
    "\n1. Análisis de Cobertura y Frecuencia:",
    "\n   - calc_sainsbury(): Modelo Sainsbury para múltiples soportes, una inserción por soporte",
    "\n   - calc_binomial(): Modelo Binomial para múltiples soportes, una inserción por soporte",
    "\n   - calc_beta_binomial(): Modelo Beta-Binomial para un soporte y n inserciones",
    "\n   - calc_metheringham(): Modelo Metheringham para m soportes y ni inserciones",
    "\n",
    "\n2. Optimización de Distribución de Contactos (d) y Acumulada (dc):",
    "\n   - optimizar_d(): Optimiza parámetros para distribución de contactos",
    "\n   - optimizar_dc(): Optimiza distribución de contactos acumulada",
    "\n",
    "\nPara ver ejemplos de uso:",
    "\n   help(\"calc_sainsbury\")",
    "\n   help(\"optimizar_d\")",
    "\n   help(\"calc_grps\")",
    "\n",
    "\nVersionión: ", utils::packageVersion(pkgname), "\n",
    "\n=================================================\n"
  )
}
