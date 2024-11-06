# Herramientas de Optimización de Planificación de Medios

## Descripción General
Este paquete R proporciona un conjunto completo de herramientas para la optimización de la planificación de medios, implementando diversos modelos para calcular cobertura, distribución de contactos y acumulación de audiencia. El paquete incluye implementaciones de modelos clásicos de planificación de medios como Sainsbury, Binomial, Beta-Binomial, Metheringham y Hofmans.

## Instalación

La forma más fácil de instalar y configurar mediaPlanR es usando las siguientes instrucciones:

```R
# Instalar el paquete devtools si no está instalado
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Instalar mediaPlanR
devtools::install_github("majesus/mediaPlanR", force = TRUE)

# Cargar el paquete
library(mediaPlanR)

# Configurar todo lo necesario (instala y carga todas las dependencias)
setup_mediaPlanR()
```

## Funciones Principales

### 1. Optimización de Distribución Beta-Binomial (`optimizar_d`)

Optimiza la distribución de contactos publicitarios utilizando el modelo Beta-Binomial. Calcula los coeficientes de duplicación (R1 y R2) y encuentra la combinación óptima de parámetros alpha y beta.

#### Características principales:
- Calcula parámetros óptimos alpha y beta
- Determina número óptimo de inserciones
- Genera distribución de contactos completa
- Permite ajustar tolerancia y criterios de convergencia

```R
resultado <- optimizar_d(
  Pob = 100000,          # Tamaño de la población
  FE = 3,                # Frecuencia efectiva
  cob_efectiva = 59000,  # Cobertura objetivo
  A1 = 50000,            # Audiencia primera inserción
  max_inserciones = 5    # Máximo de inserciones
)

# Examinar resultados
print(head(resultado$mejores_combinaciones))
print(resultado$data)
```

### 2. Optimización de Distribución de Contactos Acumulada (`optimizar_dc`)

Similar a `optimizar_d` pero enfocado en distribución de contactos acumulada, trabajando con frecuencia efectiva mínima (FEM).

```R
resultado <- optimizar_dc(
  Pob = 500000,
  FEM = 4,               # Frecuencia efectiva mínima
  cob_efectiva = 250000,
  A1 = 200000,
  max_inserciones = 10,
  tolerancia = 0.03,
  step_A = 0.05,
  step_B = 0.05,
  min_soluciones = 15
)
```

### 3. Modelo de Sainsbury (`calc_sainsbury`)

Implementa el modelo de Sainsbury para calcular la cobertura y la distribución de contactos para medios publicitarios con una única inserción por soporte.

***

