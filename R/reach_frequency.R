#' Calcula el alcance y la frecuencia
#'
#' Esta función calcula el alcance y la frecuencia de una campaña publicitaria
#' basándose en el número de impresiones y el tamaño de la audiencia.
#'
#' @param impresiones Número total de impresiones de la campaña
#' @param audiencia Tamaño total de la audiencia objetivo
#' @return Una lista con el alcance (en porcentaje) y la frecuencia media
#' @export
#'
#' @examples
#' reach_frequency(1000000, 500000)
reach_frequency <- function(impresiones, audiencia) {
  alcance <- 1 - exp(-impresiones / audiencia)
  frecuencia <- impresiones / (alcance * audiencia)

  return(list(
    alcance = alcance * 100,  # Convertir a porcentaje
    frecuencia = frecuencia
  ))
}



#' Calcula R1 y R2 a partir de los parámetros A y B
#'
#' @param A Numeric. Valor del parámetro A.
#' @param B Numeric. Valor del parámetro B.
#'
#' @return Una lista con los valores de R1 y R2.
#' @export
#'
#' @examples
#' calcular_R1_R2(A = 0.5, B = 0.3)
calcular_R1_R2 <- function(A, B) {

  # Validar que A y B sean numéricos y positivos
  if (!is.numeric(A) || !is.numeric(B) || A <= 0 || B <= 0) {
    stop("A y B deben ser numéricos y positivos.")
  }

  # Despejar R1 de la segunda ecuación
  R1 <- A / (A + B)

  # Función objetivo para encontrar R2 numéricamente
  objetivo_R2 <- function(R2) {
    (A - (R1 * (R2 - R1)) / (2 * R1 - R1^2 - R2))^2
  }

  # Encontrar el valor de R2 que minimiza el error
  resultado <- optimize(objetivo_R2, c(0, 1))

  # Obtener el valor de R2
  R2 <- resultado$minimum

  # Retornar los valores de R1 y R2
  return(list(R1 = R1, R2 = R2))
}

#' Optimiza la distribución de contactos y calcula R1 y R2
#'
#' Esta función optimiza la distribución de contactos y calcula los valores de R1 y R2
#' en función de los parámetros proporcionados.
#'
#' @param POB Numeric. Tamaño de la población objetivo.
#' @param Pi Numeric. Valor objetivo de distribución de contactos Pi.
#' @param valor_objetivo Numeric. Número de personas a alcanzar Pi veces.
#' @param salto_A Numeric. Paso para el rango de probabilidad alpha.
#' @param salto_B Numeric. Paso para el rango de probabilidad beta.
#'
#' @return Data frame con las combinaciones óptimas de x, alpha, R1, R2, y prob.
#' @export
#'
#' @examples
#' optimizar_y_calcular(POB = 1000000, Pi = 3, valor_objetivo = 0.043, salto_A = 0.125, salto_B = 0.125)
optimizar_y_calcular <- function(POB, Pi, valor_objetivo, salto_A = 0.025, salto_B = 0.025) {

  #___________________________________#
  options(lazyLoad = FALSE)
  # Comprobar si el paquete 'extraDistr' está disponible e instalarlo si no lo está
  if (!requireNamespace("extraDistr", quietly = TRUE)) {
    install.packages("extraDistr")
  }
  # Cargar el paquete
  library(extraDistr)
  #___________________________________#

  # Validación de entrada
  if (!is.numeric(POB) || !is.numeric(Pi) || !is.numeric(valor_objetivo)) {
    stop("Todos los parámetros deben ser numéricos.")
  }
  if (POB <= 0 || Pi <= 0 || valor_objetivo <= 0) {
    stop("Todos los parámetros deben ser positivos.")
  }
  if (valor_objetivo > POB) {
    stop("El valor objetivo no puede ser mayor que la población.")
  }

  # Cálculo de la tolerancia
  tolerancia <- valor_objetivo * 0.05

  # Definición de rangos para los parámetros
  rangos_size <- seq(Pi, Pi + 3, 1)  # Rango para x (contactos)
  rangos_prob1 <- seq(0.001, 1, salto_A)   # Rango para alpha
  rangos_prob2 <- seq(0.001, 1, salto_B)   # Rango para beta

  # Generar todas las combinaciones posibles de x, alpha y beta
  combinaciones <- expand.grid(x = rangos_size, alpha = rangos_prob1, beta = rangos_prob2)

  # Calcular probabilidades con vectorización usando mapply
  probs <- mapply(function(x, alpha, beta) {
    extraDistr::dbbinom(x = x, size = 5, alpha = alpha, beta = beta)
  }, combinaciones$x, combinaciones$alpha, combinaciones$beta)

  # Filtrar combinaciones que cumplen el criterio
  indices <- which(abs(valor_objetivo - probs) <= tolerancia)

  # Resultados filtrados
  mejores_combinaciones <- combinaciones[indices, ]

  # Calcular R1 y R2 para cada combinación de alpha y beta
  resultados <- mapply(function(alpha, beta) {
    res <- calcular_R1_R2(A = alpha, B = beta)
    return(c(R1 = res$R1, R2 = res$R2))
  }, mejores_combinaciones$alpha, mejores_combinaciones$beta, SIMPLIFY = FALSE)

  # Convertir lista de resultados a data frame
  resultados_df <- do.call(rbind, resultados)
  mejores_combinaciones <- cbind(mejores_combinaciones, resultados_df)

  # Ajustar las probabilidades multiplicadas por la población
  mejores_combinaciones$prob <- round(probs[indices] * POB, 0)

  # Retornar el data frame con los resultados
  return(mejores_combinaciones)
}

