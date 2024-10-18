#__________________________________________________________#

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

#__________________________________________________________#

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

#__________________________________________________________#

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
optimizar_y_calcular <- function(POB,
                                 Pi,
                                 tolerancia = 0.05,
                                 valor_objetivo,
                                 salto_A = 0.025,
                                 salto_B = 0.025,
                                 n = 5) {

  #___________________________________#
  options(lazyLoad = FALSE)
  # Comprobar si el paquete 'extraDistr' está disponible e instalarlo si no lo está
  if (!requireNamespace("extraDistr", quietly = TRUE)) {
    install.packages("extraDistr")
  }
  # Cargar el paquete
  library(extraDistr)
  library(ggplot2)  # Necesario para gráficos
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
  valor_objetivo <- valor_objetivo / POB
  tolerancia <- valor_objetivo * tolerancia

  # Definición de rangos para los parámetros
  rangos_size <- seq(Pi, Pi + 3, 1)  # Rango para x (contactos)
  rangos_prob1 <- seq(0.001, 1, salto_A)   # Rango para alpha
  rangos_prob2 <- seq(0.001, 1, salto_B)   # Rango para beta

  # Generar todas las combinaciones posibles de x, alpha y beta
  combinaciones <- expand.grid(x = rangos_size,
                               alpha = rangos_prob1,
                               beta = rangos_prob2)

  # Calcular probabilidades con vectorización usando mapply
  probs <- mapply(function(x, alpha, beta) {
    extraDistr::dbbinom(x = x, size = n, alpha = alpha, beta = beta)
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

  # Añadir un asterisco cuando R2 > 2 * R1
  mejores_combinaciones$flag <- ifelse(mejores_combinaciones$R2 > 2 * mejores_combinaciones$R1, "*", "")

  # Ajustar las probabilidades multiplicadas por la población
  mejores_combinaciones$prob <- round(probs[indices] * POB, 0)

  # Crear la columna de distancia con respecto al valor objetivo
  mejores_combinaciones$distancia_objetivo <- abs(valor_objetivo - mejores_combinaciones$prob)

  # Ordenar primero por el número de inserciones (x) y luego por la distancia al valor objetivo
  mejores_combinaciones <- mejores_combinaciones[order(mejores_combinaciones$x,
                                                       mejores_combinaciones$distancia_objetivo), ]

  # Mostrar la tabla con las mejores combinaciones ordenadas
  print(mejores_combinaciones)


  # Añadir un pie de tabla como mensaje adicional
  cat("\n* Indica que R2 es más del doble que R1, lo que sugiere que la propuesta no es viable.\n")

  # Elegir la combinación principal (primera fila)
  principal <- mejores_combinaciones[1, ]
  alpha <- principal$alpha
  beta <- principal$beta

  # Calcular las probabilidades para la distribución beta binomial con la solución principal
  distribucion <- extraDistr::dbbinom(0:n, size = n, alpha = alpha, beta = beta)

  # Crear el dataframe con las probabilidades acumuladas de 1 a n, 2 a n, etc.
  acumuladas <- sapply(1:n, function(k) sum(distribucion[(k + 1):(n + 1)]))

  # Crear un dataframe para el gráfico
  data <- data.frame(
    inserciones = 1:n,
    probabilidad = distribucion[2:(n + 1)],  # Probabilidades desde P(1) hasta P(n)
    acumulada = acumuladas  # Acumulaciones correctas de 1 a n, 2 a n, etc.
  )

  # Graficar probabilidades y acumuladas
  p <- ggplot(data, aes(x = inserciones)) +
    geom_line(aes(y = probabilidad, color = "Probabilidad"), size = 1.2) +
    geom_smooth(aes(y = probabilidad, color = "Probabilidad"), method = "loess", se = FALSE, linetype = "solid", size = 0.8) +  # Añadir suavizado
    geom_line(aes(y = acumulada, color = "Acumulada"), linetype = "dashed", size = 1.2) +
    geom_smooth(aes(y = acumulada, color = "Acumulada"), method = "loess", se = FALSE, linetype = "dashed", size = 0.8) +  # Suavizado acumulado
    labs(
      title = "Distribución Beta Binomial y Acumulada con Suavizado",
      x = "Número de inserciones",
      y = "Probabilidad"
    ) +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_color_manual(name = "Tipo", values = c("Probabilidad" = "blue", "Acumulada" = "red"))

  # Mostrar el gráfico
  print(p)

  # Retornar la tabla final con los resultados
  # return(mejores_combinaciones)
}

#__________________________________________________________#
