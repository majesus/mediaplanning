
#__________________________________________________________#

#' @encoding UTF-8
#' @title Cálculo de os valores R1 y R2 (modelo: Beta-Binomial)
#' @name calcular_R1_R2
#'
#' @description Calcula los valores R1 y R2 a partir de los
#' parámetros de forma alpha y beta del modelo de audiencia neta acumulada Beta-Binomial.
#' Los valores son clave para evaluar la audiencia neta y la distribución de contactos.
#' Si la probabilidad de éxito se distribuye según una beta de parámetros alpha y beta,
#' la distribución de contactos, sigue una distribución compuesta: la beta binomial.
#'
#' @param A Parámetro alpha, debe ser numérico y positivo
#' @param B Parámetro beta, debe ser numérico y positivo
#'
#' @details
#' Los coeficientes R1 y R2 son medidas de la duplicación de audiencias:
#' \itemize{
#'   \item R1 mide el tanto por uno de personas alcanzadas tras la primera inserción en el soporte
#'   \item R2 mide el tanto por uno de personas alcanzadas tras la segunda inserción en el soporte
#' }
#'
#' El proceso de cálculo:
#' \enumerate{
#'   \item Calcula R1 directamente como A/(A+B)
#'   \item Optimiza R2 mediante un proceso iterativo
#'   \item Verifica que los valores estén en el rango [0,1]
#' }
#'
#' @return Una lista con dos componentes:
#' \itemize{
#'   \item R1: Coeficiente de audiencia acumulada tras la primera inserción
#'   \item R2: Coeficiente de audiencia acumulada tras la segunda inserción
#' }
#'
#' @examples
#' # Calcular R1 y R2 para alpha=0.5 y beta=0.3
#' resultados <- calcular_R1_R2(0.5, 0.3)
#'
#' # Ver resultados
#' print(paste("R1:", round(resultados$R1, 4)))
#' print(paste("R2:", round(resultados$R2, 4)))
#'
#' # Verificar que los valores están en el rango esperado
#' stopifnot(resultados$R1 >= 0, resultados$R1 <= 1)
#' stopifnot(resultados$R2 >= 0, resultados$R2 <= 1)
#'
#' @export
#' @seealso
#' \code{\link{calc_beta_binomial}} para uso de estos coeficientes
#' \code{\link{calc_sainsbury}} para cálculos alternativos de duplicación
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

#' @encoding UTF-8
#' @title Impresión formateada de resultados del análisis de medios
#' @description Imprime en consola un resumen estructurado de los resultados del análisis
#' de medios, incluyendo combinaciones de soportes, distribución de contactos y
#' los parámetros alpha y beta utilizados.
#'
#' @param data_ls Una lista que debe contener los siguientes elementos:
#' \itemize{
#'   \item resultados: Data frame con las combinaciones más relevantes de soportes
#'   \item distribucion: Data frame con la distribución de contactos, incluyendo:
#'     \itemize{
#'       \item cont: Número de contactos
#'       \item prob: Probabilidad asociada
#'     }
#'   \item alpha: Valor del parámetro alpha utilizado en el análisis
#'   \item beta: Valor del parámetro beta utilizado en el análisis
#' }
#'
#' @return No retorna valor. Imprime en consola una visualización estructurada de:
#' \itemize{
#'   \item Combinaciones más relevantes de soportes
#'   \item Distribución de contactos y sus probabilidades
#'   \item Valores de los parámetros alpha y beta utilizados
#' }
#'
#' @examples
#' # Crear datos de ejemplo
#' data_ls <- list(
#'   resultados = data.frame(
#'     soporte = c("TV", "Radio", "Digital"),
#'     audiencia = c(1000, 800, 600)
#'   ),
#'   distribucion = data.frame(
#'     cont = 0:3,
#'     prob = c(0.2, 0.3, 0.3, 0.2)
#'   ),
#'   alpha = 0.5,
#'   beta = 0.3
#' )
#'
#' # Imprimir resultados
#' \dontrun{
#' imprimir_resultados(data_ls)
#' }
#'
#' @export
#' @seealso
#' \code{\link{reach_frequency}} para cálculos de alcance y frecuencia
#' \code{\link{calcular_R1_R2}} para cálculos de coeficientes de duplicación
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

