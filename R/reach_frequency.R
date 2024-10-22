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

#' Calcula R1 y R2 a partir de parámetros alpha y beta
#'
#' @param A Parámetro alpha, debe ser numérico y positivo
#' @param B Parámetro beta, debe ser numérico y positivo
#' @return Lista con valores R1 y R2 calculados
#' @export
#'
#' @examples
#' calcular_R1_R2(0.5, 0.3)
calcular_R1_R2 <- function(A, B) {
  if (!is.numeric(A) || !is.numeric(B) || A <= 0 || B <= 0) {
    stop("A y B deben ser numéricos y positivos.")
  }

  R1 <- A / (A + B)

  objetivo_R2 <- function(R2) {
    (A - (R1 * (R2 - R1)) / (2 * R1 - R1^2 - R2))^2
  }

  resultado <- stats::optimize(objetivo_R2, c(0, 1))
  R2 <- resultado$minimum

  return(list(R1 = R1, R2 = R2))
}


#__________________________________________________________#

#' Imprime resultados detallados del análisis
#'
#' @param data_ls Lista con los resultados del análisis que debe contener:
#'        combinaciones más relevantes, distribución de contactos,
#'        valor Alpha seleccionado, valor Beta seleccionado
#' @return No retorna valor, imprime los resultados en consola
#' @export
#'
#' @examples
#' data_ls <- list(
#'   resultados = data.frame(x = 1:3, y = 4:6),
#'   distribucion = data.frame(cont = 1:3, prob = c(0.3, 0.4, 0.3)),
#'   alpha = 0.5,
#'   beta = 0.3
#' )
#' imprimir_resultados(data_ls)
imprimir_resultados <- function(data_ls) {
  nombres_resultados <- c(
    "Combinaciones más relevantes",
    "Distribución de contactos",
    "Valor Alpha seleccionado",
    "Valor Beta seleccionado"
  )

  cat("\n=== RESULTADOS DEL ANÁLISIS ===\n")

  for (i in 2:5) {
    cat(sprintf("\n%s:\n", nombres_resultados[i-1]))

    if (is.data.frame(data_ls[[i]])) {
      print(data_ls[[i]], row.names = FALSE)
    } else if (is.numeric(data_ls[[i]])) {
      cat(sprintf("Valor: %.4f\n", data_ls[[i]]))
    } else {
      print(data_ls[[i]])
    }

    cat("\n", paste(rep("-", 50), collapse = ""), "\n")
  }
}


#__________________________________________________________#

#' Optimiza parámetros para el modelo de distribución de contactos
#'
#' @description
#' Esta función optimiza la distribución de contactos y calcula los valores
#' de R1 y R2 en función de los parámetros proporcionados. Utiliza una
#' distribución beta binomial para modelar los contactos publicitarios.
#'
#' @param Pob Numeric. Tamaño de la población objetivo
#' @param FE Numeric. Frecuencia efectiva objetivo
#' @param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces
#' @param A1 Numeric. Audiencia primera inserción
#' @param tolerancia Numeric. Tolerancia permitida para las soluciones (default: 0.05)
#' @param step_A Numeric. Paso para búsqueda de alpha (default: 0.025)
#' @param step_B Numeric. Paso para búsqueda de beta (default: 0.025)
#' @param n Numeric. Número de inserciones (default: 5)
#'
#' @return Una lista con los siguientes elementos:
#' \itemize{
#'   \item mejores_combinaciones: Data frame con todas las combinaciones válidas
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones
#'   \item data: Data frame con distribución de contactos
#'   \item alpha: Valor alpha seleccionado
#'   \item beta: Valor beta seleccionado
#' }
#'
#' @import ggplot2
#' @import extraDistr
#' @importFrom stats optimize
#'
#' @export
#'
#' @examples
#' \dontrun{
#' resultado <- optimizar_d(
#'   Pob = 1000000,
#'   FE = 3,
#'   cob_efectiva = 590000,
#'   A1 = 500000,
#'   tolerancia = 0.05,
#'   step_A = 0.025,
#'   step_B = 0.025,
#'   n = 5
#' )
#' }
optimizar_d <- function(Pob,
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
  if (Pob <= 0 || cob_efectiva <= 0) {
    stop("Pob y cob_efectiva deben ser positivos.")
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

#' #' Optimiza la distribución de contactos acumulada
#'
#' @description
#' Esta función optimiza la distribución de contactos acumulada y calcula
#' los valores de R1 y R2 considerando una frecuencia efectiva mínima (FEM).
#' Utiliza una distribución beta binomial para modelar los contactos.
#'
#' @param Pob Numeric. Tamaño de la población objetivo
#' @param FEM Numeric. Frecuencia efectiva mínima requerida
#' @param cob_efectiva Numeric. Número de personas a alcanzar al menos i veces
#' @param A1 Numeric. Audiencia del soporte objetivo
#' @param tolerancia Numeric. Tolerancia permitida para las soluciones (default: 0.05)
#' @param step_A Numeric. Paso para rango alpha (default: 0.025)
#' @param step_B Numeric. Paso para rango beta (default: 0.025)
#' @param n Numeric. Número máximo de contactos (default: 5)
#'
#' @return Una lista con los siguientes elementos:
#' \itemize{
#'   \item mejores_combinaciones: Data frame con todas las combinaciones válidas
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones
#'   \item data: Data frame con distribución de probabilidades
#'   \item alpha: Valor alpha seleccionado
#'   \item beta: Valor beta seleccionado
#' }
#'
#' @details
#' La función realiza las siguientes operaciones principales:
#' \itemize{
#'   \item Valida los parámetros de entrada
#'   \item Calcula distribuciones beta binomiales para diferentes combinaciones de parámetros
#'   \item Filtra las combinaciones que cumplen con los criterios especificados
#'   \item Calcula métricas R1 y R2 para las combinaciones válidas
#'   \item Genera visualizaciones de la distribución resultante
#' }
#'
#' @import ggplot2
#' @import extraDistr
#' @importFrom stats optimize
#'
#' @export
#'
#' @examples
#' \dontrun{
#' resultado <- optimizar_dc(
#'   Pob = 1000000,
#'   FEM = 3,
#'   cob_efectiva = 547657,
#'   A1 = 500000,
#'   tolerancia = 0.05,
#'   step_A = 0.25,
#'   step_B = 0.25,
#'   n = 5
#' )
#' }
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



