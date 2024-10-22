#' Calcula el reach usando el modelo de Sainsbury
#'
#' @param audiencias Vector numérico con las audiencias de cada soporte
#' @param poblacion_total Número total de la población objetivo
#'
#' @return Una lista con los siguientes elementos:
#' \itemize{
#'   \item reach$porcentaje: Reach total en porcentaje
#'   \item reach$personas: Reach total en número de personas
#'   \item distribucion$porcentaje: Vector con la distribución de contactos en porcentaje
#'   \item distribucion$personas: Vector con la distribución de contactos en personas
#'   \item acumulada$porcentaje: Vector con la distribución acumulada en porcentaje
#'   \item acumulada$personas: Vector con la distribución acumulada en personas
#' }
#' @export
#'
#' @examples
#' audiencias <- c(300000, 400000, 200000)
#' poblacion_total <- 1000000
#' resultado <- calc_sainsbury(audiencias, poblacion_total)
calc_sainsbury <- function(audiencias, poblacion_total) {
  # Validación de inputs
  if (!is.numeric(audiencias) || !is.numeric(poblacion_total)) {
    stop("Los argumentos deben ser numéricos")
  }
  if (any(audiencias < 0) || any(audiencias > poblacion_total)) {
    stop("Las audiencias deben ser positivas y menores que la población total")
  }
  if (poblacion_total <= 0) {
    stop("La población total debe ser positiva")
  }

  # Convertir audiencias a probabilidades
  probs <- audiencias / poblacion_total
  n <- length(probs)

  P <- numeric(n) # Distribución de contactos
  R <- numeric(n) # Distribución acumulada

  # Cálculo de la distribución de contactos (P)
  for(i in 1:n) {
    combs <- combn(n, i)
    P[i] <- sum(apply(combs, 2, function(idx) {
      prob <- 1
      for(j in 1:n) {
        if(j %in% idx) {
          prob <- prob * probs[j]
        } else {
          prob <- prob * (1 - probs[j])
        }
      }
      prob
    }))
  }

  # Cálculo de la distribución acumulada (R)
  for(i in 1:n) {
    R[i] <- sum(P[i:n])
  }

  # Cálculo del reach total
  reach <- 1 - prod(1 - probs)

  return(structure(list(
    reach = list(
      porcentaje = reach * 100,
      personas = reach * poblacion_total
    ),
    distribucion = list(
      porcentaje = P * 100,
      personas = P * poblacion_total
    ),
    acumulada = list(
      porcentaje = R * 100,
      personas = R * poblacion_total
    )
  ), class = "reach_sainsbury"))
}

#' Calcula el reach usando el modelo Binomial
#'
#' @param audiencias Vector numérico con las audiencias de cada soporte
#' @param poblacion_total Número total de la población objetivo
#'
#' @return Una lista con los siguientes elementos:
#' \itemize{
#'   \item reach$porcentaje: Reach total en porcentaje
#'   \item reach$personas: Reach total en número de personas
#'   \item distribucion$porcentaje: Vector con la distribución de contactos en porcentaje
#'   \item distribucion$personas: Vector con la distribución de contactos en personas
#'   \item acumulada$porcentaje: Vector con la distribución acumulada en porcentaje
#'   \item acumulada$personas: Vector con la distribución acumulada en personas
#'   \item probabilidad_media: Probabilidad media calculada
#' }
#' @export
#'
#' @examples
#' audiencias <- c(300000, 400000, 200000)
#' poblacion_total <- 1000000
#' resultado <- calc_binomial(audiencias, poblacion_total)
calc_binomial <- function(audiencias, poblacion_total) {
  # Validación de inputs
  if (!is.numeric(audiencias) || !is.numeric(poblacion_total)) {
    stop("Los argumentos deben ser numéricos")
  }
  if (any(audiencias < 0) || any(audiencias > poblacion_total)) {
    stop("Las audiencias deben ser positivas y menores que la población total")
  }
  if (poblacion_total <= 0) {
    stop("La población total debe ser positiva")
  }

  # Convertir audiencias a probabilidad media
  probs <- audiencias / poblacion_total
  p <- mean(probs)
  n <- length(audiencias)

  P <- numeric(n) # Distribución de contactos
  R <- numeric(n) # Distribución acumulada

  # Cálculo de la distribución de contactos (P)
  for(i in 1:n) {
    P[i] <- choose(n, i) * p^i * (1-p)^(n-i)
  }

  # Cálculo de la distribución acumulada (R)
  for(i in 1:n) {
    R[i] <- sum(P[i:n])
  }

  # Cálculo del reach total
  reach <- 1 - (1-p)^n

  return(structure(list(
    reach = list(
      porcentaje = reach * 100,
      personas = reach * poblacion_total
    ),
    distribucion = list(
      porcentaje = P * 100,
      personas = P * poblacion_total
    ),
    acumulada = list(
      porcentaje = R * 100,
      personas = R * poblacion_total
    ),
    probabilidad_media = p
  ), class = "reach_binomial"))
}

