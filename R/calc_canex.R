#' @encoding UTF-8
#' @title CANEX: Canonical Expansion model
#' @description Package implementing the CANEX model for calculating contact distribution
#' and reach metrics in media planning.
#'
#' @details The package implements the canonical expansion model for multivariate
#' media exposure distributions, considering heterogeneity and duplications between vehicles.
#'
#' @section Functions:
#' \itemize{
#'   \item \code{calculate_bbd_params}: Calculate BBD parameters
#'   \item \code{calculate_mean_variance}: Calculate mean and variance
#'   \item \code{calculate_marginal_prob}: Calculate marginal probability
#'   \item \code{calculate_duplication}: Calculate vehicle correlation
#'   \item \code{canex_model}: Main model implementation
#'   \item \code{calculate_metrics}: Calculate detailed metrics
#'   \item \code{calc_canex}: Generate formatted report
#' }
#'
#' @references
#' Danaher, P. J. (1991). A canonical expansion model for multivariate media exposure
#' distributions. Journal of Marketing Research, 28(3), 361–367.
#'
#' @name CANEX-package
#' @docType package

#' @encoding UTF-8
#' @title Calculate BBD Parameters
#' @description Calculates alpha and beta parameters for Beta Binomial Distribution
#' using method of moments.
#'
#' @param R1 Numeric. Single insertion reach (0-1)
#' @param R2 Numeric. Double insertion reach (0-1)
#'
#' @return List with components:
#' \itemize{
#'   \item alpha: BBD alpha parameter
#'   \item beta: BBD beta parameter
#' }
#'
#' @examples
#' params <- calculate_bbd_params(0.4902, 0.5805)
#'
#' @export

calculate_bbd_params <- function(R1, R2) {
  alpha <- R1 * (R2 - R1) / (2 * R1 - R2 - R1^2)
  beta <- alpha * (1 - R1) / R1
  return(list(alpha = alpha, beta = beta))
}

#' @encoding UTF-8
#' @title Calculate BBD Mean and Variance
#' @description Calculates mean and variance for Beta Binomial Distribution
#' given its parameters.
#'
#' @param k Integer. Number of insertions
#' @param alpha Numeric. BBD alpha parameter
#' @param beta Numeric. BBD beta parameter
#'
#' @return List with components:
#' \itemize{
#'   \item mean: Distribution mean
#'   \item variance: Distribution variance
#' }
#'
#' @examples
#' mv <- calculate_mean_variance(2, 0.5, 1.2)
#'
#' @export

calculate_mean_variance <- function(k, alpha, beta) {
  mean <- k * alpha / (alpha + beta)
  variance <- k * alpha * beta * (alpha + beta + k) /
    ((alpha + beta)^2 * (alpha + beta + 1))
  return(list(mean = mean, variance = variance))
}

#' @encoding UTF-8
#' @title Calculate Marginal Probability
#' @description Calculates marginal probability for x successes in k trials
#' under Beta-Binomial distribution.
#'
#' @param x Integer. Number of successes
#' @param k Integer. Number of trials
#' @param alpha Numeric. BBD alpha parameter
#' @param beta Numeric. BBD beta parameter
#'
#' @return Numeric. Probability value
#'
#' @examples
#' prob <- calculate_marginal_prob(2, 5, 0.5, 1.2)
#'
#' @export

calculate_marginal_prob <- function(x, k, alpha, beta) {
  if (x > k) return(0)

  log_num <- lgamma(k + 1) + lgamma(alpha + beta) +
    lgamma(alpha + x) + lgamma(beta + k - x)
  log_den <- lgamma(x + 1) + lgamma(k - x + 1) + lgamma(alpha) +
    lgamma(beta) + lgamma(alpha + beta + k)

  log_prob <- log_num - log_den
  return(exp(log_prob))
}

#' @encoding UTF-8
#' @title Calculate Vehicle Duplication
#' @description Calculates correlation coefficient between two vehicles
#' based on their reach probabilities.
#'
#' @param pij Numeric. Joint exposure probability
#' @param pi Numeric. First vehicle marginal probability
#' @param pj Numeric. Second vehicle marginal probability
#'
#' @return Numeric. Correlation coefficient (-1 to 1)
#'
#' @examples
#' corr <- calculate_duplication(0.15, 0.3, 0.4)
#'
#' @export

