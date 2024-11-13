

#' @encoding UTF-8
#' @title Modelo de Expansión Canónica para Distribuciones de Exposición a Medios
#' @description Implementa el modelo de expansión canónica desarrollado por Danaher (1991) para
#' calcular la distribución de contactos en planes de medios con múltiples inserciones por soporte.
#' El modelo considera las correlaciones entre soportes y permite estimar la cobertura y distribución
#' de contactos de manera más precisa que los modelos tradicionales al incorporar las dependencias
#' entre exposiciones.
#'
#' @references
#' Danaher, P. J. (1991). A canonical expansion model for multivariate media exposure distributions:
#' A generalization of the Duplication of Viewing Law. Journal of Marketing Research, 28(3), 361-367.
#'
#' @param marginal_probs Vector numérico con las probabilidades marginales de exposición por vehículo
#' @param correlations Matriz de correlaciones entre vehículos
#' @param insertions Vector numérico con el número de inserciones por vehículo
#' @param population Tamaño de la población objetivo (por defecto 1000000)
#' @param truncation_order Orden de truncación para la expansión canónica (por defecto 2).
#'        Controla cuántos términos de la expansión se incluyen en el cálculo.
#' @param tolerance Tolerancia numérica para validaciones (por defecto 1e-10).
#'        Define la precisión de las validaciones numéricas y cálculos.
#'
#' @details
#' El modelo de expansión canónica calcula:
#' \enumerate{
#'   \item Distribución conjunta de exposiciones considerando correlaciones entre soportes
#'   \item Distribución de contactos para cada nivel de exposición
#'   \item Métricas agregadas como cobertura total y GRPs
#' }
#'
#' El proceso incluye:
#' \itemize{
#'   \item Validación exhaustiva de inputs:
#'     \itemize{
#'       \item Verificación de dimensiones y consistencia entre inputs
#'       \item Validación de rangos (probabilidades entre 0 y 1)
#'       \item Verificación de matriz de correlaciones (simetría, semidefinida positiva)
#'       \item Control de tipos de datos y valores permitidos
#'     }
#'   \item Cálculo de variables canónicas según ecuaciones 2 y 3 del paper original
#'   \item Estimación de medias y varianzas para las distribuciones BBD marginales
#'   \item Cálculo de probabilidades conjuntas según ecuación 6
#'   \item Agregación de resultados en distribuciones de contactos y métricas
#' }
#'
#' La precisión numérica del modelo se controla mediante el parámetro tolerance,
#' que afecta tanto a las validaciones como a los cálculos internos.
#'
#' @return Una lista de clase "reach_canonical" conteniendo:
#' \itemize{
#'   \item reach: Lista con la cobertura:
#'     \itemize{
#'       \item porcentaje: Cobertura neta en porcentaje
#'       \item personas: Cobertura neta en número de personas
#'     }
#'   \item distribucion: Lista con la distribución de contactos:
#'     \itemize{
#'       \item porcentaje: Vector con probabilidad de cada número de exposiciones
#'       \item personas: Vector con número de personas para cada número de exposiciones
#'     }
#'   \item acumulada: Lista con la distribución acumulada:
#'     \itemize{
#'       \item porcentaje: Vector con probabilidades acumuladas
#'       \item personas: Vector con personas alcanzadas al menos N veces
#'     }
#'   \item parametros: Lista con parámetros del modelo:
#'     \itemize{
#'       \item probabilidad_media: Media de las probabilidades marginales
#'       \item correlaciones: Matriz de correlaciones entre soportes
#'       \item inserciones: Vector de inserciones por soporte
#'       \item prob_cero_contactos: Probabilidad de no exposición
#'       \item grps: Gross Rating Points totales
#'       \item bbd_params: Parámetros de las distribuciones Beta-Binomial para cada soporte
#'     }
#' }
#'
#' @examples
#' # Ejemplo básico con tres soportes
#' marginal_probs <- c(0.25, 0.20, 0.15)
#' correlations <- matrix(
#'   c(1.000, 0.085, 0.075,
#'     0.085, 1.000, 0.080,
#'     0.075, 0.080, 1.000),
#'   nrow = 3,
#'   byrow = TRUE
#' )
#' insertions <- c(8, 6, 4)
#' population <- 1000000
#'
#' # Ejemplo con parámetros por defecto
#' resultados <- canonical_expansion_model(
#'   marginal_probs = marginal_probs,
#'   correlations = correlations,
#'   insertions = insertions,
#'   population = population
#' )
#'
#' # Ejemplo con parámetros adicionales de control
#' resultados_precision <- canonical_expansion_model(
#'   marginal_probs = marginal_probs,
#'   correlations = correlations,
#'   insertions = insertions,
#'   population = population,
#'   truncation_order = 2,
#'   tolerance = 1e-10
#' )
#'
#' # Examinar los resultados
#' print(resultados)
#'
#' # Ejemplo con validación de datos
#' \dontrun{
#' # Matriz de correlaciones inválida
#' correlations_invalidas <- matrix(
#'   c(1.000, 0.085, 0.075,
#'     0.085, 1.000),
#'   nrow = 2,
#'   byrow = TRUE
#' )
#' resultados <- canonical_expansion_model(
#'   marginal_probs = marginal_probs,
#'   correlations = correlations_invalidas,
#'   insertions = insertions
#' )
#' # Generará un error por dimensiones incorrectas
#'
#' # Probabilidades marginales inválidas
#' probs_invalidas <- c(1.2, 0.2, 0.15)
#' resultados <- canonical_expansion_model(
#'   marginal_probs = probs_invalidas,
#'   correlations = correlations,
#'   insertions = insertions
#' )
#' # Generará un error por probabilidades fuera de rango
#' }
#'
#' @export
#' @seealso
#' \code{\link{calc_sainsbury}} para estimaciones con duplicación aleatoria
#' \code{\link{calc_binomial}} para estimaciones con la distribución Binomial
#' \code{\link{calc_beta_binomial}} para estimaciones con la distribución Beta-Binomial
#' \code{\link{calc_metheringham}} para estimaciones con la distribución de Metheringham
#' \code{\link{calc_hofmans}} para estimaciones con la distribución de Hofmans

