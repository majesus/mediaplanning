# mediaPlanR: Herramientas para la Planificación de Medios Publicitarios

## Descripción
mediaPlanR es un paquete de R que proporciona herramientas para el análisis y planificación de medios publicitarios, incluyendo modelos beta-binomial, análisis de utilidad de audiencia y convergencia de alcance.

## Instalación

La forma más fácil de instalar y configurar mediaPlanR es usando las siguientes instrucciones:

```r
# Instalar el paquete devtools si no está instalado
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Instalar mediaPlanR
devtools::install_github("majesus/mediaPlanR")

# Cargar el paquete
library(mediaPlanR)

# Configurar todo lo necesario (instala y carga todas las dependencias)
setup_mediaPlanR()
```

## Uso

Hay dos formas de usar las aplicaciones:

### Forma Directa
```r
# Explorador Beta-Binomial
run_beta_binomial_explorer()

# Explorador de Utilidad de Audiencia
run_aud_util_explorer()

# Explorador de Convergencia
run_reach_converg_explorer()
```

### Forma Alternativa (con manejo automático de errores)
```r
# La función run_mediaPlanR() verifica automáticamente las dependencias
# y maneja errores comunes

# Explorador Beta-Binomial
run_mediaPlanR("beta")

# Explorador de Utilidad de Audiencia
run_mediaPlanR("aud")

# Explorador de Convergencia
run_mediaPlanR("reach")
```

## Características Principales

- **Análisis Beta-Binomial**: Exploración y análisis del modelo beta-binomial para planificación de medios.
- **Utilidad de Audiencia**: Herramientas para evaluar y analizar la utilidad de diferentes segmentos de audiencia.
- **Convergencia de Alcance**: Análisis de la convergencia en el alcance de campañas publicitarias.

## Requisitos del Sistema

- R versión 2.10 o superior
- Conexión a Internet para la instalación inicial
- Dependencias principales:
  - shiny
  - bslib
  - ggplot2
  - dplyr
  - plotly
  - (otras dependencias se instalarán automáticamente)

## Solución de Problemas

Si encuentras algún error:

1. Ejecuta `setup_mediaPlanR()` para asegurarte de que todas las dependencias están instaladas correctamente.
2. Si el problema persiste, reinstala el paquete:
   ```r
   remove.packages("mediaPlanR")
   devtools::install_github("majesus/mediaPlanR")
   setup_mediaPlanR()
   ```
3. Si ves errores relacionados con 'page_fluid' o 'page_sidebar', ejecuta:
   ```r
   install.packages(c("shiny", "bslib"), force = TRUE)
   ```

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

## Agradecimientos

Agradecemos a todos los usuarios y colaboradores que han ayudado a mejorar este paquete con sus sugerencias y reportes de errores.
