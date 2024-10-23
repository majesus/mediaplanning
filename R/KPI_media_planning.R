#__________________________________________________________#

#' @encoding UTF-8
#' @title Cálculo de GRPs mediante cobertura y frecuencia media, o impresiones
#' @description Calcula los Gross Rating Points (GRPs) de un plan de medios
#' utilizando dos métodos diferentes: mediante impresiones totales o mediante
#' cobertura y frecuencia media. Los GRP (Gross Rating Points) son una métrica
#' publicitaria que indica el impacto total de una campaña sobre una audiencia determinada,
#' expresando la suma del alcance por la frecuencia de exposición.
#' Se calculan dividiendo el número total de impresiones (contactos o veces
#' que el anuncio fue visto) por la población relevante, multiplicado por 100,
#' lo cual permite expresar la exposición acumulativa de la campaña como un porcentaje.
#'
#' @param audiencias Vector numérico con las audiencias de cada soporte
#' @param inserciones Vector numérico del número de inserciones por soporte
#' @param pob_total Tamaño total de la población
#' @param cobertura Opcional. Cobertura en porcentaje (si se conoce)
#' @param metodo Character. Método de cálculo: "impresiones" o "cobertura" (default: "impresiones")
#'
#' @details
#' El cálculo se puede realizar mediante dos métodos:
#' \enumerate{
#'   \item Método por impresiones:
#'     \itemize{
#'       \item Calcula impresiones totales: SUMATORIO(Audiencia_i × Inserciones_i)
#'       \item GRPs = (Impresiones / Población) × 100
#'     }
#'   \item Método por cobertura:
#'     \itemize{
#'       \item Frecuencia media = Impresiones totales / (Cobertura × Población)
#'       \item GRPs = Cobertura × Frecuencia media
#'     }
#' }
#'
#' @return Una lista conteniendo:
#' \itemize{
#'   \item grps: Valor de GRPs calculado
#'   \item impresiones_totales: Suma total de impresiones
#'   \item frecuencia_media: Frecuencia media (si aplica)
#'   \item metodo: Método utilizado para el cálculo
#' }
#'
#' @note
#' Los GRPs son una medida de presión publicitaria que:
#' \itemize{
#'   \item Pueden superar el 100%
#'   \item Indican el número de impactos por cada 100 personas del target
#'   \item Son útiles para comparar campañas de diferentes tamaños
#' }
#'
#' @examples
#' # Cálculo por método de impresiones
#' grps1 <- calcular_grps(
#'   audiencias = c(300000, 400000, 200000),
#'   inserciones = c(3, 2, 4),
#'   pob_total = 1000000
#' )
#'
#' # Cálculo por método de cobertura
#' grps2 <- calcular_grps(
#'   audiencias = c(300000, 400000, 200000),
#'   inserciones = c(3, 2, 4),
#'   pob_total = 1000000,
#'   cobertura = 65.5,
#'   metodo = "cobertura"
#' )
#'
#' @export
#' @seealso
#' \code{\link{calcular_cpm}} para cálculo de costes por mil
calcular_grps <- function(audiencias, inserciones, pob_total,
                          cobertura = NULL, metodo = "impresiones") {
  # Validación de inputs
  if (!all(is.numeric(c(audiencias, inserciones, pob_total)))) {
    stop("Los argumentos audiencias, inserciones y población deben ser numéricos")
  }
  if (any(audiencias < 0) || any(inserciones < 0) || pob_total <= 0) {
    stop("Todos los valores deben ser positivos")
  }
  if (length(audiencias) != length(inserciones)) {
    stop("Los vectores de audiencias e inserciones deben tener la misma longitud")
  }

  # Cálculo de impresiones totales
  impresiones_totales <- sum(audiencias * inserciones)

  # Cálculo según método
  if (metodo == "impresiones") {
    grps <- (impresiones_totales / pob_total) * 100
    frecuencia_media <- NULL
  } else if (metodo == "cobertura") {
    if (is.null(cobertura)) {
      stop("Para el método de cobertura, debe proporcionar el valor de cobertura")
    }
    if (cobertura <= 0 || cobertura > 100) {
      stop("La cobertura debe estar entre 0 y 100")
    }
    frecuencia_media <- impresiones_totales / (cobertura/100 * pob_total)
    grps <- cobertura * frecuencia_media
  } else {
    stop("Método no válido. Use 'impresiones' o 'cobertura'")
  }

  return(list(
    grps = grps,
    impresiones_totales = impresiones_totales,
    frecuencia_media = frecuencia_media,
    metodo = metodo
  ))
}

