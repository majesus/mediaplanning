source("R/calc_modelos.R")
source("R/calc_canex.R")

#' @encoding UTF-8
#' @title Optimización de planes de medios con restricciones mediante procesamiento por lotes
#' @description Implementa un algoritmo de optimización para encontrar la combinación óptima de soportes publicitarios
#' que maximiza la cobertura para una Frecuencia Efectiva Mínima (FEM) determinada, respetando restricciones presupuestarias.
#' El algoritmo utiliza un enfoque de procesamiento por lotes (batches) y permite elegir entre el modelo de Sainsbury,
#' Binomial o Expansión Canónica para el cálculo de coberturas y distribución de contactos.
#'
#' @param soportes_df Data frame con columnas: soportes (character), audiencias (numeric), tarifas (numeric).
#'        Si se usa audiencia útil, debe incluir también indices_utilidad (numeric)
#' @param FEM Frecuencia Efectiva Mínima requerida (número entero positivo)
#' @param objetivo_cobertura Cobertura objetivo a alcanzar (porcentaje)
#' @param presupuesto_max Presupuesto máximo disponible
#' @param tolerancia_presupuesto Desviación permitida sobre el presupuesto máximo (por defecto 0.10 = 10%)
#' @param poblacion_total Tamaño de la población objetivo (por defecto 47000000)
#' @param tam_batch Tamaño de los lotes para procesamiento (por defecto 5)
#' @param soportes_vetados Vector de caracteres con nombres de soportes a excluir (opcional)
#' @param modelo Modelo a utilizar: "sainsbury", "binomial" o "canex" (por defecto "sainsbury")
#' @param usar_audiencia_util Logical indicando si usar audiencia útil (TRUE) o bruta (FALSE, por defecto)
#' @param correlaciones Matriz de correlaciones entre soportes (requerida solo para modelo "canex")
#' @param truncation_order Orden de truncación para el modelo de expansión canónica (por defecto 2)
#'
#' @details
#' El algoritmo de optimización sigue los siguientes pasos:
#' \enumerate{
#'   \item Preprocesamiento de datos:
#'     \itemize{
#'       \item Filtrado de soportes vetados
#'       \item Cálculo de audiencias útiles si corresponde
#'       \item Cálculo de ratios de eficiencia
#'       \item Validación de matriz de correlaciones para modelo canex
#'     }
#'   \item Procesamiento por lotes:
#'     \itemize{
#'       \item División en batches para optimizar el proceso
#'       \item Evaluación de combinaciones que cumplen FEM mínima
#'       \item Verificación de restricción presupuestaria
#'       \item Cálculo de cobertura mediante el modelo seleccionado
#'     }
#' }
#'
#' Los modelos disponibles son:
#' \itemize{
#'   \item Sainsbury: Considera la duplicación entre soportes como producto de probabilidades
#'   \item Binomial: Asume una probabilidad media de exposición para todos los soportes
#'   \item Canex: Modelo de expansión canónica que considera correlaciones entre soportes
#' }
#'
#' @return Una lista conteniendo:
#' \itemize{
#'   \item exito: Logical indicando si se encontró solución factible
#'   \item cobertura_alcanzada: Porcentaje de cobertura logrado
#'   \item coste_total: Coste total del plan
#'   \item soportes_seleccionados: Data frame con los soportes del plan óptimo
#'   \item plan_completo: Vector binario indicando soportes seleccionados
#'   \item objetivo_alcanzado: Logical indicando si se alcanzó el objetivo
#'   \item evaluacion: Lista con evaluaciones de presupuesto, cobertura y FEM
#'   \item distribucion: Lista con distribución de contactos y acumulada
#'   \item soportes_vetados: Vector de soportes excluidos
#'   \item tipo_audiencia: Tipo de audiencia usada ("bruta" o "util")
#'   \item modelo_usado: Modelo utilizado para los cálculos
#' }
#'
#' @examples
#' # Datos de ejemplo
#' example_data <- data.frame(
#'   soportes = c("Medio1", "Medio2", "Medio3"),
#'   audiencias = c(1000000, 800000, 600000),
#'   tarifas = c(5000, 4000, 3000)
#' )
#'
#' # Ejemplo con modelo Sainsbury
#' result_sainsbury <- optimize_media_plan(
#'   soportes_df = example_data,
#'   FEM = 2,
#'   objetivo_cobertura = 50,
#'   presupuesto_max = 100000,
#'   modelo = "sainsbury"
#' )
#'
#' # Ejemplo con modelo Binomial
#' result_binomial <- optimize_media_plan(
#'   soportes_df = example_data,
#'   FEM = 2,
#'   objetivo_cobertura = 50,
#'   presupuesto_max = 100000,
#'   modelo = "binomial"
#' )
#'
#' # Ejemplo con modelo Canex
#' correlaciones <- matrix(
#'   c(1.000, 0.085, 0.075,
#'     0.085, 1.000, 0.080,
#'     0.075, 0.080, 1.000),
#'   nrow = 3,
#'   byrow = TRUE
#' )
#'
#' result_canex <- optimize_media_plan(
#'   soportes_df = example_data,
#'   FEM = 2,
#'   objetivo_cobertura = 50,
#'   presupuesto_max = 100000,
#'   modelo = "canex",
#'   correlaciones = correlaciones
#' )
#'
#' @export
#' @seealso
#' \code{\link{calc_sainsbury}} para el modelo de Sainsbury
#' \code{\link{calc_binomial}} para el modelo Binomial
#' \code{\link{canonical_expansion_model}} para el modelo de Expansión Canónica