canonical_expansion_model <- function(marginal_probs,
                                      correlations,
                                      insertions,
                                      population = 1000000,
                                      truncation_order = 2,
                                      tolerance = 1e-10) {

  # Validaciones exhaustivas de entrada
  validate_inputs <- function() {
    # Validar dimensiones
    n_vehicles <- length(marginal_probs)
    if (length(insertions) != n_vehicles) {
      stop("La longitud de marginal_probs y insertions debe coincidir")
    }
    if (!all(dim(correlations) == c(n_vehicles, n_vehicles))) {
      stop("Las dimensiones de la matriz de correlaciones deben coincidir con el número de vehículos")
    }

    # Validar tipos y rangos
    if (!is.numeric(marginal_probs) || !is.numeric(insertions) || !is.numeric(correlations)) {
      stop("Todos los inputs deben ser numéricos")
    }
    if (any(marginal_probs < 0 - tolerance | marginal_probs > 1 + tolerance)) {
      stop("Las probabilidades marginales deben estar entre 0 y 1")
    }
    if (any(insertions < 0 | insertions != round(insertions))) {
      stop("Las inserciones deben ser números enteros no negativos")
    }

    # Validar matriz de correlaciones
    if (!isSymmetric(correlations, tol = tolerance)) {
      stop("La matriz de correlaciones debe ser simétrica")
    }
    if (any(abs(diag(correlations) - 1) > tolerance)) {
      stop("La diagonal de la matriz de correlaciones debe ser 1")
    }
    if (any(abs(correlations) > 1 + tolerance)) {
      stop("Las correlaciones deben estar entre -1 y 1")
    }
    eigen_values <- eigen(correlations, symmetric = TRUE)$values
    if (any(eigen_values < -tolerance)) {
      stop("La matriz de correlaciones debe ser semidefinida positiva")
    }
  }

  # Ejecutar validaciones
  validate_inputs()

  # Pre-cálculo de parámetros BBD usando vectorización
  calc_bbd_params <- function(p, k) {
    alpha <- p * (1/k - 1)
    beta <- (1 - p) * (1/k - 1)
    mean <- k * alpha / (alpha + beta)
    variance <- k * alpha * beta * (alpha + beta + k) /
      ((alpha + beta)^2 * (alpha + beta + 1))
    list(
      alpha = alpha,
      beta = beta,
      mean = mean,
      variance = variance
    )
  }

  # Vectorizar cálculos BBD
  bbd_params <- Map(calc_bbd_params,
                    marginal_probs,
                    insertions)

  # Extraer medias y varianzas para uso eficiente
  means <- vapply(bbd_params, function(x) x$mean, numeric(1))
  sds <- sqrt(vapply(bbd_params, function(x) x$variance, numeric(1)))

  # Optimizar cálculo de variables canónicas usando matrices
  calc_canonical_matrix <- function(x_values) {
    sweep(sweep(x_values, 2, means, "-"), 2, sds, "/")
  }

  # Generar patrones de exposición eficientemente
  generate_patterns <- function() {
    patterns <- do.call(expand.grid,
                        lapply(insertions, function(k) 0:k))
    as.matrix(patterns)
  }

  # Calcular probabilidad conjunta optimizada
  calc_joint_prob <- function(x_values) {
    # Probabilidad base usando producto vectorizado
    base_prob <- prod(mapply(function(p, k, x) {
      stats::dbinom(x, k, p)
    }, marginal_probs, insertions, x_values))

    # Términos de correlación usando álgebra matricial
    canonical_vars <- calc_canonical_matrix(matrix(x_values, nrow = 1))

    corr_terms <- 0
    n_vehicles <- length(marginal_probs)

    # Optimizar suma de términos de correlación
    if (truncation_order >= 2) {
      for (i in 1:(n_vehicles-1)) {
        for (j in (i+1):n_vehicles) {
          corr_terms <- corr_terms +
            correlations[i,j] * canonical_vars[1,i] * canonical_vars[1,j]
        }
      }
    }

    # Asegurar probabilidad válida
    prob <- base_prob * (1 + corr_terms)
    pmax(0, pmin(1, prob))
  }

  # Generar distribución completa
  patterns <- generate_patterns()
  max_contacts <- sum(insertions)

  # Vectorizar cálculo de distribución
  contact_dist <- numeric(max_contacts + 1)
  pattern_probs <- apply(patterns, 1, calc_joint_prob)
  pattern_contacts <- rowSums(patterns)

  # Agregar probabilidades por número de contactos
  for (i in 0:max_contacts) {
    contact_dist[i + 1] <- sum(pattern_probs[pattern_contacts == i])
  }

  # Validar distribución final
  if (abs(sum(contact_dist) - 1) > tolerance) {
    warning("La distribución no suma exactamente 1. Diferencia: ",
            abs(sum(contact_dist) - 1))
    # Normalizar si es necesario
    contact_dist <- contact_dist / sum(contact_dist)
  }

  # Calcular métricas finales
  net_reach <- 1 - contact_dist[1]
  total_contacts <- sum(seq(0, max_contacts) * contact_dist)
  grps <- total_contacts * 100

  # Retornar estructura de resultados
  structure(list(
    reach = list(
      porcentaje = net_reach * 100,
      personas = net_reach * population
    ),
    distribucion = list(
      porcentaje = contact_dist[-1] * 100,
      personas = contact_dist[-1] * population
    ),
    acumulada = list(
      porcentaje = cumsum(rev(contact_dist[-1])) * 100,
      personas = cumsum(rev(contact_dist[-1])) * population
    ),
    parametros = list(
      probabilidad_media = mean(marginal_probs),
      correlaciones = correlations,
      inserciones = insertions,
      prob_cero_contactos = contact_dist[1] * 100,
      grps = grps,
      bbd_params = bbd_params
    )
  ), class = "reach_canonical")
}