#' Calcula el reach usando el modelo Beta-Binomial
#'
#' @param A1 Numeric. Audiencia tras la primera inserción
#' @param A2 Numeric. Audiencia tras la segunda inserción
#' @param P Numeric. Población total objetivo
#' @param n Integer. Número de inserciones totales
#'
#' @return Una lista con los siguientes elementos:
#' \itemize{
#'   \item reach$porcentaje: Reach total en porcentaje
#'   \item reach$personas: Reach total en número de personas
#'   \item distribucion$porcentaje: Vector con la distribución de contactos en porcentaje
#'   \item distribucion$personas: Vector con la distribución de contactos en personas
#'   \item acumulada$porcentaje: Vector con la distribución acumulada en porcentaje
#'   \item acumulada$personas: Vector con la distribución acumulada en personas
#'   \item parametros: Lista con parámetros alpha, beta y probabilidad de cero contactos
#' }
#' @export
#'
#' @examples
#' resultado <- calc_beta_binomial(
#'   A1 = 500000,
#'   A2 = 550000,
#'   P = 1000000,
#'   n = 5
#' )
calc_beta_binomial <- function(A1, A2, P, n) {
  # Validación de inputs
  if (!all(is.numeric(c(A1, A2, P, n)))) {
    stop("Todos los argumentos deben ser numéricos")
  }
  if (A1 <= 0 || A2 <= 0 || P <= 0) {
    stop("Las audiencias y población deben ser positivas")
  }
  if (A1 > P || A2 > P) {
    stop("Las audiencias no pueden ser mayores que la población total")
  }
  if (n <= 0 || n != round(n)) {
    stop("El número de inserciones debe ser un entero positivo")
  }

  # Asegurar que n sea entero
  n <- as.integer(n)

  # Cálculo de R1 y R2
  R1 <- A1 / P
  R2 <- A2 / P

  # Cálculo de alpha y beta
  alpha <- (R1 * (R2 - R1)) / (2 * R1 - R1^2 - R2)
  beta <- (alpha * (1 - R1)) / R1

  # Validar que alpha y beta sean válidos
  if (is.na(alpha) || is.na(beta) || alpha <= 0 || beta <= 0) {
    stop("No se pudieron calcular parámetros válidos con los datos proporcionados")
  }

  # Función auxiliar para calcular la probabilidad beta-binomial
  dbetabinom <- function(x, n, alpha, beta) {
    choose(n, x) * beta(x + alpha, n - x + beta) / beta(alpha, beta)
  }

  # Cálculo de la distribución de contactos (P)
  P_dist <- sapply(0:n, function(k) dbetabinom(x = k, n = n, alpha = alpha, beta = beta))

  # Cálculo de la distribución acumulada (R)
  R_dist <- sapply(0:n, function(k) sum(P_dist[(k+1):length(P_dist)]))

  # El reach total es 1 menos la probabilidad de 0 contactos
  reach <- 1 - P_dist[1]

  # Eliminar el 0 de las distribuciones finales
  P_sin_cero <- P_dist[-1]
  R_sin_cero <- R_dist[-1]

  return(structure(list(
    reach = list(
      porcentaje = reach * 100,
      personas = reach * P
    ),
    distribucion = list(
      porcentaje = P_sin_cero * 100,
      personas = P_sin_cero * P
    ),
    acumulada = list(
      porcentaje = R_sin_cero * 100,
      personas = R_sin_cero * P
    ),
    parametros = list(
      alpha = alpha,
      beta = beta,
      prob_cero_contactos = P_dist[1] * 100
    )
  ), class = "reach_beta_binomial"))
}

#' @export
print.reach_sainsbury <- function(x, ...) {
  cat("Modelo Sainsbury\n")
  cat("---------------\n")
  cat(sprintf("Reach: %.2f%% (%.0f personas)\n",
              x$reach$porcentaje, x$reach$personas))
  cat("\nDistribución de contactos:\n")
  for(i in seq_along(x$distribucion$porcentaje)) {
    cat(sprintf("%d contactos: %.2f%% (%.0f personas)\n",
                i, x$distribucion$porcentaje[i], x$distribucion$personas[i]))
  }
  cat("\nDistribución acumulada:\n")
  for(i in seq_along(x$acumulada$porcentaje)) {
    cat(sprintf("%d o más contactos: %.2f%% (%.0f personas)\n",
                i, x$acumulada$porcentaje[i], x$acumulada$personas[i]))
  }
}

#' @export
print.reach_binomial <- function(x, ...) {
  cat("Modelo Binomial\n")
  cat("--------------\n")
  cat(sprintf("Reach: %.2f%% (%.0f personas)\n",
              x$reach$porcentaje, x$reach$personas))
  cat(sprintf("Probabilidad media: %.3f\n", x$probabilidad_media))
  cat("\nDistribución de contactos:\n")
  for(i in seq_along(x$distribucion$porcentaje)) {
    cat(sprintf("%d contactos: %.2f%% (%.0f personas)\n",
                i, x$distribucion$porcentaje[i], x$distribucion$personas[i]))
  }
  cat("\nDistribución acumulada:\n")
  for(i in seq_along(x$acumulada$porcentaje)) {
    cat(sprintf("%d o más contactos: %.2f%% (%.0f personas)\n",
                i, x$acumulada$porcentaje[i], x$acumulada$personas[i]))
  }
}

#' @export
print.reach_beta_binomial <- function(x, ...) {
  cat("Modelo Beta-Binomial\n")
  cat("-------------------\n")
  cat(sprintf("Reach: %.2f%% (%.0f personas)\n",
              x$reach$porcentaje, x$reach$personas))
  cat(sprintf("Parámetros: alpha=%.3f, beta=%.3f\n",
              x$parametros$alpha, x$parametros$beta))
  cat(sprintf("Probabilidad de 0 contactos: %.2f%%\n",
              x$parametros$prob_cero_contactos))
  cat("\nDistribución de contactos:\n")
  for(i in seq_along(x$distribucion$porcentaje)) {
    cat(sprintf("%d contactos: %.2f%% (%.0f personas)\n",
                i, x$distribucion$porcentaje[i], x$distribucion$personas[i]))
  }
  cat("\nDistribución acumulada:\n")
  for(i in seq_along(x$acumulada$porcentaje)) {
    cat(sprintf("%d o más contactos: %.2f%% (%.0f personas)\n",
                i, x$acumulada$porcentaje[i], x$acumulada$personas[i]))
  }
}

#__________________________________________________________#