optimize_media_plan <- function(
    soportes_df,
    FEM,
    objetivo_cobertura,
    presupuesto_max,
    tolerancia_presupuesto = 0.10,
    poblacion_total = 47000000,
    tam_batch = 5,
    soportes_vetados = NULL,
    modelo = c("sainsbury", "binomial", "canex"),
    usar_audiencia_util = FALSE,
    correlaciones = NULL,
    truncation_order = 2) {

  # Model validation
  modelo <- match.arg(modelo)

  if(modelo == "canex") {
    if(is.null(correlaciones)) {
      stop("correlaciones matrix is required when using canex model")
    }
    if(nrow(correlaciones) != ncol(correlaciones)) {
      stop("correlaciones must be a square matrix")
    }
    if(nrow(correlaciones) != nrow(soportes_df)) {
      stop("correlaciones dimensions must match number of media vehicles")
    }
  }

  cat("\nIniciando optimización...\n")

  if(usar_audiencia_util && !"indices_utilidad" %in% colnames(soportes_df)) {
    stop("Se solicitó usar audiencia útil pero no se encuentra la columna 'indices_utilidad'")
  }

  soportes_no_encontrados <- character(0)
  if (!is.null(soportes_vetados)) {
    soportes_vetados <- unique(trimws(soportes_vetados))
    for (soporte in soportes_vetados) {
      if (!soporte %in% soportes_df$soportes) {
        soportes_no_encontrados <- c(soportes_no_encontrados, soporte)
        soportes_vetados <- soportes_vetados[soportes_vetados != soporte]
      }
    }
    if (length(soportes_no_encontrados) > 0) {
      cat("\nAVISO: Los siguientes soportes vetados no fueron encontrados:\n")
      cat(paste("-", soportes_no_encontrados, collapse = "\n"))
      cat("\n")
    }
    soportes_df <- soportes_df[!soportes_df$soportes %in% soportes_vetados, ]
  }

  if (nrow(soportes_df) < FEM) {
    stop("No hay suficientes soportes disponibles para alcanzar la FEM requerida")
  }

  if(usar_audiencia_util) {
    soportes_df$audiencias_calculo <- soportes_df$audiencias * soportes_df$indices_utilidad
  } else {
    soportes_df$audiencias_calculo <- soportes_df$audiencias
  }

  soportes_df$eficiencia <- soportes_df$audiencias_calculo / soportes_df$tarifas
  soportes_ordenados <- soportes_df[order(-soportes_df$eficiencia), ]
  n_soportes <- nrow(soportes_ordenados)
  n_batches <- ceiling((n_soportes - FEM + 1) / tam_batch)

  evaluar_batch <- function(batch_combinaciones) {
    resultados <- list()
    costes <- sapply(1:nrow(batch_combinaciones), function(i) {
      sum(soportes_ordenados$tarifas[batch_combinaciones[i,] == 1])
    })

    combinaciones_validas <- which(costes <= presupuesto_max * (1 + tolerancia_presupuesto))

    if(length(combinaciones_validas) == 0) {
      return(NULL)
    }

    for(i in combinaciones_validas) {
      comb <- batch_combinaciones[i,]
      if(sum(comb) >= FEM) {
        selected_indices <- which(comb == 1)

        resultado <- if(modelo == "canex") {
          probs <- soportes_ordenados$audiencias_calculo[selected_indices] / poblacion_total
          selected_corr <- correlaciones[selected_indices, selected_indices]
          insertions <- rep(4, length(selected_indices))  # Cambio a 4 inserciones

          tryCatch({
            res <- canonical_expansion_model(
              marginal_probs = probs,
              correlations = selected_corr,
              insertions = insertions,
              population = poblacion_total,
              truncation_order = truncation_order,
              tolerance = 1e-6  # Aumentada tolerancia
            )

            if(length(res$acumulada$porcentaje) >= FEM) {
              cobertura <- res$acumulada$porcentaje[FEM]
              if(!is.na(cobertura) && cobertura > 0) {
                list(
                  acumulada = list(
                    porcentaje = res$acumulada$porcentaje,
                    personas = res$acumulada$personas
                  )
                )
              } else {
                NULL
              }
            } else {
              NULL
            }
          }, error = function(e) NULL)
        } else if(modelo == "sainsbury") {
          calc_sainsbury(soportes_ordenados$audiencias_calculo[selected_indices],
                         poblacion_total)
        } else {
          calc_binomial(soportes_ordenados$audiencias_calculo[selected_indices],
                        poblacion_total)
        }

        if(!is.null(resultado)) {
          cobertura <- resultado$acumulada$porcentaje[FEM]
          if(!is.na(cobertura)) {
            resultados[[length(resultados) + 1]] <- list(
              combinacion = comb,
              cobertura = cobertura,
              coste = costes[i]
            )
          }
        }
      }
    }
    return(resultados)
  }

  # Definir variables antes del bucle
  mejor_combinacion <- NULL
  mejor_cobertura <- 0
  mejor_coste <- Inf

  cat("\nProcesando por batches...\n")
  pb <- txtProgressBar(min = 0, max = n_batches, style = 3)



  for(batch_idx in 1:n_batches) {
    setTxtProgressBar(pb, batch_idx)

    inicio <- FEM + (batch_idx - 1) * tam_batch
    fin <- min(inicio + tam_batch - 1, n_soportes)

    batch_base <- rep(0, n_soportes)
    batch_base[1:FEM] <- 1

    combinaciones_batch <- matrix(0, nrow = 2^(fin-inicio+1), ncol = n_soportes)
    combinaciones_batch[,1:FEM] <- 1

    for(i in 1:(2^(fin-inicio+1))) {
      bits <- as.integer(intToBits(i-1)[1:(fin-inicio+1)])
      combinaciones_batch[i, inicio:fin] <- bits
    }

    resultados_batch <- evaluar_batch(combinaciones_batch)

    if(!is.null(resultados_batch)) {
      for(resultado in resultados_batch) {
        if(resultado$cobertura > mejor_cobertura) {
          mejor_combinacion <- resultado$combinacion
          mejor_cobertura <- resultado$cobertura
          mejor_coste <- resultado$coste

          cat(sprintf("\nBatch %d/%d - ¡Nueva mejor solución!\n",
                      batch_idx, n_batches))
          cat(sprintf("Cobertura: %.2f%%, Coste: %.2f€\n",
                      mejor_cobertura, mejor_coste))

          if(mejor_cobertura >= objetivo_cobertura) {
            cat("\n¡Objetivo alcanzado! Finalizando búsqueda...\n")
            break
          }
        }
      }
    }

    if(mejor_cobertura >= objetivo_cobertura) break
  }

  close(pb)

  if(is.null(mejor_combinacion)) {
    cat("\nNO SE HA ENCONTRADO SOLUCIÓN FACTIBLE\n")
    cat("===================================\n")
    cat(sprintf("- Presupuesto máximo: %.2f€\n", presupuesto_max))
    cat(sprintf("- FEM requerida: %d impactos\n", FEM))
    cat(sprintf("- Objetivo de cobertura: %.2f%%\n", objetivo_cobertura))

    soporte_min <- soportes_ordenados[which.min(soportes_ordenados$tarifas), ]
    cat(sprintf("\nNota: El soporte más económico cuesta %.2f€ (%s)\n",
                soporte_min$tarifas, soporte_min$soportes))

    return(list(
      exito = FALSE,
      mensaje = "No se encontró solución factible con las restricciones dadas",
      presupuesto_max = presupuesto_max,
      FEM_requerida = FEM,
      objetivo_cobertura = objetivo_cobertura,
      soportes_vetados = soportes_vetados,
      soportes_no_encontrados = soportes_no_encontrados,
      soporte_mas_economico = list(
        nombre = soporte_min$soportes,
        tarifa = soporte_min$tarifas
      )
    ))
  }

  soportes_seleccionados <- soportes_ordenados[mejor_combinacion == 1, ]

  # En optimize_media_plan, modificar la parte de distribución final:
  distribucion_final <- if(modelo == "canex") {
    probs <- soportes_seleccionados$audiencias_calculo / poblacion_total
    selected_indices <- which(mejor_combinacion == 1)
    selected_corr <- correlaciones[selected_indices, selected_indices]

    # Usar vector de inserciones real
    insertions <- c(8, 6, 4)[selected_indices]  # Mantener orden de soportes seleccionados

    res <- canonical_expansion_model(
      marginal_probs = probs,
      correlations = selected_corr,
      insertions = insertions,
      population = poblacion_total,
      truncation_order = truncation_order,
      tolerance = 1e-6
    )

    # Mantener estructura completa del resultado
    res
  } else if(modelo == "sainsbury") {
    calc_sainsbury(soportes_seleccionados$audiencias_calculo, poblacion_total)
  } else {
    calc_binomial(soportes_seleccionados$audiencias_calculo, poblacion_total)
  }

  # Y en la parte de impresión:
  cat("\nDISTRIBUCIÓN DE CONTACTOS:\n")
  cat("------------------------\n")
  cat("\nDistribución normal:\n")

  max_contacts <- length(distribucion_final$distribucion$porcentaje)

  for(i in 1:max_contacts) {
    cat(sprintf("%d contacto%s: %.2f%% (%.0f personas)\n",
                i,
                ifelse(i == 1, " ", "s"),
                distribucion_final$distribucion$porcentaje[i],
                distribucion_final$distribucion$personas[i]))
  }

  cat("\nDistribución acumulada:\n")
  for(i in 1:max_contacts) {
    cat(sprintf("%d+ contacto%s: %.2f%% (%.0f personas)\n",
                i,
                ifelse(i == 1, " ", "s"),
                distribucion_final$acumulada$porcentaje[i],
                distribucion_final$acumulada$personas[i]))
  }

  cat("\nRESUMEN ECONÓMICO:\n")
  cat("----------------\n")
  cat(sprintf("Coste total: %.2f€\n", mejor_coste))
  cat(sprintf("Coste por impacto: %.2f€\n",
              mejor_coste/sum(distribucion_final$distribucion$personas)))

  cat("\nSOPORTES SELECCIONADOS:\n")
  cat("--------------------\n")

  # Preparar tabla de resultados según tipo de audiencia
  if(usar_audiencia_util) {
    tabla_plan <- soportes_seleccionados[
      order(-soportes_seleccionados$eficiencia),
      c("soportes", "audiencias", "audiencias_calculo", "indices_utilidad",
        "tarifas", "eficiencia")]
    names(tabla_plan)[names(tabla_plan) == "audiencias_calculo"] <- "audiencia_util"
  } else {
    tabla_plan <- soportes_seleccionados[
      order(-soportes_seleccionados$eficiencia),
      c("soportes", "audiencias", "tarifas", "eficiencia")]
  }

  print(tabla_plan)

  cat("\nEVALUACIÓN DE OBJETIVOS:\n")
  cat("=====================\n")

  # Evaluación del presupuesto
  presupuesto_usado_pct <- (mejor_coste / presupuesto_max) * 100
  cat(sprintf("\n1. PRESUPUESTO:\n"))
  cat(sprintf("   - Disponible: %.2f€\n", presupuesto_max))
  cat(sprintf("   - Utilizado: %.2f€ (%.1f%%)\n", mejor_coste, presupuesto_usado_pct))
  if(mejor_coste <= presupuesto_max) {
    cat("   ✓ Se ha cumplido la restricción presupuestaria\n")
  } else {
    cat(sprintf("   ⚠ Se ha excedido el presupuesto en %.2f€\n",
                mejor_coste - presupuesto_max))
  }

  # Evaluación de la cobertura
  cat(sprintf("\n2. COBERTURA:\n"))
  cat(sprintf("   - Objetivo: %.2f%%\n", objetivo_cobertura))
  cat(sprintf("   - Alcanzada: %.2f%%\n", mejor_cobertura))
  if(mejor_cobertura >= objetivo_cobertura) {
    cat("   ✓ Se ha alcanzado el objetivo de cobertura\n")
  } else {
    diferencia_cobertura <- objetivo_cobertura - mejor_cobertura
    cat(sprintf("   ⚠ No se ha alcanzado el objetivo. Diferencia: %.2f%%\n",
                diferencia_cobertura))
  }

  # Evaluación de la FEM
  contactos_FEM <- distribucion_final$acumulada$porcentaje[FEM]
  cat(sprintf("\n3. FRECUENCIA EFECTIVA MÍNIMA (FEM):\n"))
  cat(sprintf("   - FEM requerida: %d contactos\n", FEM))
  cat(sprintf("   - Población con %d+ contactos: %.2f%%\n", FEM, contactos_FEM))

  # Resumen general del plan
  cat("\nRESUMEN GENERAL:\n")
  cat("---------------\n")

  if(mejor_coste <= presupuesto_max && mejor_cobertura >= objetivo_cobertura) {
    cat("✓ PLAN ÓPTIMO: Se han cumplido todos los objetivos\n")
  } else {
    if(mejor_coste <= presupuesto_max) {
      cat("⚠ PLAN SUBÓPTIMO: Se ajusta al presupuesto pero no alcanza la cobertura deseada\n")
      cat("   Recomendaciones:\n")
      cat("   - Considerar aumentar el presupuesto\n")
      cat("   - Revisar soportes vetados\n")
      cat("   - Evaluar otros soportes alternativos\n")
    } else if(mejor_cobertura >= objetivo_cobertura) {
      cat("⚠ PLAN SUBÓPTIMO: Alcanza la cobertura pero excede el presupuesto\n")
      cat("   Recomendaciones:\n")
      cat("   - Aumentar el presupuesto disponible\n")
      cat("   - Buscar soportes más eficientes\n")
    } else {
      cat("⚠ PLAN NO VIABLE: No cumple ni presupuesto ni cobertura\n")
      cat("   Recomendaciones:\n")
      cat("   - Revisar objetivos de cobertura\n")
      cat("   - Aumentar presupuesto\n")
      cat("   - Considerar otros soportes\n")
    }
  }

  # Modificar el return para incluir la nueva información
  return(list(
    exito = TRUE,
    cobertura_alcanzada = mejor_cobertura,
    coste_total = mejor_coste,
    soportes_seleccionados = tabla_plan,
    plan_completo = mejor_combinacion,
    objetivo_alcanzado = mejor_cobertura >= objetivo_cobertura,
    presupuesto_cumplido = mejor_coste <= presupuesto_max,
    evaluacion = list(
      presupuesto = list(
        disponible = presupuesto_max,
        utilizado = mejor_coste,
        porcentaje_uso = presupuesto_usado_pct,
        cumplido = mejor_coste <= presupuesto_max
      ),
      cobertura = list(
        objetivo = objetivo_cobertura,
        alcanzada = mejor_cobertura,
        diferencia = objetivo_cobertura - mejor_cobertura,
        cumplido = mejor_cobertura >= objetivo_cobertura
      ),
      FEM = list(
        requerida = FEM,
        poblacion_alcanzada = contactos_FEM
      )
    ),
    distribucion = distribucion_final,
    soportes_vetados = soportes_vetados,
    soportes_no_encontrados = soportes_no_encontrados,
    tipo_audiencia = ifelse(usar_audiencia_util, "util", "bruta"),
    modelo_usado = modelo
  ))
}

