
#__________________________________________________________#

#' @encoding UTF-8
#' @title Cálculo de los valores R1 y R2 (modelo: Beta-Binomial)
#' @name calc_R1_R2
#'
#' @description Calcula los valores R1 y R2 a partir de los
#' parámetros de forma alpha y beta del modelo de audiencia neta acumulada Beta-Binomial.
#' Los valores son clave para evaluar la audiencia neta y la distribución de contactos (y acumulada).
#' Si la probabilidad de éxito se distribuye según una distribución beta de parámetros alpha y beta,
#' la distribución de contactos, es una distribución compuesta: la distribución beta binomial.
#'
#' @param A Parámetro de forma alpha, debe ser numérico y positivo
#' @param B Parámetro de forma beta, debe ser numérico y positivo
#'
#' @details
#' Los coeficientes R1 y R2 son medidas de la duplicación de audiencias:
#' \itemize{
#'   \item R1 mide el tanto por uno de personas alcanzadas tras la primera inserción en el soporte elegido
#'   \item R2 mide el tanto por uno de personas alcanzadas tras la segunda inserción en el soporte elegido
#' }
#'
#' El proceso de cálculo:
#' \enumerate{
#'   \item Calcula R1 directamente como A/(A+B)
#'   \item Optimiza R2 mediante un proceso iterativo
#'   \item Verifica que los valores R1 y R2 estén en el rango (0,1)
#' }
#'
#' @return Una lista con dos componentes:
#' \itemize{
#'   \item R1: Coeficiente (tanto por uno) de audiencia acumulada tras la primera inserción
#'   \item R2: Coeficiente (tanto por uno) de audiencia acumulada tras la segunda inserción
#' }
#'
#' @examples
#' # Calcular R1 y R2 para alpha=0.5 y beta=0.3
#' resultados <- calc_R1_R2(0.5, 0.3)
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
#' \code{\link{calc_beta_binomial}} para estimaciones con el modelo Binomial
#' \code{\link{calc_sainsbury}} para estimaciones con el modelo de Sainsbury
calc_R1_R2 <- function(A, B) {
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
