# Función de optimización con formatos de impresión corregidos
optimizar_inserciones <- function(datos_entrada,
                                  objetivo_cobertura,
                                  presupuesto_maximo,
                                  min_contactos,
                                  max_inserciones = 20,
                                  num_simulaciones = 100,
                                  tolerancia_presupuesto = 0.05,
                                  tolerancia_cobertura = 0.05,
                                  max_intentos = 10) {

  # Mostrar los parámetros iniciales para depuración
  cat("\nParámetros de entrada:")
  cat(sprintf("\n- Objetivo de cobertura: %.0f", objetivo_cobertura))
  cat(sprintf("\n- Presupuesto máximo: %.2f", presupuesto_maximo))
  cat(sprintf("\n- Mínimo de contactos: %.0f", min_contactos))

  # Calcular límites con tolerancias
  presupuesto_max_tolerado <- presupuesto_maximo * (1 + tolerancia_presupuesto)
  cobertura_min_aceptable <- objetivo_cobertura * (1 - tolerancia_cobertura)

  cat(sprintf("\n\nLímites ajustados:"))
  cat(sprintf("\n- Presupuesto máximo tolerado: %.2f", presupuesto_max_tolerado))
  cat(sprintf("\n- Cobertura mínima aceptable: %.0f", cobertura_min_aceptable))

  # Estimar parámetros para cada soporte
  parametros_bb <- lapply(1:nrow(datos_entrada), function(i) {
    params <- estimar_parametros_mm(
      datos_entrada$audiencia_1[i],
      datos_entrada$audiencia_2[i],
      datos_entrada$poblacion[i]
    )
    cat(sprintf("\n\nSoporte %s:", datos_entrada$soporte[i]))
    cat(sprintf("\n- Alpha: %.3f", params$alpha))
    cat(sprintf("\n- Beta: %.3f", params$beta))
    cat(sprintf("\n- R1: %.3f", params$R1))
    cat(sprintf("\n- R2: %.3f", params$R2))
    params
  })

  # Crear datos_soportes con los parámetros estimados
  datos_soportes <- data.frame(
    soporte = datos_entrada$soporte,
    poblacion = datos_entrada$poblacion,
    alpha = sapply(parametros_bb, function(x) x$alpha),
    beta = sapply(parametros_bb, function(x) x$beta),
    tarifa = datos_entrada$tarifa
  )

  mejor_solucion <- list(
    cobertura = 0,
    coste = Inf,
    inserciones = numeric(nrow(datos_soportes))
  )

  # Para depuración: probar una solución simple
  cat("\n\nProbando solución inicial simple...")
  inserciones_prueba <- rep(1, nrow(datos_soportes))
  coste_prueba <- sum(inserciones_prueba * datos_soportes$tarifa)
  cat(sprintf("\nCoste con una inserción en cada soporte: %.2f", coste_prueba))

  cobertura_prueba <- sum(mapply(calcular_cobertura_bb,
                                 datos_soportes$poblacion,
                                 datos_soportes$alpha,
                                 datos_soportes$beta,
                                 inserciones_prueba,
                                 MoreArgs = list(min_contactos = min_contactos)))
  cat(sprintf("\nCobertura con una inserción en cada soporte: %.0f", cobertura_prueba))

  # Iteración por intentos
  for(intento in 1:max_intentos) {
    cat(sprintf("\n\nIntento %d de %d", intento, max_intentos))
    cat(sprintf("\nNúmero de simulaciones: %.0f", num_simulaciones))

    mejora_en_este_intento <- FALSE

    for(sim in 1:num_simulaciones) {
      inserciones_prueba <- sample(0:max_inserciones, nrow(datos_soportes), replace = TRUE)
      coste <- sum(inserciones_prueba * datos_soportes$tarifa)

      if(coste <= presupuesto_max_tolerado) {
        cobertura <- sum(mapply(calcular_cobertura_bb,
                                datos_soportes$poblacion,
                                datos_soportes$alpha,
                                datos_soportes$beta,
                                inserciones_prueba,
                                MoreArgs = list(min_contactos = min_contactos)))

        if(cobertura >= cobertura_min_aceptable &&
           (cobertura > mejor_solucion$cobertura ||
            (cobertura == mejor_solucion$cobertura && coste < mejor_solucion$coste))) {
          mejor_solucion$cobertura <- cobertura
          mejor_solucion$coste <- coste
          mejor_solucion$inserciones <- inserciones_prueba
          mejora_en_este_intento <- TRUE

          cat(sprintf("\nNueva mejor solución encontrada:"))
          cat(sprintf("\n- Cobertura: %.0f", cobertura))
          cat(sprintf("\n- Coste: %.2f", coste))
        }
      }
    }

    if(!mejora_en_este_intento) {
      cat("\nNo se encontraron mejoras en este intento")
    }

    if(mejor_solucion$cobertura >= cobertura_min_aceptable) {
      cat("\nSe alcanzó el objetivo de cobertura mínima")
      break
    }

    num_simulaciones <- num_simulaciones * 1.5
  }

  # Verificar si se encontró una solución válida
  if(mejor_solucion$cobertura < cobertura_min_aceptable) {
    cat("\n\nADVERTENCIA: No se encontró una solución que cumpla con los objetivos.")
    if(mejor_solucion$cobertura > 0) {
      cat(sprintf("\nMejor cobertura encontrada: %.2f%% del objetivo",
                  100 * mejor_solucion$cobertura / objetivo_cobertura))
      cat(sprintf("\nPresupuesto utilizado: %.2f%% del máximo",
                  100 * mejor_solucion$coste / presupuesto_maximo))
    } else {
      cat("\nNo se encontró ninguna solución válida")
    }
  }

  return(list(
    solucion = mejor_solucion,
    parametros = datos_soportes,
    exito = mejor_solucion$cobertura >= cobertura_min_aceptable
  ))
}

