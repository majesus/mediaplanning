#' @encoding UTF-8
#' @title CANEX: Correlation Adjusted for N EXposures Model
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
  num <- gamma(k + 1) * gamma(alpha + beta) *
    gamma(alpha + x) * gamma(beta + k - x)
  den <- gamma(x + 1) * gamma(k - x + 1) * gamma(alpha) *
    gamma(beta) * gamma(alpha + beta + k)
  return(num / den)
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
  for(i in 1:(m-1)) {
    for(j in (i+1):m) {
      pi <- vehicles_data$R1[i]
      pj <- vehicles_data$R1[j]
      pij <- duplications[i,j]
      correlations[i,j] <- correlations[j,i] <-
        (pij - pi*pj) / sqrt(pi*(1-pi)*pj*(1-pj))
    }
  }
  return(correlations)
}

#' @encoding UTF-8
#' @title Calculate CANEX Model
#' @description Main function implementing CANEX (Correlation Adjusted for N EXposures) model calculations.
#' This model calculates reach and frequency distribution considering heterogeneity and correlations
#' between media vehicles.
#'
#' @param vehicles_data Data frame containing media vehicle data with columns:
#' \itemize{
#'   \item k: Number of insertions per vehicle (integer)
#'   \item R1: Single insertion reach (0-1)
#'   \item R2: Double insertion reach (0-1)
#' }
#' @param duplications Matrix. Vehicle duplication matrix where element [i,j] represents
#' the proportion of population exposed to both vehicle i and j
#' @param poblacion Integer. Target population size (default: 1,000,000)
#'
#' @details
#' The CANEX model integrates three key components:
#' \itemize{
#'   \item Beta Binomial Distribution (BBD) to model exposure heterogeneity
#'   \item Vehicle duplications through correlation coefficients
#'   \item Multivariate adjustment for joint probabilities
#' }
#'
#' The model follows these steps:
#' \enumerate{
#'   \item Calculate BBD parameters (alpha, beta) for each vehicle
#'   \item Transform duplication matrix to correlations
#'   \item Generate joint probability distribution
#'   \item Calculate reach and frequency metrics
#' }
#'
#' @return List with components:
#' \itemize{
#'   \item total_reach: Proportion of population reached (0-1)
#'   \item total_reach_people: Number of people reached
#'   \item distribution: Data frame with columns:
#'     \itemize{
#'       \item contacts: Number of exposures
#'       \item percentage: Percentage of population
#'       \item people: Number of people
#'     }
#'   \item cumulative: Data frame with columns:
#'     \itemize{
#'       \item min_contacts: Minimum number of exposures
#'       \item percentage: Cumulative percentage
#'       \item people: Cumulative number of people
#'     }
#'   \item stats: List with additional metrics:
#'     \itemize{
#'       \item avg_contacts: Average contacts per person reached
#'       \item zero_contacts_prob: Probability of zero contacts
#'     }
#' }
#'
#' @examples
#' # Example 1: Basic usage with two vehicles
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
#' # Example 2: Three vehicles with custom population
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
#' # Access specific metrics
#' total_reach <- results2$total_reach
#' avg_contacts <- results2$stats$avg_contacts
#' dist_table <- results2$distribution
#'
#' @seealso
#' \code{\link{calculate_bbd_params}} for BBD parameter calculation
#' \code{\link{transform_duplications}} for duplication matrix transformation
#' \code{\link{calculate_metrics}} for detailed metrics calculation
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

  calculate_joint_prob <- function(exposures) {
    marginals <- mapply(function(x, i) {
      calculate_marginal_prob(x, vehicles_data$k[i],
                              bbd_params[[i]]$alpha,
                              bbd_params[[i]]$beta)
    }, exposures, 1:m)

    base_prob <- prod(marginals)
    dup_term <- 0
    for (i in 1:(m-1)) {
      for (j in (i+1):m) {
        if (mv_params[[i]]$variance > 0 && mv_params[[j]]$variance > 0) {
          dup_term <- dup_term + correlations[i,j] *
            ((exposures[i] - mv_params[[i]]$mean) /
               sqrt(mv_params[[i]]$variance)) *
            ((exposures[j] - mv_params[[j]]$mean) /
               sqrt(mv_params[[j]]$variance))
        }
      }
    }

    final_prob <- base_prob * (1 + dup_term)
    return(max(0, final_prob))
  }

  probs <- apply(exposure_grid, 1, calculate_joint_prob)
  total_exposures <- rowSums(exposure_grid)

  result <- aggregate(probs, by = list(total_exposures), sum)
  names(result) <- c("exposures", "probability")

  # Calcular métricas y mostrar reporte
  metrics <- calculate_metrics(result, poblacion)
  print.calc_canex(metrics, poblacion)

  return(metrics)
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

  cumulative_people <- sapply(distribution$exposures, function(n) {
    sum(distribution$people[distribution$exposures >= n])
  })

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

  return(report)
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

print.calc_canex <- function(metrics, poblacion = 1000000) {
  cat("\nMODELO CANEX")
  cat("\n===================")
  cat("\nDescripción: Modelo que considera heterogeneidad y duplicaciones entre vehículos\n")

  cat("\nMÉTRICAS PRINCIPALES:")
  cat("\n--------------------")
  cat(sprintf("\nCobertura total: %.2f%% (%d personas)\n",
              metrics$total_reach * 100,
              metrics$total_reach_people))

  cat("\nDISTRIBUCIÓN DE CONTACTOS:")
  cat("\n-------------------------")
  cat("\n(Porcentaje de población que recibe exactamente N contactos)")
  for(i in 1:nrow(metrics$distribution)) {
    contacts <- metrics$distribution$contacts[i]
    pct <- metrics$distribution$percentage[i]
    people <- metrics$distribution$people[i]
    cat(sprintf("\n%d contacto%s: %.2f%% (%d personas)",
                contacts,
                ifelse(contacts == 1, "", "s"),
                pct,
                people))
  }

  cat("\n\nDISTRIBUCIÓN ACUMULADA:")
  cat("\n----------------------")
  cat("\n(Porcentaje de población que recibe N o más contactos)")
  for(i in 2:nrow(metrics$cumulative)) {
    contacts <- metrics$cumulative$min_contacts[i]
    pct <- metrics$cumulative$percentage[i]
    people <- metrics$cumulative$people[i]
    cat(sprintf("\n≥ %d contacto%s: %.2f%% (%d personas)",
                contacts,
                ifelse(contacts == 1, "", "s"),
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