calculate_duplication <- function(pij, pi, pj) {
  numerator <- pij - pi * pj
  denominator <- sqrt(pi * (1 - pi) * pj * (1 - pj))
  if (denominator == 0) return(0)
  return(numerator / denominator)
}

#' @encoding UTF-8
#' @title Transform Duplication Matrix
#' @description Converts raw duplication matrix to correlation coefficients.
#'
#' @param duplications Matrix. Raw duplication values
#' @param vehicles_data Data frame. Contains R1 for each vehicle
#'
#' @return Matrix of correlation coefficients
#'
#' @examples
#' dup_matrix <- matrix(c(1, 0.0157, 0.0157, 1), nrow=2)
#' vehicles <- data.frame(R1=c(0.4902, 0.033))
#' correlations <- transform_duplications(dup_matrix, vehicles)
#'
#' @export

transform_duplications <- function(duplications, vehicles_data) {
  m <- nrow(duplications)
  correlations <- matrix(0, m, m)
  diag(correlations) <- 1
  epsilon <- 1e-10

  for (i in 1:m) {
    for (j in 1:m) {
      if (i != j) {  # Solo calcular fuera de la diagonal
        pi <- vehicles_data$R1[i]
        pj <- vehicles_data$R1[j]
        pij <- duplications[i, j]

        # Condiciones para correlación 0
        if (pi < epsilon || pi > 1 - epsilon ||
            pj < epsilon || pj > 1 - epsilon ||
            pi * (1 - pi) * pj * (1 - pj) < epsilon^2) {
          correlations[i, j] <- 0
        } else {
          correlations[i, j] <- (pij - pi * pj) / sqrt(pi * (1 - pi) * pj * (1 - pj))
        }
      }
    }
  }
  return(correlations)
}