# 1. Primero definimos los datos de entrada
datos_ejemplo <- data.frame(
  soporte = c("Norte Noticias", "La Gaceta del Norte", "El Eco del Norte"),
  poblacion = rep(8500000, 3),  # Población igual para todos
  audiencia_1 = c(595000, 504000, 315000),
  audiencia_2 = c(620000, 720000, 450000),
  tarifa = c(12500, 10800, 7200)
)

# Ejecutamos con valores más conservadores para prueba
resultado <- optimizar_inserciones(
  datos_entrada = datos_ejemplo,
  objetivo_cobertura = 500000,     # Objetivo más bajo para prueba
  presupuesto_maximo = 100000,     # Presupuesto más alto
  min_contactos = 5,               # Menos contactos mínimos
  max_inserciones = 10,            # Menos inserciones máximas
  num_simulaciones = 1000,
  tolerancia_presupuesto = 0.10,   # Mayor tolerancia
  tolerancia_cobertura = 0.10,     # Mayor tolerancia
  max_intentos = 10
)

# 3. Generamos la tabla resumen
tabla_resumen <- generar_tabla_resumen(resultado, min_contactos = 3)

# 4. Mostramos los resultados
print("\nTABLA RESUMEN DE SOPORTES")
print("=========================")
print(tabla_resumen)

# 5. Mostramos el reporte detallado del primer soporte
imprimir_reporte_betabinomial(resultado, 1)

# 6. Mostramos información sobre el éxito de la optimización
cat("\nRESULTADOS GLOBALES:")
cat("\n===================")
cat(sprintf("\nCobertura total alcanzada: %.0f", resultado$solucion$cobertura))
cat(sprintf("\nPresupuesto utilizado: %.2f €", resultado$solucion$coste))
cat(sprintf("\nSolución exitosa: %s", if(resultado$exito) "Sí" else "No"))

