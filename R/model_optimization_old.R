
#__________________________________________________________#

#' @encoding UTF-8
#' @title Optimización de distribución de contactos mediante modelo Beta-Binomial
#' @description Esta función optimiza la distribución de contactos publicitarios y calcula
#' los coeficientes de duplicación (R1 y R2) utilizando la distribución Beta-Binomial.
#' El proceso busca la mejor combinación de parámetros alpha y beta y número de inserciones que satisfaga
#' los criterios de cobertura efectiva y frecuencia efectiva (FE) especificados por el usuario.
#'
#' @param Pob Tamaño de la población
#' @param FE Frecuencia efectiva (FE, número objetivo de impactos por persona)
#' @param cob_efectiva Número objetivo de personas a alcanzar con FE contactos
#' @param A1 Audiencia tras la primera inserción
#' @param max_inserciones Número de inserciones máximo a considerar (default: 5)
#' @param tolerancia Margen de error permitido en las soluciones (default: 0.05)
#' @param step_A Incremento para búsqueda del parámetro alpha (default: 0.025)
#' @param step_B Incremento para búsqueda del parámetro beta (default: 0.025)
#'
#' @return Una lista con los siguientes componentes:
#' \itemize{
#'   \item mejores_combinaciones: Data frame con todas las combinaciones válidas de
#'         parámetros, incluyendo:
#'         \itemize{
#'           \item x: Número de contactos
#'           \item alpha: Parámetro alpha del modelo
#'           \item beta: Parámetro beta del modelo
#'           \item R1: Proporción de personas alcanzadas tras la primera inserción
#'           \item R2: Proporción de personas alcanzadas tras la segunda inserción
#'           \item prob: Probabilidad asociada
#'         }
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones según criterios y valores establecidos
#'   \item data: Data frame con la distribución de contactos
#'   \item alpha: Valor seleccionado para alpha
#'   \item beta: Valor seleccionado para beta
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Genera combinaciones de parámetros (alpha, beta) dentro de rangos especificados
#'   \item Calcula distribuciones Beta-Binomiales para cada combinación
#'   \item Filtra resultados según criterios de cobertura y frecuencia
#'   \item Calcula coeficientes R1 y R2
#'   \item Genera visualizaciones de la distribución resultante
#' }
#'
#' @note
#' Los parámetros alpha y beta controlan la forma de la distribución Beta-Binomial:
#' \itemize{
#'   \item alpha: Cuando el valor de alpha aumenta (manteniendo beta constante), se produce una asimetría hacia valores más altos de p (es decir, el éxito es más probable). Esto implica que alpha efectivamente influye en la asimetría, pero en combinación con beta.
#'   \item beta: Cuando beta aumenta (y alpha se mantiene constante), se produce una asimetría hacia valores más bajos de p. En este sentido, beta también afecta la asimetría de la distribución beta.
#' }
#'
#' @import ggplot2
#' @import extraDistr
#' @importFrom stats optimize
#'
#' @examples
#' \dontrun{
#' # Ejemplo básico
#' resultado <- optimizar_d(
#'   Pob = 1000000,           # Población de 1 millón
#'   FE = 3,                  # Frecuencia efectiva de 3 contactos
#'   cob_efectiva = 590000,   # Objetivo: alcanzar 590,000 personas
#'   A1 = 500000,             # Audiencia primera inserción: 500,000
#'   max_inserciones = 5      # Número de inserciones máximo a considerar: 5
#' )
#'
#' # Examinar resultados
#' print(head(resultado$mejores_combinaciones))
#' print(resultado$data)
#' }
#'
#' @export
#' @seealso
#' \code{\link{calc_R1_R2}} para los cálculos de R1 y R2
optimizar_d <- function(Pob,
                        FE,
                        cob_efectiva,
                        A1,
                        max_inserciones,
                        tolerancia = 0.05,
                        step_A = 0.025,
                        step_B = 0.025) {

  #___________________________________#
  options(lazyLoad = FALSE)
  if (!requireNamespace("extraDistr", quietly = TRUE)) {
    install.packages("extraDistr")
  }
  library(extraDistr)
  library(ggplot2)
  #___________________________________#

  cat("Este script optimiza la distribución de contactos y calcula los valores de R1 y R2.

Para mayor información:
@param Pob              Numeric. Tamaño de la población
@param FE               Numeric. Valor objetivo de distribución de contactos
@param cob_efectiva     Numeric. Número de personas a alcanzar al menos i veces
@param A1               Numeric. Audiencia del soporte objetivo
@param max_inserciones  Numeric. Número máximo de inserciones a probar
@param tolerancia       Numeric. Tolerancia +/- de las soluciones propuestas
@param step_A           Numeric. Paso para el rango alpha
@param step_B           Numeric. Paso para el rango beta
")

  #___________________________________#

  # Validación de entrada
  if (!is.numeric(Pob) || !is.numeric(FE) || !is.numeric(cob_efectiva) || !is.numeric(max_inserciones)) {
    stop("Todos los parámetros deben ser numéricos.")
  }
  if (Pob <= 0 || cob_efectiva <= 0) {
    stop("Pob y cob_efectiva deben ser positivos.")
  }
  if (FE <= 0) {
    stop("'FE' no puede ser igual o menor que 0.")
  }
  if (FE > max_inserciones) {
    stop("'FE' no puede ser superior a 'max_inserciones'.")
  }
  if (cob_efectiva > Pob) {
    stop("El valor objetivo no puede ser mayor que la población.")
  }

  #___________________________________#

  # Cálculo de la tolerancia
  cob_efectiva <- cob_efectiva / Pob
  tolerancia <- cob_efectiva * tolerancia

  # Definición de rangos para los parámetros
  rangos_n <- seq(FE, max_inserciones, 1)  # Rango para n
  rangos_prob1 <- seq(0.01, 10, step_A)   # Rango para alpha
  rangos_prob2 <- seq(0.01, 10, step_B)   # Rango para beta

  # Generar todas las combinaciones posibles
  combinaciones <- expand.grid(
    n = rangos_n,
    x = FE,  # Mantenemos x fijo en FE
    alpha = rangos_prob1,
    beta = rangos_prob2
  )

  # Calcular probabilidades con vectorización usando mapply
  probs <- mapply(function(n, x, alpha, beta) {
    extraDistr::dbbinom(x = x, size = n, alpha = alpha, beta = beta)
  }, combinaciones$n, combinaciones$x, combinaciones$alpha, combinaciones$beta)

  # Filtrar combinaciones que cumplen el criterio
  indices <- which(abs(cob_efectiva - probs) <= tolerancia)
  mejores_combinaciones <- combinaciones[indices, ]

  # Calcular R1 y R2 para cada combinación
  resultados <- mapply(function(alpha, beta) {
    res <- calc_R1_R2(A = alpha, B = beta)
    return(c(R1 = res$R1, R2 = res$R2))
  }, mejores_combinaciones$alpha, mejores_combinaciones$beta, SIMPLIFY = FALSE)

  # Convertir lista de resultados a data frame
  resultados_df <- do.call(rbind, resultados)
  mejores_combinaciones <- cbind(mejores_combinaciones, resultados_df)

  # Calcular métricas a nivel población
  cob_efectiva_poblacional <- cob_efectiva * Pob
  mejores_combinaciones$prob <- round(probs[indices] * Pob, 0)
  mejores_combinaciones$distancia_objetivo <- abs(cob_efectiva_poblacional - mejores_combinaciones$prob)

  # Ordenar por distancia al objetivo y número de inserciones
  mejores_combinaciones <- mejores_combinaciones[
    order(mejores_combinaciones$distancia_objetivo, mejores_combinaciones$n),
  ]

  # Filtrar por R1 objetivo
  R1_objetivo <- A1 / Pob
  mejores_combinaciones <- mejores_combinaciones[
    which(abs(mejores_combinaciones$R1 - R1_objetivo) <= tolerancia),
  ]

  # Verificar si hay soluciones
  if (nrow(mejores_combinaciones) == 0) {
    cat(">>> No se ha encontrado ninguna solución que se ajuste a los límites de tolerancia especificados.",
        "Se recomienda ampliar los límites de tolerancia para encontrar posibles soluciones.")
    return(NULL)
  }

  # Procesar solución principal
  principal <- mejores_combinaciones[1, ]
  alpha <- principal$alpha
  beta <- principal$beta
  n_optimo <- principal$n

  # Calcular distribución con parámetros óptimos
  distribucion <- extraDistr::dbbinom(0:n_optimo, size = n_optimo, alpha = alpha, beta = beta)

  # Calcular probabilidades acumuladas
  acumuladas <- sapply(1:n_optimo, function(k) sum(distribucion[(k + 1):(n_optimo + 1)]))

  # Crear dataframe para visualización
  data <- data.frame(
    inserciones = 1:n_optimo,
    d_probabilidad = distribucion[2:(n_optimo + 1)],
    dc_acumulada = acumuladas
  )

  # Preparar resultados
  data_ls <- list(
    mejores_combinaciones = mejores_combinaciones,
    mejores_combinaciones_top_10 = head(mejores_combinaciones, 10),
    data = head(data, n = n_optimo),
    alpha = alpha,
    beta = beta,
    n_optimo = n_optimo
  )

  imprimir_resultados(data_ls)

  # Crear visualización
  p <- ggplot(data, aes(x = inserciones)) +
    geom_smooth(
      aes(y = d_probabilidad, color = "d_probabilidad"),
      method = "loess",
      se = FALSE,
      linetype = "solid",
      size = 0.8
    ) +
    geom_smooth(
      aes(y = dc_acumulada, color = "dc_acumulada"),
      method = "loess",
      se = FALSE,
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
      values = c("d_probabilidad" = "blue", "dc_acumulada" = "red")
    )

  print(p)
  return(invisible(data_ls))
}

#__________________________________________________________#

#' @encoding UTF-8
#' @title Optimización de distribución de contactos acumulada mediante modelo Beta-Binomial
#' @description Esta función optimiza la distribución de contactos publicitarios y calcula
#' los coeficientes de duplicación (R1 y R2) utilizando la distribución Beta-Binomial.
#' El proceso busca la mejor combinación de parámetros alpha y beta y número de inserciones que satisfaga
#' los criterios de cobertura efectiva y frecuencia efectiva mínima (FEM) especificados por el usuario.
#'
#' @param Pob Tamaño total de la población
#' @param FEM Frecuencia efectiva mínima requerida (FEM, número mínimo de contactos)
#' @param cob_efectiva Número objetivo de personas a alcanzar al menos FEM
#' @param A1 Audiencia del soporte tras la primera inserción
#' @param max_inserciones Número de inserciones máximo a considerar (default: 5)
#' @param tolerancia Margen de error permitido para las soluciones (default: 0.05)
#' @param step_A Incremento para la búsqueda del parámetro alpha (default: 0.025)
#' @param step_B Incremento para la búsqueda del parámetro beta (default: 0.025)
#'
#' @details
#' El proceso de optimización sigue estos pasos:
#' \enumerate{
#'   \item Validación de parámetros de entrada y normalización
#'   \item Generación de combinaciones de parámetros (alpha, beta)
#'   \item Cálculo de distribuciones Beta-Binomiales
#'   \item Evaluación de probabilidades acumuladas
#'   \item Filtrado de soluciones según criterios específicos:
#'     \itemize{
#'       \item Cumplimiento de la cobertura efectiva
#'       \item Validación de los coeficientes R1 y R2
#'       \item Ajuste a la audiencia objetivo del primer soporte
#'     }
#'   \item Generación de visualizaciones y resultados
#' }
#'
#' @return Una lista con los siguientes componentes:
#' \itemize{
#'   \item mejores_combinaciones: Data frame con todas las combinaciones válidas, incluyendo:
#'     \itemize{
#'       \item x: Número de contactos
#'       \item alpha: Parámetro alpha del modelo
#'       \item beta: Parámetro beta del modelo
#'       \item R1: Proporción de personas alcanzadas tras la primera inserción
#'       \item R2: Proporción de personas alcanzadas tras la segunda inserción
#'       \item probs_acumuladas: Probabilidades acumuladas
#'     }
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones
#'   \item data: Data frame con:
#'     \itemize{
#'       \item inserciones: Número de contactos
#'       \item d_probabilidad: Probabilidad individual
#'       \item dc_probabilidad: Probabilidad acumulada
#'     }
#'   \item alpha: Valor seleccionado para alpha
#'   \item beta: Valor seleccionado para beta
#' }
#'
#' @note
#' La función considera la distribución acumulada de contactos, lo que la hace
#' especialmente útil para:
#' \itemize{
#'   \item Planificación de campañas con objetivos de frecuencia efectiva mínima
#'   \item Evaluación de cobertura efectiva en diferentes niveles de exposición
#'   \item Optimización de planes de medios con requisitos de frecuencia efectiva mínima específicos
#' }
#'
#' @import ggplot2
#' @import extraDistr
#' @importFrom stats optimize
#'
#' @examples
#' \dontrun{
#' # Ejemplo de optimización para una campaña
#' resultado <- optimizar_dc(
#'   Pob = 1000000,           # Población de 1 millón
#'   FEM = 3,                 # Mínimo 3 contactos
#'   cob_efectiva = 547657,   # Objetivo: alcanzar 547,657 personas
#'   A1 = 500000,             # Audiencia primera inserción: 500,000
#'   max_inserciones = 5      # Número de inserciones máximo a considerar: 5
#' )
#'
#' # Examinar los resultados
#' print(head(resultado$mejores_combinaciones))
#' print(resultado$data)
#'
#' # Ver parámetros óptimos
#' cat("Alpha óptimo:", resultado$alpha, "\n")
#' cat("Beta óptimo:", resultado$beta, "\n")
#' }
#'
#' @export
#' @seealso
#' \code{\link{optimizar_d}} para optimización de distribución de contactos
#' \code{\link{calc_R1_R2}} para los cálculos de R1 y R2
optimizar_dc <- function(Pob,
                         FEM,
                         cob_efectiva,
                         A1,
                         max_inserciones,
                         tolerancia = 0.05,
                         step_A = 0.025,
                         step_B = 0.025) {

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
    @param Pob              Numeric. Tamaño de la población
    @param FEM              Numeric. Frecuencia efectiva mínima
    @param cob_efectiva     Numeric. Número de personas a alcanzar al menos i veces
    @param A1               Numeric. Audiencia del soporte objetivo
    @param max_inserciones  Numeric. Número máximo de inserciones a probar
    @param tolerancia       Numeric. Tolerancia +/- de las soluciones propuestas (Ri y A1i)
    @param step_A           Numeric. Paso para el rango alpha
    @param step_B           Numeric. Paso para el rango beta
  ")

  # Input validation
  if (!is.numeric(Pob) || !is.numeric(FEM) || !is.numeric(cob_efectiva) || !is.numeric(max_inserciones)) {
    stop("Todos los parámetros deben ser numéricos.")
  }
  if (Pob <= 0 || cob_efectiva <= 0) {
    stop("Pob y cob_efectiva deben ser positivos.")
  }
  if (FEM <= 0) {
    stop("'FEM' no puede ser igual o menor que 0.")
  }
  if (FEM > max_inserciones) {
    stop("'FEM' no puede ser superior a 'max_inserciones'.")
  }
  if (cob_efectiva > Pob) {
    stop("La cobertura efectiva no puede ser mayor que la población.")
  }

  # Calculate tolerance and normalize coverage
  cob_efectiva <- cob_efectiva / Pob
  tolerancia <- cob_efectiva * tolerancia

  # Define parameter ranges
  rangos_n <- seq(FEM, max_inserciones, 1)  # Rango de valores para n
  rangos_prob1 <- seq(0.01, 2000, step_A)
  rangos_prob2 <- seq(0.01, 2000, step_B)

  # Generate all possible combinations
  combinaciones <- expand.grid(
    n = rangos_n,          # Agregamos n a las combinaciones
    alpha = rangos_prob1,
    beta = rangos_prob2
  )

  # Calculate probabilities using vectorization
  probs <- mapply(
    function(n, alpha, beta) {
      extraDistr::dbbinom(x = 0:n, size = n, alpha = alpha, beta = beta)
    },
    combinaciones$n,       # Usamos n de las combinaciones
    combinaciones$alpha,
    combinaciones$beta,
    SIMPLIFY = FALSE
  )

  # Calculate cumulative probabilities
  probs_acumuladas <- mapply(
    function(prob_vector, n) {
      sum(prob_vector[(FEM + 1):(n + 1)])
    },
    probs,
    combinaciones$n,       # Pasamos n para cada cálculo
    SIMPLIFY = TRUE
  )

  # Filter combinations meeting criteria
  indices <- which(abs(cob_efectiva - unlist(probs_acumuladas)) <= tolerancia)
  mejores_combinaciones <- combinaciones[indices, ]

  # Calculate R1 and R2 for each combination
  resultados <- mapply(
    function(alpha, beta) {
      res <- calc_R1_R2(A = alpha, B = beta)
      return(c(R1 = res$R1, R2 = res$R2))
    },
    mejores_combinaciones$alpha,
    mejores_combinaciones$beta,
    SIMPLIFY = FALSE
  )

  # Convert results to data frame and process
  resultados_df <- do.call(rbind, resultados)
  mejores_combinaciones <- cbind(mejores_combinaciones, resultados_df)

  # Calculate GRPs values - ahora usando n variable
  mejores_combinaciones$GRP <- (mejores_combinaciones$R1 * Pob * mejores_combinaciones$n) * 100 / Pob

  # Calculate population-level metrics
  cob_efectiva_poblacional <- cob_efectiva * Pob
  mejores_combinaciones$probs_acumuladas <- round(probs_acumuladas[indices] * Pob, 0)
  mejores_combinaciones$distancia_objetivo <- abs(
    cob_efectiva_poblacional - mejores_combinaciones$probs_acumuladas
  )

  # Sort results
  mejores_combinaciones <- mejores_combinaciones[
    order(mejores_combinaciones$distancia_objetivo, mejores_combinaciones$n),
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
  n_optimo <- principal$n    # Usamos el n óptimo encontrado
  distribucion <- extraDistr::dbbinom(0:n_optimo, size = n_optimo, alpha = alpha, beta = beta)

  # Calculate accumulated probabilities
  acumuladas <- sapply(1:n_optimo, function(k) sum(distribucion[(k + 1):(n_optimo + 1)]))

  # Create visualization data
  data <- data.frame(
    inserciones = 1:n_optimo,
    d_probabilidad = distribucion[2:(n_optimo + 1)],
    dc_probabilidad = acumuladas
  )

  # Prepare results
  data_ls <- list(
    mejores_combinaciones = mejores_combinaciones,
    mejores_combinaciones_top_10 = head(mejores_combinaciones, 10),
    data = head(data, n = n_optimo),
    alpha = alpha,
    beta = beta,
    n_optimo = n_optimo    # Incluimos el n óptimo en los resultados
  )

  imprimir_resultados(data_ls)

  # Create visualization
  p <- ggplot(data, aes(x = inserciones)) +
    geom_smooth(
      aes(y = d_probabilidad, color = "d_probabilidad"),
      linetype = "solid",
      size = 0.8
    ) +
    geom_smooth(
      aes(y = dc_probabilidad, color = "dc_acumulada"),
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
      values = c("d_probabilidad" = "blue", "dc_acumulada" = "red")
    )

  print(p)
  return(invisible(data_ls))
}