#' @encoding UTF-8
#' @title Calcular Modelo CANEX
#' @description Función principal que implementa los cálculos del modelo CANEX (Canonical Expansion model).
#' Este modelo calcula la distribución de alcance y frecuencia considerando la heterogeneidad y duplicaciones y correlaciones
#' entre vehículos de medios.
#'
#' @param vehicles_data Marco de datos que contiene datos de vehículos de medios con columnas:
#' \itemize{
#'   \item k: Número de inserciones por vehículo (entero)
#'   \item R1: Alcance de inserción tras primera inserción (0-1)
#'   \item R2: Alcance de inserción tras segunda inserción (0-1)
#' }
#' @param duplications Matriz. Matriz de duplicación de vehículos donde el elemento [i,j] representa
#' la proporción de población expuesta a ambos vehículos i y j
#' @param poblacion Entero. Tamaño de la población objetivo (predeterminado: 1,000,000)
#'
#' @details
#' El modelo CANEX integra tres componentes clave:
#' \itemize{
#'   \item Distribución Beta Binomial (BBD) para modelar la heterogeneidad de exposición
#'   \item Duplicaciones de vehículos a través de coeficientes de duplicación y correlación
#'   \item Ajuste multivariado para probabilidades conjuntas
#' }
#'
#' El modelo sigue estos pasos:
#' \enumerate{
#'   \item Calcular parámetros BBD (alfa, beta) para cada vehículo
#'   \item Transformar matriz de duplicación a correlaciones
#'   \item Generar distribución de probabilidad conjunta
#'   \item Calcular métricas de alcance y frecuencia
#' }
#'
#' @return Lista con componentes:
#' \itemize{
#'   \item total_reach: Proporción de población alcanzada (0-1)
#'   \item total_reach_people: Número de personas alcanzadas
#'   \item distribution: Marco de datos con columnas:
#'     \itemize{
#'       \item contacts: Número de exposiciones
#'       \item percentage: Porcentaje de población
#'       \item people: Número de personas
#'     }
#'   \item cumulative: Marco de datos con columnas:
#'     \itemize{
#'       \item min_contacts: Número mínimo de exposiciones
#'       \item percentage: Porcentaje acumulado
#'       \item people: Número acumulado de personas
#'     }
#'   \item stats: Lista con métricas adicionales:
#'     \itemize{
#'       \item avg_contacts: Contactos promedio por persona alcanzada
#'       \item zero_contacts_prob: Probabilidad de cero contactos
#'     }
#' }
#'
#' @examples
#' # Ejemplo 1: Uso básico con dos vehículos
#' vehicles <- data.frame(
#'   k = c(2, 2),
#'   R1 = c(0.4902, 0.033),
#'   R2 = c(0.5805, 0.0502)
#' )
#' duplications <- matrix(
#'   c(1.000, 0.0157,
#'     0.0157, 1.000),
#'   nrow = 2, byrow = TRUE
#' )
#' results <- calc_canex(vehicles, duplications)
#' print(results)
#'
#' # Ejemplo 2: Tres vehículos con población personalizada
#' vehicles2 <- data.frame(
#'   k = c(2, 2, 2),
#'   R1 = c(0.4902, 0.033, 0.0300),
#'   R2 = c(0.5805, 0.0502, 0.0371)
#' )
#' duplications2 <- matrix(
#'   c(1.000, 0.0157, 0.0139,
#'     0.0157, 1.000, 0.0003,
#'     0.0139, 0.0003, 1.000),
#'   nrow = 3, byrow = TRUE
#' )
#' results2 <- calc_canex(vehicles2, duplications2, poblacion = 500000)
#'
#' # Acceder a métricas específicas
#' total_reach <- results2$total_reach
#' avg_contacts <- results2$stats$avg_contacts
#' dist_table <- results2$distribution
#'
#' @seealso
#' \code{\link{calculate_bbd_params}} para el cálculo de parámetros BBD
#' \code{\link{transform_duplications}} para la transformación de matriz de duplicación
#' \code{\link{calculate_metrics}} para el cálculo detallado de métricas
#'
#' @references
#' Danaher, P. J. (1991). A canonical expansion model for multivariate media exposure
#' distributions: A generalization of the "duplication of viewing law."
#' Journal of Marketing Research, 28(3), 361–367.
#'
#' @importFrom stats aggregate
#' @importFrom stats rgamma
#' @export