#' @export
#' @method print reach_canonical
#' @title Método de Impresión para Objetos reach_canonical
#' @description Imprime un resumen formateado de los resultados del modelo de expansión canónica,
#' incluyendo las métricas principales (cobertura, GRPs), información del plan (número de soportes,
#' inserciones), distribución de contactos y distribución acumulada.
#'
#' @param x Objeto de clase reach_canonical a imprimir
#' @param digits Número de decimales para los valores porcentuales (por defecto 2)
#' @param ... Argumentos adicionales pasados a otros métodos (no utilizados actualmente)
#'
#' @details
#' El método de impresión organiza la información en secciones:
#' \itemize{
#'   \item Métricas principales: cobertura, GRPs, probabilidades medias
#'   \item Información del plan: número de soportes e inserciones
#'   \item Distribución de contactos: porcentaje y número de personas por nivel
#'   \item Distribución acumulada: porcentaje y personas con N o más contactos
#'   \item Resumen estadístico: promedios y ratios relevantes
#' }
#'
#' Los valores numéricos se formatean según estas reglas:
#' \itemize{
#'   \item Porcentajes: Redondeados a 2 decimales por defecto
#'   \item Personas: Redondeadas sin decimales
#'   \item GRPs: Redondeados a 1 decimal
#'   \item Probabilidades: Redondeadas a 3 decimales
#' }
#'
#' @return No retorna ningún valor, imprime el resumen en la consola
#'
#' @examples
#' marginal_probs <- c(0.25, 0.20, 0.15)
#' correlations <- matrix(
#'   c(1.000, 0.085, 0.075,
#'     0.085, 1.000, 0.080,
#'     0.075, 0.080, 1.000),
#'   nrow = 3,
#'   byrow = TRUE
#' )
#' insertions <- c(8, 6, 4)
#' resultados <- canonical_expansion_model(
#'   marginal_probs = marginal_probs,
#'   correlations = correlations,
#'   insertions = insertions
#' )
#' print(resultados)  # Impresión con formato por defecto
#' print(resultados, digits = 3)  # Impresión con 3 decimales