#' @encoding UTF-8
#' @title Optimización de distribución de contactos mediante modelo Beta-Binomial
#' @description Esta función optimiza la distribución de contactos publicitarios y calcula
#' los coeficientes de duplicación (R1 y R2) utilizando un modelo Beta-Binomial.
#' El proceso busca la mejor combinación de parámetros alpha y beta que satisfaga
#' los criterios de cobertura efectiva y frecuencia efectiva (FE) especificados.
#'
#' @param Pob Tamaño total de la población
#' @param FE Frecuencia efectiva (número objetivo de impactos por persona)
#' @param cob_efectiva Número objetivo de personas a alcanzar con FE contactos
#' @param A1 Audiencia de la primera inserción
#' @param tolerancia Margen de error permitido en las soluciones (default: 0.05)
#' @param step_A Incremento para búsqueda del parámetro alpha (default: 0.025)
#' @param step_B Incremento para búsqueda del parámetro beta (default: 0.025)
#' @param n Número máximo de inserciones a considerar (default: 5)
#'
#' @return Una lista con los siguientes componentes:
#' \itemize{
#'   \item mejores_combinaciones: Data frame con todas las combinaciones válidas de
#'         parámetros, incluyendo:
#'         \itemize{
#'           \item x: Número de contactos
#'           \item alpha: Parámetro alpha del modelo
#'           \item beta: Parámetro beta del modelo
#'           \item R1: Coeficiente de duplicación de primer orden
#'           \item R2: Coeficiente de duplicación de segundo orden
#'           \item prob: Probabilidad asociada
#'         }
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones según criterios
#'   \item data: Data frame con la distribución de contactos y probabilidades acumuladas
#'   \item alpha: Valor óptimo seleccionado para alpha
#'   \item beta: Valor óptimo seleccionado para beta
#' }
#'
#' @details
#' La función realiza los siguientes pasos:
#' \enumerate{
#'   \item Genera combinaciones de parámetros (alpha, beta) dentro de rangos especificados
#'   \item Calcula distribuciones Beta-Binomiales para cada combinación
#'   \item Filtra resultados según criterios de cobertura y frecuencia
#'   \item Calcula coeficientes de duplicación R1 y R2
#'   \item Genera visualizaciones de la distribución resultante
#' }
#'
#' @note
#' Los parámetros alpha y beta controlan la forma de la distribución Beta-Binomial:
#' \itemize{
#'   \item alpha: Cuando el valor de alpha aumenta (manteniendo beta constante), se produce una asimetría hacia valores más altos de p (es decir, el éxito es más probable). Esto implica que alfa efectivamente influye en la asimetría, pero en combinación con beta.
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
#'   Pob = 1000000,      # Población de 1 millón
#'   FE = 3,             # Frecuencia efectiva de 3 contactos
#'   cob_efectiva = 590000,  # Objetivo: alcanzar 590,000 personas
#'   A1 = 500000         # Audiencia primera inserción: 500,000
#' )
#'
#' # Examinar resultados
#' print(head(resultado$mejores_combinaciones))
#' print(resultado$data)
#' }
#'
#' @export
#' @seealso
#' \code{\link{calcular_R1_R2}} para los cálculos de coeficientes de duplicación
#' \code{\link{imprimir_resultados}} para visualizar los resultados
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
    cat(">>> No se ha encontrado ninguna solución que se ajuste a los límites de tolerancia especificados.",
        "Se recomienda ampliar los límites de tolerancia para encontrar posibles soluciones.")
    return(NULL)
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

#' @encoding UTF-8
#' @title Optimización de distribución de contactos acumulada mediante modelo Beta-Binomial
#' @description Optimiza la distribución de contactos acumulada considerando una
#' frecuencia efectiva mínima (FEM) y calcula los coeficientes de duplicación R1 y R2.
#' La función se enfoca en la distribución acumulada de contactos, lo que permite
#' evaluar el alcance para diferentes niveles mínimos de exposición.
#'
#' @param Pob Tamaño total de la población
#' @param FEM Frecuencia efectiva mínima requerida (número mínimo de contactos)
#' @param cob_efectiva Número objetivo de personas a alcanzar al menos FEM
#' @param A1 Audiencia del soporte con la primera inserción
#' @param tolerancia Margen de error permitido para las soluciones (default: 0.05)
#' @param step_A Incremento para la búsqueda del parámetro alpha (default: 0.025)
#' @param step_B Incremento para la búsqueda del parámetro beta (default: 0.025)
#' @param n Número máximo de contactos a considerar (default: 5)
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
#'       \item R1: Coeficiente de duplicación de primer orden
#'       \item R2: Coeficiente de duplicación de segundo orden
#'       \item probs_acumuladas: Probabilidades acumuladas
#'     }
#'   \item mejores_combinaciones_top_10: Las 10 mejores combinaciones
#'   \item data: Data frame con:
#'     \itemize{
#'       \item inserciones: Número de contactos
#'       \item d_probabilidad: Probabilidad individual
#'       \item dc_probabilidad: Probabilidad acumulada
#'     }
#'   \item alpha: Valor óptimo seleccionado para alpha
#'   \item beta: Valor óptimo seleccionado para beta
#' }
#'
#' @note
#' La función considera la distribución acumulada de contactos, lo que la hace
#' especialmente útil para:
#' \itemize{
#'   \item Planificación de campañas con objetivos de frecuencia mínima
#'   \item Evaluación de cobertura efectiva en diferentes niveles de exposición
#'   \item Optimización de planes de medios con requisitos de frecuencia específicos
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
#'   Pob = 1000000,      # Población de 1 millón
#'   FEM = 3,            # Mínimo 3 contactos
#'   cob_efectiva = 547657,  # Objetivo: alcanzar 547,657 personas
#'   A1 = 500000         # Audiencia primera inserción: 500,000
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
#' \code{\link{optimizar_d}} para optimización de distribución simple
#' \code{\link{calcular_R1_R2}} para cálculos de coeficientes de duplicación
#' \code{\link{imprimir_resultados}} para visualización de resultados
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