calc_canex <- function(vehicles_data, duplications, poblacion = 1000000) {
  correlations <- transform_duplications(duplications, vehicles_data)
  m <- nrow(vehicles_data)

  bbd_params <- lapply(1:m, function(i) {
    calculate_bbd_params(vehicles_data$R1[i], vehicles_data$R2[i])
  })

  mv_params <- lapply(1:m, function(i) {
    calculate_mean_variance(vehicles_data$k[i],
                            bbd_params[[i]]$alpha,
                            bbd_params[[i]]$beta)
  })

  max_exposures <- vehicles_data$k
  exposure_grid <- expand.grid(lapply(max_exposures, function(k) 0:k))

  # Precalcular valores para cada vehículo
  precalculated_marginals <- lapply(1:m, function(i) {
    lapply(0:vehicles_data$k[i], function(x) {
      calculate_marginal_prob(x, vehicles_data$k[i], bbd_params[[i]]$alpha, bbd_params[[i]]$beta)
    })
  })

  precalculated_mean_var_ratios <- lapply(1:m, function(i) {
    if (mv_params[[i]]$variance > 0) {
      list(mean = mv_params[[i]]$mean,
           var_sqrt_inv = 1 / sqrt(mv_params[[i]]$variance))
    } else {
      list(mean = 0, var_sqrt_inv = 0) # Manejar caso de varianza 0
    }
  })

  calculate_joint_prob <- function(exposures) {
    # Acceder a los valores precalculados
    marginals <- mapply(function(x, i) precalculated_marginals[[i]][[x + 1]], exposures, 1:m)
    base_prob <- prod(marginals)

    dup_term <- 0
    for (i in 1:(m-1)) {
      for (j in (i+1):m) {
        if (precalculated_mean_var_ratios[[i]]$var_sqrt_inv != 0 &&
            precalculated_mean_var_ratios[[j]]$var_sqrt_inv != 0) {

          # Líneas de depuración adicionales:
          print(paste("Iteración: i =", i, ", j =", j))
          print(paste("  marginals:", paste(marginals, collapse = ", ")))
          print(paste("  base_prob:", base_prob))
          print(paste("  correlations[i,j]:", correlations[i,j]))
          print(paste("  exposures[i]:", exposures[i]))
          print(paste("  precalculated_mean_var_ratios[[i]]$mean:", precalculated_mean_var_ratios[[i]]$mean))
          print(paste("  precalculated_mean_var_ratios[[i]]$var_sqrt_inv:", precalculated_mean_var_ratios[[i]]$var_sqrt_inv))
          print(paste("  exposures[j]:", exposures[j]))
          print(paste("  precalculated_mean_var_ratios[[j]]$mean:", precalculated_mean_var_ratios[[j]]$mean))
          print(paste("  precalculated_mean_var_ratios[[j]]$var_sqrt_inv:", precalculated_mean_var_ratios[[j]]$var_sqrt_inv))

          dup_term <- dup_term + correlations[i,j] *
            (exposures[i] - precalculated_mean_var_ratios[[i]]$mean) * precalculated_mean_var_ratios[[i]]$var_sqrt_inv *
            (exposures[j] - precalculated_mean_var_ratios[[j]]$mean) * precalculated_mean_var_ratios[[j]]$var_sqrt_inv

          print(paste("  dup_term:", dup_term))
        }
      }
    }

    # Manejar casos donde base_prob o dup_term son NaN o Inf
    if (is.nan(base_prob) || is.infinite(base_prob)) {
      base_prob <- 0
    }
    if (is.nan(dup_term) || is.infinite(dup_term)) {
      dup_term <- 0
    }

    final_prob <- base_prob * (1 + dup_term)

    # Línea de depuración:
    print(paste("final_prob:", final_prob))

    return(max(0, final_prob))
  }

  probs <- apply(exposure_grid, 1, calculate_joint_prob)
  total_exposures <- rowSums(exposure_grid)

  result <- aggregate(probs, by = list(total_exposures), sum)
  names(result) <- c("exposures", "probability")

  # Calcular métricas y mostrar reporte
  metrics <- calculate_metrics(result, poblacion)
  print.calc_canex(metrics, poblacion)

  invisible(metrics) # Retorna metrics sin imprimirlo

  # return(metrics)
}

#' @encoding UTF-8
#' @title Calculate CANEX Metrics
#' @description Calculates detailed metrics from contact distribution.
#'
#' @param distribution Data frame. Contact distribution
#' @param poblacion Integer. Target population size
#'
#' @return List with components:
#' \itemize{
#'   \item total_reach: Total reach proportion
#'   \item total_reach_people: People reached
#'   \item distribution: Detailed distribution
#'   \item cumulative: Cumulative distribution
#'   \item stats: Additional statistics
#' }
#'
#' @examples
#' dist <- data.frame(
#'   exposures = 0:2,
#'   probability = c(0.3, 0.5, 0.2)
#' )
#' metrics <- calculate_metrics(dist, 1000000)
#'
#' @export

calculate_metrics <- function(distribution, poblacion = 1000000) {
  distribution <- distribution[order(distribution$exposures), ]
  distribution$percentage <- distribution$probability * 100
  distribution$people <- round(distribution$probability * poblacion)

  # Líneas de depuración:
  print(paste("Dentro de calculate_metrics:"))
  print(paste("  distribution$probability:", distribution$probability))
  print(paste("  poblacion:", poblacion))

  cumulative_people <- vapply(distribution$exposures, function(n) {
    sum(distribution$people[distribution$exposures >= n])
  }, numeric(1)) # Especificamos que la salida es un vector numérico de longitud 1

  cumulative_dist <- data.frame(
    min_contacts = distribution$exposures,
    people = cumulative_people,
    percentage = (cumulative_people / poblacion) * 100
  )

  avg_contacts <- sum(distribution$exposures * distribution$probability) /
    sum(distribution$probability[distribution$exposures > 0])

  report <- list(
    total_reach = 1 - distribution$probability[1],
    total_reach_people = cumulative_people[2],

    distribution = data.frame(
      contacts = distribution$exposures,
      percentage = distribution$percentage,
      people = distribution$people
    ),

    cumulative = data.frame(
      min_contacts = cumulative_dist$min_contacts,
      percentage = cumulative_dist$percentage,
      people = cumulative_dist$people
    ),

    stats = list(
      avg_contacts = avg_contacts,
      zero_contacts_prob = distribution$probability[1]
    )
  )

  # return(report)
}