print.reach_canonical <- function(x, digits = 2, ...) {
  # Validar el objeto
  if (!inherits(x, "reach_canonical")) {
    stop("El objeto debe ser de clase 'reach_canonical'")
  }

  # Funciones auxiliares de formato
  format_percent <- function(value, d = digits) {
    sprintf(paste0("%.", d, "f%%"), value)
  }

  format_number <- function(value) {
    format(round(value), big.mark = ",", scientific = FALSE)
  }

  # Encabezado
  cat("\nMODELO DE EXPANSIÓN CANÓNICA (DANAHER)\n")
  cat(paste(rep("=", 38), collapse = ""), "\n")
  cat("Descripción: Modelo que considera correlaciones entre soportes y múltiples inserciones\n\n")

  # Métricas principales
  cat("MÉTRICAS PRINCIPALES:\n")
  cat(paste(rep("-", 20), collapse = ""), "\n")
  cat(sprintf("Cobertura total: %s (%s personas)\n",
              format_percent(x$reach$porcentaje),
              format_number(x$reach$personas)))
  cat(sprintf("GRPs: %.1f\n", x$parametros$grps))
  cat(sprintf("Probabilidad media de exposición: %.3f\n",
              x$parametros$probabilidad_media))
  cat(sprintf("Probabilidad de 0 contactos: %s\n",
              format_percent(x$parametros$prob_cero_contactos)))

  # Información del plan
  cat("\nINFORMACIÓN DEL PLAN:\n")
  cat(paste(rep("-", 20), collapse = ""), "\n")
  n_soportes <- length(x$parametros$inserciones)
  cat(sprintf("Número de soportes: %d\n", n_soportes))
  cat(sprintf("Total inserciones: %d\n", sum(x$parametros$inserciones)))
  cat("Inserciones por soporte:\n")
  for (i in seq_len(n_soportes)) {
    cat(sprintf("  Soporte %d: %d inserción(es)\n",
                i, x$parametros$inserciones[i]))
  }

  # Distribución de contactos
  cat("\nDISTRIBUCIÓN DE CONTACTOS:\n")
  cat(paste(rep("-", 25), collapse = ""), "\n")
  cat("(Porcentaje de población que recibe exactamente N contactos)\n")
  for(i in seq_along(x$distribucion$porcentaje)) {
    cat(sprintf("%2d contacto%s: %s (%s personas)\n",
                i, ifelse(i == 1, " ", "s"),
                format_percent(x$distribucion$porcentaje[i]),
                format_number(x$distribucion$personas[i])))
  }

  # Distribución acumulada
  cat("\nDISTRIBUCIÓN ACUMULADA:\n")
  cat(paste(rep("-", 22), collapse = ""), "\n")
  cat("(Porcentaje de población que recibe N o más contactos)\n")
  for(i in seq_along(x$acumulada$porcentaje)) {
    cat(sprintf("≥%2d contacto%s: %s (%s personas)\n",
                i, ifelse(i == 1, " ", "s"),
                format_percent(x$acumulada$porcentaje[i]),
                format_number(x$acumulada$personas[i])))
  }

  # Resumen estadístico
  cat("\nRESUMEN ESTADÍSTICO:\n")
  cat(paste(rep("-", 19), collapse = ""), "\n")
  total_contactos <- sum(seq_along(x$distribucion$porcentaje) *
                           x$distribucion$personas)
  poblacion_alcanzada <- sum(x$distribucion$personas)
  contactos_promedio <- if (poblacion_alcanzada > 0) {
    total_contactos / poblacion_alcanzada
  } else {
    0
  }

  cat(sprintf("Promedio de contactos por individuo alcanzado: %.2f\n",
              contactos_promedio))
  cat(sprintf("GRPs por inserción: %.1f\n",
              x$parametros$grps / sum(x$parametros$inserciones)))

  invisible(x)
}



