

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
                                      population = 10000000,
                                      truncation_order = 2,
                                      tolerance = 1e-10) {

  #' Valida y extrae correlaciones únicas de una matriz de correlaciones
  #' @param correlations Matriz numérica de correlaciones
  #' @param tolerance Tolerancia numérica para validaciones
  #' @return Lista con validación y DataFrame de correlaciones únicas
  validate_and_extract_correlations <- function(correlations, tolerance = 1e-10) {
    if (!is.matrix(correlations) || !is.numeric(correlations)) {
      stop("correlations debe ser una matriz numérica")
    }

    n_vehicles <- nrow(correlations)
    if (nrow(correlations) != ncol(correlations)) {
      stop("La matriz de correlaciones debe ser cuadrada")
    }

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

    expected_pairs <- (n_vehicles * (n_vehicles - 1)) / 2

    correlation_pairs <- data.frame(
      vehicle1 = integer(expected_pairs),
      vehicle2 = integer(expected_pairs),
      correlation = numeric(expected_pairs),
      stringsAsFactors = FALSE
    )

    pair_idx <- 1
    for(i in 1:(n_vehicles-1)) {
      for(j in (i+1):n_vehicles) {
        correlation_pairs[pair_idx,] <- list(i, j, correlations[i,j])
        pair_idx <- pair_idx + 1
      }
    }

    actual_pairs <- nrow(correlation_pairs)
    if(actual_pairs != expected_pairs) {
      stop(sprintf(
        "Número incorrecto de pares de correlación. Esperado: %d, Encontrado: %d",
        expected_pairs, actual_pairs
      ))
    }

    if(any(correlation_pairs$vehicle1 >= correlation_pairs$vehicle2)) {
      stop("Error en extracción: se incluyó un par duplicado o diagonal")
    }

    diagnostics <- list(
      n_vehicles = n_vehicles,
      n_pairs = actual_pairs,
      correlation_range = range(correlation_pairs$correlation),
      eigen_values = eigen_values
    )

    return(list(
      correlation_pairs = correlation_pairs,
      diagnostics = diagnostics
    ))
  }

  #' Validación y ordenamiento de inputs principales
  #' @return Lista con datos validados y ordenados
  validate_and_order_inputs <- function(marginal_probs, correlations, insertions) {
    n_vehicles <- length(marginal_probs)
    if (!is.numeric(marginal_probs) || !is.numeric(insertions)) {
      stop("marginal_probs e insertions deben ser numéricos")
    }
    if (length(insertions) != n_vehicles) {
      stop("La longitud de marginal_probs y insertions debe coincidir")
    }

    if (any(marginal_probs < 0 - tolerance | marginal_probs > 1 + tolerance)) {
      stop("Las probabilidades marginales deben estar entre 0 y 1")
    }
    if (any(insertions < 0 | insertions != round(insertions))) {
      stop("Las inserciones deben ser números enteros no negativos")
    }

    corr_result <- validate_and_extract_correlations(correlations, tolerance)

    vehicle_data <- data.frame(
      original_index = 1:n_vehicles,
      prob = marginal_probs,
      insertions = insertions,
      stringsAsFactors = FALSE
    )

    return(list(
      vehicle_data = vehicle_data,
      correlation_pairs = corr_result$correlation_pairs,
      correlation_diagnostics = corr_result$diagnostics,
      n_vehicles = n_vehicles
    ))
  }

  #' Cálculo de parámetros BBD
  #' @param vehicle_data DataFrame con datos de vehículos
  #' @return Lista de parámetros BBD por vehículo
  calc_bbd_params <- function(vehicle_data) {
    lapply(1:nrow(vehicle_data), function(i) {
      p <- vehicle_data$prob[i]
      k <- vehicle_data$insertions[i]
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
    })
  }

  #' Cálculo de matriz canónica
  #' @return Matriz de variables canónicas normalizadas
  calc_canonical_matrix <- function(x_values, vehicle_data, bbd_params) {
    means <- sapply(bbd_params, function(x) x$mean)
    sds <- sqrt(sapply(bbd_params, function(x) x$variance))
    sweep(sweep(x_values, 2, means, "-"), 2, sds, "/")
  }

  #' Cálculo de probabilidad conjunta
  #' @return Probabilidad conjunta para un patrón de exposición
  calc_joint_prob <- function(x_values, vehicle_data, correlation_pairs, bbd_params) {
    base_prob <- prod(mapply(function(p, k, x) {
      stats::dbinom(x, k, p)
    }, vehicle_data$prob, vehicle_data$insertions, x_values))

    canonical_vars <- calc_canonical_matrix(matrix(x_values, nrow = 1),
                                            vehicle_data,
                                            bbd_params)

    corr_terms <- 0
    if (truncation_order >= 2) {
      for(i in 1:nrow(correlation_pairs)) {
        v1 <- correlation_pairs$vehicle1[i]
        v2 <- correlation_pairs$vehicle2[i]
        corr <- correlation_pairs$correlation[i]

        corr_terms <- corr_terms +
          corr * canonical_vars[1,v1] * canonical_vars[1,v2]
      }
    }

    prob <- base_prob * (1 + corr_terms)
    pmax(0, pmin(1, prob))
  }

  #' Genera todos los patrones posibles de exposición
  generate_patterns <- function(vehicle_data) {
    do.call(expand.grid,
            lapply(vehicle_data$insertions, function(k) 0:k))
  }

  # Proceso principal
  ordered_data <- validate_and_order_inputs(marginal_probs, correlations, insertions)
  bbd_params <- calc_bbd_params(ordered_data$vehicle_data)
  patterns <- as.matrix(generate_patterns(ordered_data$vehicle_data))
  max_contacts <- sum(ordered_data$vehicle_data$insertions)

  # Calcular distribución
  contact_dist <- numeric(max_contacts + 1)
  pattern_probs <- apply(patterns, 1, function(x) {
    calc_joint_prob(x, ordered_data$vehicle_data,
                    ordered_data$correlation_pairs, bbd_params)
  })
  pattern_contacts <- rowSums(patterns)

  for (i in 0:max_contacts) {
    contact_dist[i + 1] <- sum(pattern_probs[pattern_contacts == i])
  }

  suma_dist <- sum(contact_dist, na.rm = TRUE)
  if (!is.na(suma_dist) && abs(suma_dist - 1) > tolerance) {
    warning("La distribución no suma exactamente 1. Diferencia: ",
            abs(suma_dist - 1))
    contact_dist <- contact_dist / suma_dist
  }

  net_reach <- 1 - contact_dist[1]
  total_contacts <- sum(seq(0, max_contacts) * contact_dist)
  grps <- total_contacts * 100

  acum_dist <- numeric(max_contacts)
  for(i in 1:max_contacts) {
    acum_dist[i] <- sum(contact_dist[(i+1):(max_contacts+1)])
  }

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
      porcentaje = acum_dist * 100,
      personas = acum_dist * population
    ),
    parametros = list(
      probabilidad_media = mean(marginal_probs),
      correlaciones = correlations,
      inserciones = insertions,
      prob_cero_contactos = contact_dist[1] * 100,
      grps = grps,
      bbd_params = bbd_params,
      max_contactos = max_contacts,
      correlation_diagnostics = ordered_data$correlation_diagnostics
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