![Sainsbury Coverage Extended](https://latex.codecogs.com/png.image?C=1-\prod_{i=1}^{n}(1-\frac{A_i}{P}))

Donde:

* C es la cobertura
* n es el número de soportes
* Ai es la audiencia del soporte i
* P es la población total

***

![Sainsbury Distribution](https://latex.codecogs.com/png.image?P(X=k)=\sum_{|S|=k}\prod_{i\in%20S}p_i\prod_{j\notin%20S}(1-p_j))

Donde:

* |S| = k significa que sumamos sobre todas las combinaciones posibles de k soportes
* pi es la probabilidad de exposición al soporte i (Ai/P)
* El primer producto es sobre los soportes incluidos en la combinación
* El segundo producto es sobre los soportes no incluidos

***

#### Características:
- Considera independencia entre soportes
- Calcula duplicación como producto de probabilidades
- Genera distribución de contactos exacta

```R
audiencias <- c(300000, 400000, 200000)  # Audiencias individuales
pob_total <- 1000000                     # Población total
resultado <- calc_sainsbury(audiencias, pob_total)

# Examinar resultados
print(paste("Cobertura total:", resultado$reach$porcentaje, "%"))
print(resultado$distribucion$personas)    # Personas por número de contactos

# Verificar suma de distribuciones
sum_dist <- sum(resultado$distribucion$porcentaje)/100
print(paste("Suma distribución:", round(sum_dist, 4)))
```

### 4. Modelo Binomial (`calc_binomial`)

Implementa el modelo Binomial para calcular cobertura y distribución de contactos, asumiendo probabilidades homogéneas.

#### Características:
- Asume duplicación aleatoria
- Utiliza probabilidad media de exposición
- Ideal para planes simples con soportes similares

```R
audiencias <- c(300000, 400000, 200000)
pob_total <- 1000000
resultado <- calc_binomial(audiencias, pob_total)

print(paste("Cobertura total:", resultado$reach$porcentaje, "%"))
print(paste("Probabilidad media:", resultado$probabilidad_media))
```

### 5. Modelo Beta-Binomial (`calc_beta_binomial`)

Implementa el modelo Beta-Binomial para calcular audiencia neta acumulada y distribución de contactos.

***

![Beta-Binomial PMF](https://latex.codecogs.com/png.image?P(X=k|n,\alpha,\beta)=\binom{n}{k}\frac{B(k+\alpha,n-k+\beta)}{B(\alpha,\beta)})

***

![R1](https://latex.codecogs.com/png.image?R_1=\frac{\alpha}{\alpha+\beta})

![R2](https://latex.codecogs.com/png.image?R_2=\frac{\alpha(\alpha+1)}{(\alpha+\beta)(\alpha+\beta+1)})

***
![Alpha](https://latex.codecogs.com/png.image?\alpha=\frac{R_1(R_2-R_1)}{2R_1-R_1^2-R_2})

![Beta](https://latex.codecogs.com/png.image?\beta=\alpha\frac{1-R_1}{R_1})
***

#### Características:
- Modela heterogeneidad en probabilidades de exposición
- Requiere datos de audiencias acumuladas (A1 y A2)
- Mayor precisión para poblaciones heterogéneas

```R
resultado <- calc_beta_binomial(
  A1 = 500000,    # Primera audiencia
  A2 = 550000,    # Segunda audiencia
  P = 1000000,    # Población total
  n = 5           # Número de inserciones
)

print(paste("Cobertura:", round(resultado$reach$porcentaje, 2), "%"))
print(paste("Alpha:", round(resultado$parametros$alpha, 4)))
print(paste("Beta:", round(resultado$parametros$beta, 4)))

# Verificar consistencia
sum_dist <- sum(resultado$distribucion$porcentaje)/100
print(paste("Suma distribución:", round(sum_dist +
                                          resultado$parametros$prob_cero_contactos/100, 4)))
```

### 6. Modelo de Hofmans (`calc_hofmans`)

Implementa el modelo de Hofmans para calcular audiencia acumulada con múltiples inserciones en un soporte.

#### Características:
- Considera duplicación constante entre pares de inserciones
- Utiliza parámetro de ajuste alpha
- Ideal para múltiples inserciones en mismo soporte

```R
R1 <- 0.06    # 6% cobertura primera inserción
R2 <- 0.103   # 10.3% cobertura segunda inserción
resultado <- calc_hofmans(R1, R2, N = 5)

print(resultado$results)
print(resultado$parametros)
```

### 7. Optimización de Plan de Medios (`optimize_media_plan`)

Optimiza planes de medios con restricciones mediante procesamiento por lotes.

#### Características:
- Permite elegir entre modelo Sainsbury o Binomial
- Maneja restricciones presupuestarias
- Permite exclusión de soportes específicos
- Trabaja con audiencias brutas o útiles

```R
# Ejemplo con audiencia bruta y modelo Sainsbury
datos <- data.frame(
  soportes = c("Medio1", "Medio2", "Medio3"),
  audiencias = c(1000000, 800000, 600000),
  tarifas = c(50000, 40000, 30000)
)

resultado_bruto <- optimize_media_plan(
  soportes_df = datos,
  fem = 2,
  objetivo_cobertura = 50,
  presupuesto_max = 100000,
  modelo = "sainsbury",
  usar_audiencia_util = FALSE
)

# Ejemplo con audiencia útil y modelo Binomial
datos_util <- data.frame(
  soportes = c("Medio1", "Medio2", "Medio3"),
  audiencias = c(1000000, 800000, 600000),
  tarifas = c(50000, 40000, 30000),
  indices_utilidad = c(1.2, 1.1, 0.9)
)

resultado_util <- optimize_media_plan(
  soportes_df = datos_util,
  fem = 2,
  objetivo_cobertura = 50,
  presupuesto_max = 100000,
  modelo = "binomial",
  usar_audiencia_util = TRUE
)
```

### 8. Modelo MBBD (Morgensztern Beta Binomial Distribution)

Implementa el modelo MBBD para calcular la distribución de contactos de un plan de medios.

#### Características:
- Combina estimación Morgensztern con distribución Beta-Binomial
- Ajuste iterativo de parámetros
- Ideal para planes complejos

```R
resultado <- calc_MBBD(
  m = 3,                          # Número de soportes
  insertions = c(5, 7, 4),        # Inserciones por soporte
  audiences = c(500000, 550000, 600000),  # Audiencias
  RM = 550000,                    # Estimación Morgensztern
  universe = 1000000,             # Universo total
  A0 = 0.1                        # Valor inicial de A
)
```

## Características Generales del Paquete

- Múltiples modelos de cobertura y frecuencia
- Optimización con restricciones presupuestarias
- Soporte para audiencias brutas y ponderadas
- Procesamiento por lotes para cálculos eficientes
- Salida detallada con distribuciones de contactos
- Validación y manejo de errores integrado
- Seguimiento de progreso para operaciones largas

## Detalles de los Modelos

### Modelo de Sainsbury
- Considera independencia entre medios y heterogeneidad
- Calcula duplicación entre inserciones como producto de probabilidades
- Adecuado para una inserción por medio

### Modelo Binomial
- Asume duplicación aleatoria y probabilidades homogéneas
- Usa probabilidad media para todos los medios
- Más simple computacionalmente pero puede ser menos preciso

### Modelo Beta-Binomial
- Modela heterogeneidad usando distribución Beta
- Combina con distribución Binomial
- Requiere solo dos parámetros (alpha, beta)
- Más preciso para poblaciones heterogéneas

### Modelo de Hofmans
- Diseñado específicamente para audiencia acumulada
- Usa parámetro de ajuste (alpha)
- Adecuado para múltiples inserciones en mismo medio

### Modelo MBBD
- Combina estimación Morgensztern con Beta-Binomial
- Ajuste iterativo de parámetros
- Maneja cobertura y distribución de contactos
- Ideal para planes complejos

## Notas de Uso

### Parámetros de Optimización
- `FE/FEM`: Frecuencia efectiva (contactos mínimos por persona)
- `cob_efectiva`: Cobertura objetivo
- `tolerancia`: Margen de error permitido
- `batch_size`: Tamaño de lote para procesamiento
- `presupuesto_max`: Restricción presupuestaria

### Mejores Prácticas
1. Comenzar con objetivos realistas de cobertura y frecuencia
2. Usar índices de utilidad cuando varíe la calidad de audiencia
3. Monitorear convergencia en procesos de optimización
4. Elegir modelo apropiado según caso específico:
  - Sainsbury: Medios independientes
- Beta-Binomial: Población heterogénea
- Hofmans: Múltiples inserciones en mismo medio

### Manejo de Errores
El paquete incluye validación de entrada y manejo de errores:
  - Validación de rangos de parámetros
- Verificaciones de consistencia
- Mensajes de error descriptivos
- Seguimiento de progreso

## Referencias

Aldás Manzano, J. (1998). Modelos de determinación de la cobertura y la distribución de contactos en la planificación de medios publicitarios impresos. Tesis doctoral, Universidad de Valencia, España.

## Contacto y Soporte

- **Autor**: Manuel J. Sánchez-Franco
- **ORCID**: [0000-0002-8042-3550](https://orcid.org/0000-0002-8042-3550)
- **Email**: majesus@us.es
- **Issues**: Para reportar problemas o sugerencias, usa la sección de [Issues](https://github.com/majesus/mediaPlanR/issues)

## Licencia

Este paquete está disponible bajo la licencia MIT. Ver el archivo LICENSE para más detalles.

## Cómo Citar

Si utilizas mediaPlanR en tu investigación, por favor cítalo como:

  ```
Sánchez-Franco, M. J. (2024). mediaPlanR: Herramientas para la Planificación de
Medios Publicitarios. R package version 0.1.1.
https://github.com/majesus/mediaPlanR
```