#__________________________________________________________#

#' @encoding UTF-8
#' @title Cálculo de CPM para plan de medios o soportes individuales
#' @description Calcula el Coste Por Mil (CPM) ya sea para un plan de medios
#' completo o para soportes individuales, permitiendo evaluar la eficiencia
#' en términos de coste por cada mil personas alcanzadas, es decir, permite
#' comparar la rentabilidad de diferentes estrategias y medios dentro del mismo plan de campaña.
#'
#' @param precios Vector numérico con precios de cada inserción o precio total (presupuesto) del plan
#' @param audiencias Vector numérico con audiencias de cada soporte
#' @param cobertura Opcional. Cobertura del plan en personas
#' @param tipo Character. Tipo de cálculo: "soporte" o "plan" (default: "soporte")
#'
#' @details
#' El CPM se puede calcular de dos formas:
#' \enumerate{
#'   \item Para soportes individuales:
#'     \itemize{
#'       \item CPM = (Precio inserción / Audiencia) × 1000
#'     }
#'   \item Para plan completo:
#'     \itemize{
#'       \item CPM = (Precio total / Cobertura) × 1000
#'     }
#' }
#'
#' @return Una lista conteniendo:
#' \itemize{
#'   \item cpm: Vector de CPMs calculados o CPM del plan
#'   \item tipo: Tipo de cálculo realizado
#'   \item total: Suma total de precios (si aplica)
#' }
#'
#' @note
#' El CPM es útil para:
#' \itemize{
#'   \item Comparar eficiencia entre soportes
#'   \item Evaluar rentabilidad de planes de medios
#'   \item Optimizar presupuestos publicitarios
#' }
#'
#' @examples
#' # CPM por soportes
#' cpm1 <- calcular_cpm(
#'   precios = c(1000, 1500, 800),
#'   audiencias = c(300000, 400000, 200000)
#' )
#'
#' # CPM del plan completo
#' cpm2 <- calcular_cpm(
#'   precios = 25000,
#'   cobertura = 750000,
#'   tipo = "plan"
#' )
#'
#' @export
#' @seealso
#' \code{\link{calcular_grps}} para cálculo de GRPs
calcular_cpm <- function(precios, audiencias = NULL, cobertura = NULL,
                         tipo = "soporte") {
  # Validación de inputs
  if (!is.numeric(precios) || any(precios < 0)) {
    stop("Los precios deben ser numéricos y positivos")
  }

  if (tipo == "soporte") {
    if (is.null(audiencias)) {
      stop("Para cálculo por soporte, debe proporcionar audiencias")
    }
    if (length(precios) != length(audiencias)) {
      stop("Los vectores de precios y audiencias deben tener la misma longitud")
    }
    if (any(audiencias <= 0)) {
      stop("Las audiencias deben ser positivas")
    }

    # Cálculo CPM por soporte
    cpm <- (precios / audiencias) * 1000
    total <- sum(precios)

  } else if (tipo == "plan") {
    if (is.null(cobertura)) {
      stop("Para cálculo del plan, debe proporcionar la cobertura")
    }
    if (length(precios) > 1) {
      warning("Se usará la suma total de precios para el cálculo del plan")
    }
    if (cobertura <= 0) {
      stop("La cobertura debe ser positiva")
    }

    # Cálculo CPM del plan
    total <- sum(precios)
    cpm <- (total / cobertura) * 1000

  } else {
    stop("Tipo no válido. Use 'soporte' o 'plan'")
  }

  return(list(
    cpm = cpm,
    tipo = tipo,
    total = total
  ))
}

#__________________________________________________________#
