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

imprimir_resultados <- function(data_ls) {
  # Definir nombres descriptivos para los resultados 2 al 5
  nombres_resultados <- c(
    "Combinaciones más relevantes",
    "Distribución de contactos",
    "Valor Alpha seleccionado",
    "Valor Beta seleccionado"
  )

  cat("\n=== RESULTADOS DEL ANÁLISIS ===\n")

  # Iterar sobre los componentes 2 al 5
  for (i in 2:5) {
    cat(sprintf("\n%s:\n", nombres_resultados[i-1]))

    # Formatear la salida según el tipo de dato
    if (is.data.frame(data_ls[[i]])) {
      print(data_ls[[i]], row.names = FALSE)
    } else if (is.numeric(data_ls[[i]])) {
      cat(sprintf("Valor: %.4f\n", data_ls[[i]]))
    } else {
      print(data_ls[[i]])
    }

    cat("\n", paste(rep("-", 50), collapse = ""), "\n")  # Corregido aquí
  }
}

#__________________________________________________________#

#' Optimiza la distribución de contactos y calcula R1 y R2
#'
#' Esta función optimiza la distribución de contactos y calcula los valores de R1 y R2
#' en función de los parámetros proporcionados.
#'
#' @param Pob          Numeric. Tamaño de la población
#' @param FE           Numeric. Frecuencia efectiva
#' @param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces
#' @param A1           Numeric. Audiencia del soporte objetivo
#' @param tolerancia   Numeric. Tolerancia +/- de las soluciones propuestas (Ri y A1i)
#' @param step_A       Numeric. Paso para el rango alpha
#' @param step_B       Numeric. Paso para el rango beta
#' @param n            Numeric. Número máximo de contactos
#'
#' @return Data frame con las combinaciones óptimas de x, alpha, R1, R2, probs_acumuladas, distancia_objetivo.
#' @export
#'
#' @examples
#' optimizar_y_calcular(POB = 1000000, FE = 3, cob_efectiva = 0.043, step_A = 0.125, step_B = 0.125)
optimizar_d <- function(POB,
                        FE,
                        cob_efectiva,
                        A1,
                        tolerancia = 0.05,
                        step_A = 0.025,
                        step_B = 0.025,
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

  # Cargar el paquete y mostrar ayuda de mi paquete
  cat("Este script optimiza la distribución de contactos y calcula los valores de R1 y R2 en función de los parámetros proporcionados.

Para mayor información:
@param Pob Numeric. Tamaño de la población.
@param FE Numeric. Valor objetivo de distribución de contactos.
@param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces.
@param A1 Numeric. Audiencia del soporte objetivo.
@param tolerancia Numeric. Tolerancia +/- de las soluciones propuestas (Ri y A1i).
@param step_A Numeric. Paso para el rango de probabilidad alpha.
@param step_B Numeric. Paso para el rango de probabilidad beta.

")

  #___________________________________#

  # Validación de entrada
  if (!is.numeric(Pob) || !is.numeric(FE) || !is.numeric(cob_efectiva)) {
    stop("Todos los parámetros deben ser numéricos.")
  }
  if (POB <= 0 || cob_efectiva <= 0) {
    stop("POB y cob_efectiva deben ser positivos.")
  }
  if (FE <= 0) {
    stop("'FE' no puede ser igual o menor que 0.")
  }
  if (FE > n) {
    stop("'FE' no puede ser superior a 'n'.")
  }
  if (cob_efectiva > Pob) {
    stop("El valor objetivo no puede ser mayor que la población.")
  }

  #___________________________________#

  # Cálculo de la tolerancia
  cob_efectiva <- cob_efectiva / Pob
  tolerancia <- cob_efectiva * tolerancia

  # Definición de rangos para los parámetros
  rangos_size <- seq(FE, FE + 3, 1)  # Rango para x (contactos)
  rangos_prob1 <- seq(0.001, 10, step_A)   # Rango para alpha
  rangos_prob2 <- seq(0.001, 10, step_B)   # Rango para beta

  # Generar todas las combinaciones posibles de x, alpha y beta
  combinaciones <- expand.grid(x = rangos_size,
                               alpha = rangos_prob1,
                               beta = rangos_prob2)

  # Calcular probabilidades con vectorización usando mapply
  probs <- mapply(function(x, alpha, beta) {
    extraDistr::dbbinom(x = x, size = n, alpha = alpha, beta = beta)
  }, combinaciones$x, combinaciones$alpha, combinaciones$beta)

  # Filtrar combinaciones que cumplen el criterio
  indices <- which(abs(cob_efectiva - probs) <= tolerancia)

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


  # Asegurarse de que cob_efectiva esté en las mismas unidades que prob
  cob_efectiva_poblacional <- cob_efectiva * Pob  # Ajustamos el valor objetivo según la población

  # Calcular la columna prob
  mejores_combinaciones$prob <- round(probs[indices] * Pob, 0)

  # Crear la columna de distancia con respecto al valor objetivo poblacional
  mejores_combinaciones$distancia_objetivo <- abs(cob_efectiva_poblacional - mejores_combinaciones$prob)

  # Ordenar primero por el número de inserciones (x) y luego por la distancia al valor objetivo
  mejores_combinaciones <- mejores_combinaciones[order(mejores_combinaciones$x, mejores_combinaciones$distancia_objetivo), ]

  # Eliminar las filas donde la columna 'flag' tiene un asterisco
  mejores_combinaciones <- mejores_combinaciones[mejores_combinaciones$flag != "*", ]

  # Filtrar filas cuyo valor R1 esté cerca del valor objetivo especificado
  R1_objetivo <- A1 / Pob  # Valor objetivo de R1 para filtrar
  mejores_combinaciones <- mejores_combinaciones[which(abs(mejores_combinaciones$R1 - R1_objetivo) <= tolerancia), ]

  # Mostrar la tabla con las mejores combinaciones ordenadas
  if (nrow(mejores_combinaciones) == 0) {
    cat(">>>No se ha encontrado ninguna solución que se ajuste a los límites de tolerancia especificados. Se recomienda ampliar los límites de tolerancia para encontrar posibles soluciones.")
  } else {
    # Mostrar la tabla con las mejores combinaciones ordenadas
    print(mejores_combinaciones)
  }

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
  data

  # Prepare results
  data_ls <- list(
    mejores_combinaciones = mejores_combinaciones,
    mejores_combinaciones_top_10 = head(mejores_combinaciones, 10),
    data = head(data, n = 5),
    alpha = alpha,
    beta = beta
  )

  imprimir_resultados(data_ls)

  # Graficar probabilidades y acumuladas
  p <- ggplot(data, aes(x = inserciones)) +
    geom_smooth(aes(y = probabilidad, color = "Probabilidad"), method = "loess", se = FALSE, linetype = "solid", size = 0.8) +  # Añadir suavizado
    geom_smooth(aes(y = acumulada, color = "Acumulada"), method = "loess", se = FALSE, linetype = "dashed", size = 0.8) +  # Suavizado acumulado
    labs(
      title = "Distribución Beta Binomial y Acumulada con Suavizado",
      x = "Número de inserciones",
      y = "Probabilidad"
    ) +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_color_manual(name = "Tipo", values = c("Probabilidad" = "blue", "Acumulada" = "red"))

  print(p)
  return(invisible(data_ls))
}

#__________________________________________________________#

#' Optimiza la distribución de contactos y calcula R1 y R2
#'
#' Esta función optimiza la distribución de contactos y calcula los valores de R1 y R2
#' en función de los parámetros proporcionados.
#'
#' @param Pob          Numeric. Tamaño de la población
#' @param FEM          Numeric. Frecuencia efectiva mínima
#' @param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces
#' @param A1           Numeric. Audiencia del soporte objetivo
#' @param tolerancia   Numeric. Tolerancia +/- de las soluciones propuestas (Ri y A1i)
#' @param step_A       Numeric. Paso para el rango alpha
#' @param step_B       Numeric. Paso para el rango beta
#' @param n            Numeric. Número máximo de contactos
#'
#' @return Data frame con las combinaciones óptimas de x, alpha, R1, R2, probs_acumuladas, distancia_objetivo.
#' @export
#'
#' @examples
#' optimizar_y_calcular(Pob = 1000000, FEM = 3, cob_efectiva = 590000, A1 = 500000, tolerancia = 0.05, step_A = 0.025, step_B = 0.025, n = 5)
optimizar_dc <- function(Pob,
                         FEM,
                         cob_efectiva,
                         A1,
                         tolerancia = 0.05,
                         step_A = 0.025,
                         step_B = 0.025,
                         n = 5) {

  # Package dependencies check and loading
  if (!requireNamespace("extraDistr", quietly = TRUE)) {
    install.packages("extraDistr")
  }
  library(extraDistr)
  library(ggplot2)

  # Function documentation
  cat("
    Este script optimiza la distribución de contactos acumulada, y calcula
    los valores de R1 y R2 en función de los parámetros proporcionados.

    Parámetros:
    -----------
    @param Pob          Numeric. Tamaño de la población
    @param FEM          Numeric. Frecuencia efectiva mínima
    @param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces
    @param A1           Numeric. Audiencia del soporte objetivo
    @param tolerancia   Numeric. Tolerancia +/- de las soluciones propuestas (Ri y A1i)
    @param step_A       Numeric. Paso para el rango alpha
    @param step_B       Numeric. Paso para el rango beta
    @param n            Numeric. Número máximo de contactos
  ")

  # Input validation
  if (!is.numeric(Pob) || !is.numeric(FEM) || !is.numeric(cob_efectiva)) {
    stop("Todos los parámetros deben ser numéricos.")
  }
  if (Pob <= 0 || cob_efectiva <= 0) {
    stop("Pob y cob_efectiva deben ser positivos.")
  }
  if (FEM <= 0) {
    stop("'FEM' no puede ser igual o menor que 0.")
  }
  if (FEM > n) {
    stop("'FEM' no puede ser superior a 'n'.")
  }
  if (cob_efectiva > Pob) {
    stop("La cobertura efectiva no puede ser mayor que la población.")
  }

  # Calculate tolerance and normalize coverage
  cob_efectiva <- cob_efectiva / Pob
  tolerancia <- cob_efectiva * tolerancia

  # Define parameter ranges
  rangos_size <- seq(FEM, FEM + 3, 1)
  rangos_prob1 <- seq(0.001, 10, step_A)
  rangos_prob2 <- seq(0.001, 10, step_B)

  # Generate all possible combinations
  combinaciones <- expand.grid(
    x = rangos_size,
    alpha = rangos_prob1,
    beta = rangos_prob2
  )

  # Calculate probabilities using vectorization
  probs <- mapply(
    function(x, alpha, beta) {
      extraDistr::dbbinom(x = 0:n, size = n, alpha = alpha, beta = beta)
    },
    combinaciones$x,
    combinaciones$alpha,
    combinaciones$beta,
    SIMPLIFY = FALSE
  )

  # Calculate cumulative probabilities
  probs_acumuladas <- sapply(probs, function(prob_vector) {
    sum(prob_vector[(FEM + 1):(n + 1)])
  })

  # Filter combinations meeting criteria
  indices <- which(abs(cob_efectiva - unlist(probs_acumuladas)) <= tolerancia)
  mejores_combinaciones <- combinaciones[indices, ]

  # Calculate R1 and R2 for each combination
  resultados <- mapply(
    function(alpha, beta) {
      res <- calcular_R1_R2(A = alpha, B = beta)
      return(c(R1 = res$R1, R2 = res$R2))
    },
    mejores_combinaciones$alpha,
    mejores_combinaciones$beta,
    SIMPLIFY = FALSE
  )

  # Convert results to data frame and process
  resultados_df <- do.call(rbind, resultados)
  mejores_combinaciones <- cbind(mejores_combinaciones, resultados_df)
  mejores_combinaciones$flag <- ifelse(
    mejores_combinaciones$R2 > 2 * mejores_combinaciones$R1,
    "*",
    ""
  )

  # Calculate population-level metrics
  cob_efectiva_poblacional <- cob_efectiva * Pob
  mejores_combinaciones$probs_acumuladas <- round(probs_acumuladas[indices] * Pob, 0)
  mejores_combinaciones$distancia_objetivo <- abs(
    cob_efectiva_poblacional - mejores_combinaciones$probs_acumuladas
  )

  # Sort results
  mejores_combinaciones <- mejores_combinaciones[
    order(mejores_combinaciones$x, mejores_combinaciones$distancia_objetivo),
  ]

  # Filter by R1 target
  R1_objetivo <- A1 / Pob
  mejores_combinaciones <- mejores_combinaciones[
    which(abs(mejores_combinaciones$R1 - R1_objetivo) <= tolerancia),
  ]

  # Check if solutions were found
  if (nrow(mejores_combinaciones) == 0) {
    cat(">>> No se ha encontrado ninguna solución que se ajuste a los límites de tolerancia especificados.",
        "Se recomienda ampliar los límites de tolerancia para encontrar posibles soluciones.")
    return(NULL)
  }

  # Process principal solution
  principal <- mejores_combinaciones[1, ]
  alpha <- principal$alpha
  beta <- principal$beta
  distribucion <- extraDistr::dbbinom(0:n, size = n, alpha = alpha, beta = beta)

  # Calculate accumulated probabilities
  acumuladas <- sapply(1:n, function(k) sum(distribucion[(k + 1):(n + 1)]))

  # Create visualization data
  data <- data.frame(
    inserciones = 1:n,
    d_probabilidad = distribucion[2:(n + 1)],
    dc_probabilidad = acumuladas
  )

  # Prepare results
  data_ls <- list(
    mejores_combinaciones = mejores_combinaciones,
    mejores_combinaciones_top_10 = head(mejores_combinaciones, 10),
    data = head(data, n = 5),
    alpha = alpha,
    beta = beta
  )

  imprimir_resultados(data_ls)

  # Create visualization
  p <- ggplot(data, aes(x = inserciones)) +
    geom_smooth(
      aes(y = d_probabilidad, color = "Probabilidad"),
      linetype = "solid",
      size = 0.8
    ) +
    geom_smooth(
      aes(y = dc_probabilidad, color = "Acumulada"),
      linetype = "dashed",
      size = 0.8
    ) +
    labs(
      title = "Distribución Beta Binomial y Acumulada con Suavizado",
      x = "Número de inserciones",
      y = "Probabilidad"
    ) +
    theme_minimal() +
    theme(legend.position = "top") +
    scale_color_manual(
      name = "Tipo",
      values = c("Probabilidad" = "blue", "Acumulada" = "red")
    )

  print(p)
  return(invisible(data_ls))
}

#__________________________________________________________#

#' Calcula el reach y distribuciones usando el modelo de Sainsbury
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

#' Calcula el reach y distribuciones usando el modelo Binomial
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

#' Calcula el reach y distribuciones usando el modelo Beta-Binomial
#'
#' @param A1 Audiencia tras la primera inserción
#' @param A2 Audiencia tras la segunda inserción
#' @param P Población total
#' @param n Número de inserciones
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
#' resultado <- calc_beta_binomial(A1 = 500000, A2 = 550000, P = 1000000, n = 5)
#' Calcula el reach y distribuciones usando el modelo Beta-Binomial
#'
#' @param A1 Audiencia tras la primera inserción
#' @param A2 Audiencia tras la segunda inserción
#' @param P Población total
#' @param n Número de inserciones
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
#' resultado <- calc_beta_binomial(A1 = 500000, A2 = 550000, P = 1000000, n = 5)
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