#' @encoding UTF-8
#' @title Print CANEX Report
#' @description Generates formatted report with CANEX model metrics.
#'
#' @param metrics List. Output from calculate_metrics()
#' @param poblacion Integer. Target population size
#'
#' @return NULL (prints to console)
#'
#' @examples
#' dist <- data.frame(
#'   exposures = 0:2,
#'   probability = c(0.3, 0.5, 0.2)
#' )
#' metrics <- calculate_metrics(dist)
#' print.calc_canex(metrics)
#'
#' @export

#' @encoding UTF-8
#' @title Print CANEX Report
#' @description Generates formatted report with CANEX model metrics.
#'
#' @param metrics List. Output from calculate_metrics()
#' @param poblacion Integer. Target population size
#'
#' @return NULL (prints to console)
#'
#' @examples
#' dist <- data.frame(
#'   exposures = 0:2,
#'   probability = c(0.3, 0.5, 0.2)
#' )
#' metrics <- calculate_metrics(dist)
#' print.calc_canex(metrics)
#'
#' @export

print.calc_canex <- function(metrics, poblacion = 1000000) {
  cat("\nMODELO CANEX")
  cat("\n===================")
  cat("\nDescripción: Modelo que considera heterogeneidad y duplicaciones entre vehículos\n")

  cat("\nMÉTRICAS PRINCIPALES:")
  cat("\n--------------------")
  cat(sprintf("\nCobertura total: %.2f%% (%.0f personas)\n",
              metrics$total_reach * 100,
              metrics$total_reach_people))

  cat("\nDISTRIBUCIÓN DE CONTACTOS:")
  cat("\n-------------------------")
  cat("\n(Porcentaje de población que recibe exactamente N contactos)")

  # Asegurar que el bucle itera correctamente incluso si hay un solo contacto
  num_rows <- if (is.null(nrow(metrics$distribution))) length(metrics$distribution$contacts) else nrow(metrics$distribution)

  for(i in 1:num_rows) {
    contacts <- metrics$distribution$contacts[i]
    pct <- metrics$distribution$percentage[i]
    people <- metrics$distribution$people[i]

    cat(sprintf("\n%d contacto%s: %.2f%% (%.0f personas)",
                contacts,
                ifelse(contacts == 1, "", "s"),
                pct,
                people))
  }

  cat("\n\nDISTRIBUCIÓN ACUMULADA:")
  cat("\n-----------------------")
  cat("\n(Porcentaje de población que recibe al menos N contactos)")

  # Asegurar que el bucle itera correctamente incluso si hay un solo contacto
  num_rows_cum <- if (is.null(nrow(metrics$cumulative))) length(metrics$cumulative$min_contacts) else nrow(metrics$cumulative)

  for (i in 1:num_rows_cum) {
    min_contacts <- metrics$cumulative$min_contacts[i]
    pct <- metrics$cumulative$percentage[i]
    people <- metrics$cumulative$people[i]

    cat(sprintf("\n≥ %d contacto%s: %.2f%% (%.0f personas)",
                min_contacts,
                ifelse(min_contacts == 1, "", "s"),
                pct,
                people))
  }

  cat("\n\nRESUMEN ESTADÍSTICO:")
  cat("\n-------------------")
  cat(sprintf("\nPromedio de contactos por individuo alcanzado: %.2f",
              metrics$stats$avg_contacts))
  cat(sprintf("\nProbabilidad de 0 contactos: %.2f%%",
              metrics$stats$zero_contacts_prob * 100))
  cat("\n")
}
