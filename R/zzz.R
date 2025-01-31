.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\n",
    "=== mediaPlanR: Planificación de Medios Publicitarios ===\n",
    "\nFunciones principales:\n",
    "\n1. Indicadores básicos:",
    "\n   - calc_grps(): Calcula el volumen de GRPs",
    "\n   - calc_cpm(): Calcula el nivel de CPM",
    "\n   - calcular_metricas_medios(): Calcular principales métricas",
    "\n",
    "\n2. Análisis de Cobertura y Frecuencia:",
    "\n   - calc_sainsbury(): Modelo Sainsbury",
    "\n   - calc_binomial(): Modelo Binomial",
    "\n   - calc_beta_binomial(): Modelo Beta-Binomial",
    "\n   - calc_metheringham(): Modelo Metheringham",
    "\n   - calc_hofmans(): Modelo Hofmans",
    "\n   - calc_MBBD(): Modelo MBBD",
    "\n   - calc_canex(): Modelo CANEX",
    "\n",
    "\n3. Optimización de Distribución de Contactos (d) y Acumulada (dc):",
    "\n   - optimizar_d(): Optimiza parámetros alpha y beta y n de la distribución de contactos",
    "\n   - optimizar_dc(): Optimiza parámetros alpha y beta y n de la distribución de contactos acumulada",
    "\n   - optimize_media_sb(): Optimización de planes de medios con restricciones",
    "\n",
    "\nPara ver ejemplos de uso:",
    "\n   help(\"calc_grps\")",
    "\n   help(\"calc_sainsbury\")",
    "\n   help(\"optimizar_d\")",
    "\n   help(\"optimizar_dc\")",
    "\n",
    "\nDocumentación completa disponible en:",
    "\n   https://github.com/majesus/mediaPlanR/mediaPlanR_manual.pdf",
    "\n",
    "\nVersión: ", utils::packageVersion(pkgname), "\n",
    "\n=================================================\n"
  )
}
