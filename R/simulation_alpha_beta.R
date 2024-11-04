# Función para realizar la simulación
simular_parametros <- function(A1, P) {
  # Desactivar notación científica
  options(scipen = 999)

  # Crear secuencia de valores para A2 (desde A1 hasta 2*A1)
  A2_valores <- seq(A1, 2*A1, length.out = 100)

  # Inicializar vectores para almacenar resultados
  R1_valores <- c()
  R2_valores <- c()
  alpha_valores <- c()
  beta_valores <- c()
  A2_validos <- c()

  # Calcular R1 (constante para todos los valores)
  R1 <- A1 / P

  # Realizar cálculos para cada valor de A2
  for(A2 in A2_valores) {
    R2 <- A2 / P

    # Calcular alpha y beta
    alpha <- (R1 * (R2 - R1)) / (2 * R1 - R1^2 - R2)
    beta <- (alpha * (1 - R1)) / R1

    # Si alpha o beta son negativos o no son finitos, romper el bucle
    if(!is.finite(alpha) || !is.finite(beta) || alpha < 0 || beta < 0) {
      break
    }

    # Almacenar resultados válidos
    R1_valores <- c(R1_valores, R1)
    R2_valores <- c(R2_valores, R2)
    alpha_valores <- c(alpha_valores, alpha)
    beta_valores <- c(beta_valores, beta)
    A2_validos <- c(A2_validos, A2)
  }

  # Crear un data frame con los resultados
  resultados <- data.frame(
    A2 = A2_validos,
    R2 = R2_valores,
    alpha = alpha_valores,
    beta = beta_valores
  )

  # Configurar el layout para dos gráficos
  par(mfrow = c(1, 2), mar = c(7, 4, 4, 2))

  # Gráfico para alpha
  plot(A2_validos, alpha_valores,
       type = "l",
       col = "blue",
       xlab = "",
       ylab = "alpha",
       main = "Evolución de alpha")

  # Añadir punto donde termina
  points(A2_validos[length(A2_validos)], alpha_valores[length(alpha_valores)],
         col = "red", pch = 19)

  # Añadir etiquetas del eje X rotadas
  axis(1, at = A2_validos[seq(1, length(A2_validos), length.out = 10)],
       labels = round(A2_validos[seq(1, length(A2_validos), length.out = 10)], 2),
       las = 2)
  mtext("A2", side = 1, line = 5)

  # Gráfico para beta
  plot(A2_validos, beta_valores,
       type = "l",
       col = "blue",
       xlab = "",
       ylab = "beta",
       main = "Evolución de beta")

  # Añadir punto donde termina
  points(A2_validos[length(A2_validos)], beta_valores[length(beta_valores)],
         col = "red", pch = 19)

  # Añadir etiquetas del eje X rotadas
  axis(1, at = A2_validos[seq(1, length(A2_validos), length.out = 10)],
       labels = round(A2_validos[seq(1, length(A2_validos), length.out = 10)], 2),
       las = 2)
  mtext("A2", side = 1, line = 5)

  # Añadir leyenda
  legend("topleft",
         legend = c("Valores positivos", "Punto crítico"),
         col = c("blue", "red"),
         pch = c(NA, 19),
         lty = c(1, NA),
         cex = 0.8)

  # Restaurar configuración original del gráfico
  par(mfrow = c(1, 1), mar = c(5, 4, 4, 2))

  # Restaurar configuración de notación científica
  options(scipen = 0)

  # Imprimir el último valor válido
  cat("\nÚltimo valor válido:\n")
  cat("A2 =", round(A2_validos[length(A2_validos)], 4), "\n")
  cat("alpha =", round(alpha_valores[length(alpha_valores)], 4), "\n")
  cat("beta =", round(beta_valores[length(beta_valores)], 4), "\n")

  # Devolver los resultados
  return(resultados)
}

simular_parametros(90200, 1000000)


