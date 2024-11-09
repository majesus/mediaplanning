---
output:
  pdf_document: default
  html_document: default
---
# Herramientas para la Planificación de Medios Publicitarios

Autor: Manuel J. Sánchez Franco

## Descripción General

**mediaPlanR** proporciona un conjunto completo de herramientas para la planificación de medios publicitarios, implementando diversos modelos para estimar la cobertura, distribución de contactos y acumulación de audiencia. El paquete **mediaPlanR** incluye implementaciones de modelos clásicos de planificación de medios como Sainsbury, Binomial, Beta-Binomial, Metheringham o Hofmans, así como permite el cálculo de las métricas clásicas en la planificación de medios tradicinales.

## Instalación

La forma más sencilla de instalar y configurar **mediaPlanR** es usando las siguientes instrucciones:

```R
# Instalar el paquete devtools si no está instalado
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Instalar mediaPlanR
devtools::install_github("majesus/mediaPlanR", force = TRUE)

# Cargar el paquete mediaPlanR
library(mediaPlanR)
```

***

Antes de aplicar mediaPlanR, haremos un breve resumen de los conceptos clave de la planificación en medios tradicionales.

***

## Planificación de medios

La planificación de medios es el proceso de encontrar la **combinación adecuada de medios publicitarios para llegar a la población objetivo de una marca de manera efectiva y eficiente**. No se trata de alcanzar a la mayor cantidad de personas, sino de conectar con aquellas **_en el momento y lugar precisos_**. Este proceso busca que el anuncio publicitario y la combinación de medios y soportes logre los objetivos de comunicación y marketing diseñados, y optimice el retorno de la inversión (ROI, ROAS _Return On Ad Spend_).

Para el logro de los objetivos es preciso reflexionar en torno a cinco bloques clave. Véase la siguiente tabla.

| Componente | Descripción Detallada (ejemplos) |
|------------|---------------------|
| Público Objetivo | **Base fundamental del plan de medios** <br>- Análisis demográfico: edad, género, ubicación, nivel de ingresos<br>- Psicografía: valores, intereses, estilo de vida<br>- Hábitos de consumo de medios<br>- Comportamiento de compra<br><br>*Ejemplo*: Una marca de fitness que busca llegar a millennials y Generación Z activos en redes sociales con interés en salud y bienestar necesita identificar sus patrones específicos de consumo digital. |
| Objetivos | **Metas claramente definidas y medibles**<br>- Awareness: aumentar reconocimiento de marca<br>- Actitud: mejorar la valoración del uso de la marca<br>- Predisposición a la compra: aumentar la intención de compra<br><br>*Ejemplo*: Si el objetivo es brand awareness, se priorizarán canales de amplio alcance como TV o video online. Para ventas, se enfocará en search marketing y publicidad segmentada. |
| Presupuesto | **Planificación financiera estratégica**<br>- Evaluación de costos por canal<br>- ROI / ROAS esperado por medio<br>- Distribución eficiente de recursos<br>- Escalabilidad del presupuesto<br><br> - Consideraciones:<br>  * TV: alto costo, gran alcance<br>  * Digital: más asequible, mejor segmentación<br>  * Medios impresos: costos variables según alcance<br>  * Exterior: costos fijos con exposición prolongada |
| Canales de Medios | **Ecosistema de medios integrado**<br>- Tradicionales:<br>  * Televisión<br>  * Radio<br>  * Prensa<br>  * Cine<br><br>- Digitales:<br>  * Redes sociales<br>  * Search engines<br>  * Display advertising<br>  * Email marketing<br><br>- Exterior:<br>  * Vallas publicitarias<br>  * Mobiliario urbano<br>  * Transit advertising<br><br>**Métricas**: <br>  * Alcance<br>  * Frecuencia<br>  * Afinidad con target<br>  * Coste por impacto<br>  * Capacidad de segmentación |
| Programación | **Planificación temporal**<br>- Factores clave:<br>  * Estacionalidad del producto/servicio<br>  * Hábitos de consumo del target<br>  * Actividad competitiva<br>  * Eventos relevantes del mercado<br><br>- Consideraciones tácticas:<br>  * Momentos de mayor demanda<br>  * Períodos de compra<br>  * Eventos especiales<br>  * Fechas comerciales clave<br>  * Horarios de mayor consumo mediático del target |


***

En este contexto, un planificador de medios debe pues abordar una serie de preguntas clave para garantizar el éxito de una campaña publicitaria. Estas preguntas se estructuran en las siguientes categorías:

**1. Conocimiento del Mercado y de la Audiencia**

**¿Cuál es el tamaño del mercado y la demanda del producto?** El planificador debe analizar el contexto del mercado del producto o servicio, incluyendo el tamaño actual y futuro del mercado, la segmentación, las cuotas de mercado y las tendencias de la demanda.

**¿Quién es el público objetivo?** Es esencial tener un conocimiento profundo del perfil del consumidor al que se dirige la campaña. Esto incluye el análisis de sus características demográficas, psicográficas, comportamiento de compra, fuentes de información y las influencias personales o familiares que recibe.

**¿Cuáles son sus hábitos de consumo de medios?** Es clave comprender cuáles son los medios que consume el público objetivo, con qué frecuencia y en qué contextos. Esto abarca tanto medios tradicionales como digitales.

**¿Quiénes son los competidores y cuáles son sus estrategias de marketing y comunicación?** El análisis de la competencia y sus actividades publicitarias resulta crucial, así como la comprensión de la presión competitiva del entorno y su influencia en el mercado.

**2. Objetivos y Estrategia de la Campaña**

Es fundamental que los objetivos de la campaña estén definidos de forma SMART, es decir, _específicos, medibles, alcanzables, relevantes y temporales_. Esto garantizará una mayor claridad y efectividad en la evaluación de los resultados.

**¿Cuáles son los objetivos de marketing y comunicación de la marca?** Los objetivos de la planificación de medios deben estar alineados (subordinados estratégicamente) con los objetivos globales de marketing y otros  objetivos de comunicación de la marca.

**¿Qué se quiere lograr con la campaña publicitaria?** Se deben definir objetivos específicos, como aumentar la notoriedad (memoria), mejorar o cambiar las valoraciones del producto o servicio (actitud), o incitar a la acción.

**¿Cuál es el presupuesto disponible para la campaña?**

**¿Qué mensaje se quiere comunicar y qué estrategia creativa se utilizará?** La estrategia creativa del mensaje debe estar en sintonía con los medios seleccionados. El planificador debe evaluar cómo dicha estrategia impacta en la elección de los medios y viceversa.

**3. Selección de Medios y Canales**

**¿Cómo se determinará la efectividad de cada medio en relación con los objetivos definidos?** Es crucial evaluar cada medio en función de su capacidad para cumplir con los objetivos de la campaña. Esto implica realizar pruebas previas, análisis de retorno de inversión (ROI, ROAS) y mediciones de impacto para cada medio seleccionado.

**¿Qué medios y canales son los más adecuados para alcanzar al público objetivo y lograr los objetivos de la campaña?** La selección de medios se debe basar en un análisis exhaustivo de la audiencia útil, sus hábitos de consumo, las características de cada medio y la estrategia creativa, así como los costes relativos y absolutos asociados.

**¿Qué combinación de medios tradicionales y digitales será la más efectiva?** Es necesario considerar las ventajas y limitaciones de cada medio, buscando la combinación óptima que maximice el impacto de la campaña.

**¿Cuál es la cobertura y frecuencia óptimas para la campaña?** El planificador debe definir la cobertura efectiva (cuántas personas deben ser alcanzadas por la campaña) y la frecuencia efectiva (cuántas veces deben exponerse al mensaje) para alcanzar los objetivos.

**4. Implementación, Monitoreo y Evaluación**

**¿Cómo se garantizará la evaluación continua durante la campaña?** Para asegurar la evaluación constante, se deben realizar mediciones regulares durante la implementación de la campaña. Esto incluye el seguimiento de indicadores clave de rendimiento (KPIs) a antes (pre-test) y a lo largo del ciclo de vida de la campaña y la realización de ajustes oportunos según los resultados obtenidos.

**¿Cómo se implementará el plan de medios?** Es esencial definir los aspectos operativos, como la compra de espacios publicitarios, la producción de los anuncios y la gestión de la campaña.

**¿Cómo se medirá la efectividad del plan?** Se deben establecer indicadores clave de rendimiento (KPIs) para evaluar el éxito de la campaña, como el retorno de la inversión, el impacto en ventas y rentabilidad así como en los objetivos publicitarios definidos, y otros indicadores relevantes.

**5. Presupuesto y Gestión Financiera de la Campaña**

**¿Cómo se determinará el presupuesto publicitario?** El planificador debe establecer el presupuesto considerando diferentes métodos: porcentaje sobre ventas, paridad competitiva, objetivos y tareas, o histórico ajustado. La elección del método dependerá de factores como la etapa del producto, el entorno competitivo y los objetivos de marketing.
**¿Cuál es la distribución óptima del presupuesto entre medios?** Es fundamental determinar la asignación presupuestaria entre los diferentes canales, considerando, por ejemplo:

- Medio principal (40-50%): canal con mayor impacto para objetivos primarios
- Medios de apoyo (20-30%): complementan y refuerzan el mensaje
- Medios tácticos (10-20%): acciones específicas y oportunidades
- Innovación y pruebas (5-10%): nuevos formatos y canales

**¿Cómo se optimizará el rendimiento del presupuesto?** Se debe establecer un sistema de control y optimización que incluya:

- Métricas de eficiencia: CPM, CPC, CPL, ROAS
- KPIs financieros: ROI, ROAS, margen sobre inversión publicitaria
- Control de costes: producción, espacios, implementación
- Flexibilidad para ajustes según resultados

**¿Qué consideraciones adicionales afectan al presupuesto?**

- Estacionalidad del negocio y del consumo mediático
- Presión competitiva y _share of voice_ (SOV) deseado
- Costes de producción y adaptación de materiales
- Reserva para contingencias y oportunidades
- Economías de escala y negociación con medios

**¿Cómo se evaluará la eficiencia presupuestaria?** Es necesario establecer:

- Sistema de _reporting_ financiero regular
- Análisis de desviaciones y causas
- Medición de retorno por canal y campaña
- Benchmarks de eficiencia por medio y formato
- Optimización continua de la inversión

**6. Consideraciones Adicionales**

**¿Cómo se integrará la planificación de medios con otras áreas del marketing?** La planificación de medios debe estar subordinada a una estrategia de comunicación integrada, coordinando todas las herramientas de marketing para maximizar la coherencia e impacto. Esto implica una colaboración estrecha, asegurando que todas las acciones sean consistentes y contribuyan a los objetivos estratégicos de la marca. La palabra clave es sinergia.

**¿Cómo se integrará la planificación de medios con otras áreas del marketing?** La planificación de medios debe estar alineada con una estrategia de comunicación integrada, coordinando todas las herramientas de marketing para maximizar la coherencia e impacto.

**¿Cómo se adaptará el plan de medios al entorno mediático en constante cambio?** El planificador debe mantenerse actualizado respecto a nuevas tendencias, plataformas y tecnologías, y ser flexible para ajustar la estrategia según lo requieran las circunstancias.

En resumen, el planificador de medios debe ser un estratega capaz de analizar información compleja, tomar decisiones informadas y adaptarse a un entorno en constante evolución. Su objetivo primordial es conectar eficazmente la marca con su público, maximizando el retorno de la inversión y contribuyendo al logro de los objetivos de marketing de manera eficiente.

</details>

***

## Conceptos básicos de la planificación de medios

### Métricas relativas a la población:

#### BDI / CDI

El **BDI (índice de desarrollo de marca) y el CDI (índice de desarrollo de categoría)** son dos métricas cruciales utilizadas en la planificación de medios para analizar el rendimiento de una marca y su potencial de crecimiento en diferentes mercados geográficos. El CDI se utiliza como medida de potencial, mientras que el BDI es una medida de la fuerza real de la marca.

- **BDI**: Este índice mide la fuerza de las ventas de una marca en un mercado específico (en %) en relación con el tamaño de la población de ese mercado (en %). Se calcula como el porcentaje de ventas de la marca en un mercado dividido por el porcentaje de la población de ese mercado. Un BDI de 100 significa que las ventas de la marca en ese mercado reflejan la población. Si el índice es inferior a 100, la marca no se consume o usa al nivel per cápita en términos relativos; si el BDI es superior a 100, el consumo es mayor que el nivel per cápita en términos relativos. 

- **CDI**: Este índice mide la fuerza de las ventas de una categoría de producto en un mercado específico (en %) en relación con el tamaño de la población de ese mercado (en %). Al igual que el BDI, se calcula como el porcentaje de ventas de la categoría en un mercado dividido por el porcentaje de la población de ese mercado. 

**Cálculo del BDI / CDI**

| Métrica | Cálculo | Interpretación |
|---------|---------|----------------|
| BDI (Índice de Desarrollo de Marca) | (% de Ventas de la Marca en el Mercado / % de Población en el Mercado) x 100 | BDI > 100: Alta cuota de mercado<br>BDI = 100: Ventas de marca proporcionales a la población del mercado<br>BDI < 100: Baja cuota de mercado |
| CDI (Índice de Desarrollo de Categoría) | (% de Ventas de la Categoría en el Mercado / % de Población en el Mercado) x 100 | CDI > 100: Alto potencial de ventas de la categoría<br>CDI = 100: Ventas de categoría proporcionales al mercado<br>CDI < 100: Bajo potencial de ventas de la categoría |

***

<details>
<summary>Haz clic para mayor desarrollo</summary>

***

**Uso del BDI / CDI**

El análisis BDI/CDI se utiliza para identificar los mercados donde una marca tiene un buen rendimiento y dónde hay potencial de crecimiento. Se suele representar gráficamente en un gráfico de cuadrantes, donde cada cuadrante refleja una relación diferente entre la marca y la categoría:

- Cuadrante I (Alto BDI, Alto CDI): Tanto la marca como la categoría son fuertes en este mercado. Esta es una buena área para defender.

- Cuadrante II (Alto BDI, Bajo CDI): El BDI es mucho más fuerte que el CDI, lo que significa que el único crecimiento de la marca en este mercado estaría limitado al crecimiento de la categoría.

- Cuadrante III (Bajo BDI, Alto CDI): La categoría es más fuerte que la marca en este mercado. Esta es el área de oportunidad.

- Cuadrante IV (Bajo BDI, Bajo CDI): Tanto la marca como la categoría son débiles en este mercado. Esta es un área donde se evitaría invertir en publicidad.

Además del gráfico de cuadrantes, se puede utilizar el **índice de oportunidad de marca (BOI)** para identificar mercados con potencial de crecimiento. El BOI se calcula dividiendo el CDI por el BDI. Un BOI alto indica una mayor oportunidad para el crecimiento de la marca.

![BDI/CDI](./img/grafico-bdi-cdi.svg)

**Factores adicionales**

Es importante tener en cuenta que el análisis BDI/CDI no es el único factor a considerar en la planificación geográfica. La distribución también juega un papel fundamental. Una marca puede tener un BDI bajo en un mercado debido a una distribución limitada. En estos casos, se recomienda realizar un análisis de ventas por punto de distribución para evaluar el rendimiento de la marca en los puntos donde está disponible.

En resumen, el BDI y el CDI son herramientas valiosas para comprender el rendimiento de una marca y su potencial de crecimiento y rentabilidad en diferentes mercados. Sin embargo, es crucial considerar estos índices en conjunto con otros factores, como la distribución y la competencia, para tomar decisiones informadas sobre la asignación de recursos de marketing.

</details>

***

#### Coeficiente (índice) de afinidad

El coeficiente (índice) de afinidad mide la propensión de un grupo específico (segmento o clase) a consumir o usar un producto, servicio o marca en comparación con el resto de la población. Este índice es fundamental para evaluar qué tan relevante o atractivo es un producto para un grupo particular, ayudando a los especialistas en marketing a optimizar sus estrategias de segmentación y posicionamiento.

En particular, en el ámbito de la planificación de medios el coeficiente de afinidad proporciona información basada en datos que ayuda a seleccionar los canales de medios más relevantes para tu campaña. No se trata solo de llegar a una gran audiencia, sino de llegar a la audiencia adecuada. Esto asegura que el mensaje _resuene_ con aquellos que tienen mayor propensión al consumo o uso del producto o servicio, lo que lleva a un mejor rendimiento de la campaña.

**Cálculo del coeficiente (índice) de afinidad**

| Paso | Descripción | Ejemplo |
|------|-------------|----------|
| 1 | Determinar el porcentaje del segmento o clase que usa/consume el producto | 20% de los adolescentes (segmento o clase) ven un programa específico de cocina |
| 2 | Determinar el porcentaje de la población total que usa/consume el producto | 10% de la población total ve el mismo programa de cocina |
| 3 | Dividir el porcentaje del segmento o clase entre el porcentaje de la población total y multiplicar por 100 | (20% / 10%) x 100 = 200 |

**Interpretación del resultado:**

- Valores superiores a 100: Sugieren que el grupo objetivo tiene una mayor afinidad o inclinación por el producto en comparación con la media poblacional. Esto puede indicar que el producto es especialmente atractivo o relevante para ese grupo específico.

- Valores inferiores a 100: Señalan una menor afinidad de la subpoblación respecto al producto, lo que podría sugerir que el producto tiene menos relevancia o penetración en ese grupo en particular.

***

### Métricas relativas a los soportes:

**Audiencia o Audiencia Bruta**  
Número total de personas, expresado frecuentemente en miles (000), que se exponen regularmente a un soporte (vehículo) publicitario. Medida fundamental de alcance numérico que constituye la base para cálculos más específicos como la audiencia útil.

**Audiencia Útil**  
Número de personas de la audiencia de un soporte que pertenece específicamente al público objetivo. Refina la audiencia bruta para centrar los esfuerzos de marketing en el público relevante o target para la campaña publicitaria.

**Índice de Utilidad**  
Expresa el tanto por uno de la audiencia de un soporte que corresponde a la población objetivo. Permite evaluar la eficacia del soporte en términos de su capacidad para alcanzar específicamente al público deseado.

**Vehículo de Medios (Media Vehicle)**  
Soporte específico dentro de un medio publicitario que transporta el mensaje al público objetivo. Características:

- Es el canal específico de transmisión del mensaje
- Puede ser un programa, una publicación, una web específica, etc.
- Su selección afecta directamente a la efectividad del mensaje
- Determina el contexto de exposición al mensaje

**Inserción**  
Colocación física o digital de un anuncio en un soporte publicitario específico. Representa la acción de situar el anuncio o mensaje en el vehículo de medios. Aspectos clave:

- Es el acto de colocación del anuncio en el medio
- Genera oportunidades de ver (OTS) para la audiencia del soporte
- No garantiza la exposición efectiva
- Su efectividad depende de factores como ubicación, formato y contexto

**OTS (Opportunity To See)**  
Oportunidad(es) de ver, oír o leer el anuncio o la oferta promocional. Características fundamentales:

- En singular: representa una única oportunidad de contacto con el mensaje
- En plural: equivale a la frecuencia de exposición
- Representa una oportunidad de atención, no la atención efectiva
- Es la unidad básica para medir la intensidad de una campaña

### Métricas de cobertura y frecuencia

**Alcance o Cobertura (Reach)**  
Número absoluto (o relativo) de individuos del público objetivo expuestos al menos una vez a un mensaje publicitario durante un ciclo específico. Características clave:

- Es uno de los tres parámetros básicos del plan de medios
- Se centra en individuos únicos, no en exposiciones acumuladas
- Puede expresarse en términos absolutos o porcentuales
- Es la base para el cálculo del alcance efectivo

**Patrón de Alcance (Reach Pattern)**  
Distribución de la continuidad individual sobre el público objetivo para alcanzar el alcance efectivo durante el período de planificación. Tipos principales:

- Patrones para Nuevos Productos (4):

  - Blitz Pattern (patrón blitz)
  - Wedge Pattern (patrón cuña)
  - Reverse-wedge/PI Pattern (patrón cuña inversa/PI)
  - Short Fad Pattern (patrón moda corta)

- Patrones para Productos Establecidos (4):

  - Regular Purchase Cycle Pattern (patrón de ciclo de compra regular)
  - Awareness Pattern (patrón de conciencia)
  - Shifting Reach Pattern (patrón de alcance cambiante)
  - Seasonal Priming Pattern (patrón de preparación estacional)

**Frecuencia**  
Número medio de exposiciones por individuo del público objetivo en un ciclo publicitario. Aspectos relevantes:

- Es un promedio de exposiciones por individuo alcanzado
- Debe analizarse junto con su distribución de exposición (o contactos)
- Es uno de los tres parámetros básicos del plan de medios junto con la cobertura y la distribución de exposición

**Distribución de Exposición (o Contactos)**  
Distribución de frecuencia de exposiciones en un ciclo publicitario, expresada como porcentajes del público objetivo. Incluye:

- Porcentaje no alcanzado (0 exposiciones)
- Porcentaje con exclusivamente 1 exposición
- Porcentaje con exclusivamente 2 exposiciones
- Y así sucesivamente

También se calcula la distribución de exposiciòn acumulada, es decir, al menos i exposiciones por personal de la población (o cobertura)

**Rating Point (RP)**  
Representa el 1% de la población alcanzada en caso de realizar una inserción en el soporte publicitario. Características:

- Es una medida estándar en medios publicitarios de difusión
- Facilita la comparación entre diferentes soportes y campañas
- Base para el cálculo de GRPs

**GRPs (Gross Rating Points)**  
- Es una estimación del total de oportunidades de exposición promedio por cada 100 individuos de la población (o target). Características principales:

- 1 GRP significa que el plan de medios y soportes alcanza al 1% del público (o target)
- Se calcula también multiplicando la cobertura en % por la frecuencia media

### Métricas de eficiencia y costes

**CPM (Coste Por Mil)**  
Coste de alcanzar a mil personas de la audiencia o de la cobertura alcanzada. Características:

- Permite comparar eficiencia entre soportes o planes de medios o soportes
- Para el target específico se denomina CPMT

**Coste por Contacto Útil**  
Representa el coste de alcanzar a una persona de la audiencia útil. Características:

- Se calcula dividiendo el coste total de una inserción entre el número de personas de la audiencia útil
- Proporciona una medida más precisa que el CPM
- Considera específicamente el público objetivo

**CPERP (Coste Por Punto de Alcance Efectivo)**  
Coste por porcentaje de alcance efectivo.

**SOV (Share of Voice)**  
Representa la cuota de voz o presencia publicitaria de una marca en comparación con sus competidores. Características:

- Se calcula como porcentaje de impactos totales o GRPs
- Indica la dominancia relativa en el mercado publicitario
- Permite comparar la presencia mediática entre competidores o medios en que se programa
- Es un indicador clave del esfuerzo publicitario relativo

### Conceptos avanzados de planificación

**Ciclo Publicitario**  
Período específico durante el cual se desarrolla una actividad publicitaria planificada. Puede variar desde:

- Una exposición continua durante todo el período
- Ciclos discontinuos con duraciones variables ( _flighting o pulsing_ )

**Ciclo de Compra (Purchase Cycle)**  
Intervalo medio de tiempo entre compras sucesivas en una categoría de producto o servicio. También conocido como:

- IPT ( _Inter-Purchase Time_ ): tiempo entre compras
- IPI ( _Inter-Purchase Interval_ ): intervalo entre compras

Es fundamental para:
- Determinar momentos óptimos de comunicación
- Establecer la frecuencia efectiva (mínima) de exposición
- Diseñar patrones de alcance efectivos
- Sincronizar la comunicación con el comportamiento de compra

**Timing**  
Táctica que busca sincronizar la comunicación con momentos de máxima receptividad del público objetivo. Implica:

- Selección estratégica de momentos de contacto
- Consideración de ciclos de compra y activaciones del reconocimiento de la necesidad de la categoría
- Optimización de la efectividad del mensaje

**Frecuencia Efectiva**  
Número de exposiciones, en un ciclo publicitario, necesario para maximizar la disposición de compra del público objetivo. Se expresa como:

- MEF (Minimum Effective Frequency): nivel mínimo necesario
- MaxEF (Maximum Effective Frequency): nivel máximo antes de generar desgaste

**Alcance Efectivo**  
Número de individuos del público objetivo alcanzados al nivel de frecuencia efectiva (MEF o superior) en un ciclo publicitario. Características:

- Combina alcance y frecuencia efectiva
- Se define dentro del rango [MEF-MaxEF]
- Es un parámetro clave para evaluar planes de medios

**Carryover Publicitario (Advertising Carryover)**  
Persistencia de la disposición de compra generada por las exposiciones publicitarias. Aspectos clave:

- Es el efecto posterior al ciclo publicitario
- La falta de persistencia se considera _decay_ publicitario
- Es especialmente relevante en exposiciones espaciadas en el tiempo
- Afecta directamente al alcance efectivo activo
- Es más significativo cuando hay continuidad en la comunicación

**Alcance Efectivo Activo**  
Número de individuos del público objetivo que mantienen al menos el nivel de frecuencia efectiva mínima (MEF) después del ciclo publicitario. Características:

- Mide la persistencia del efecto publicitario
- Considera el fenómeno de _carryover_
- Es clave para evaluar la efectividad a largo plazo
- Depende de la tasa de decaimiento ( _decay_ ) de los efectos publicitarios

**Dominancia**  
Estrategia donde la frecuencia MEF/c se establece deliberadamente por encima de la competencia principal (LC + 1). Características:

- Busca establecer presencia superior
- Es especialmente relevante en momentos críticos del mercado

***

### Ejemplo de diversas métricas

**Tabla de principales métricas**

| Soporte  | Audiencia_miles | Inserciones | RP | SOV   | Tarifa_Pag_Color | CPM    | C/RP     | Indice_Utilidad | Audiencia_Util_miles | Coste_Contacto_Util |
|----------|----------------|-------------|----|---------|--------------------|--------|----------|----------------|-------------------|-------------------|
| D 1 | 150000          | 1           | 30  | 40,54  | 500               | 3,33 | 16,67 | 0,30           | 45000               | 0,01              |
| D 2 | 100000          | 1           | 20  | 27,03  | 250               | 2,50 | 12,50  | 0,20           | 20000               | 0,01              |
| D 3 | 120000          | 1           | 24  | 32,43  | 400               | 3,33 | 16,67 | 0,25           | 30000               | 0,01              |

***

**Tabla de comparación de opciones publicitarias en función del coste relativo**

| Opción | Coste | Alcance | CPM | C/RP |
|--------|--------|----------|-----|------|
| D 4 | 5.000€ | 100.000 jóvenes adultos | **50€** (5.000€ / (100.000 / 1.000)) | **100€** (5.000€ / (100.000 / 500.000 * 100)) |
| D 5 | 2.500€ | 25.000 jóvenes adultos (5% de la población = 5 RP) | **100€** (2.500€ / (25.000 / 1.000)) | **500€** (2.500€ / 5) |

Población = 500.000 personas

***

La función **calcular_metricas_medios()** del paquete mediaPlanR permite estimar la tabla resumen del conjunto de soportes elegidos.

#### Aplicación de la función:

```R
resultado <- calcular_metricas_medios(
  soportes = c("D 1", "D 2", "D 3"),
  audiencias = c(1500, 1000, 1200),
  tarifas = c(500, 250, 400),
  ind_utilidad = c(0.3, 0.20, 0.25),
  pob_total = 39500000)
head(resultado)
```

***

### Objetivos del Plan de Medios

#### Cobertura efectiva

Se refiere al porcentaje o número absoluto de individuos del público objetivo que deben estar expuestos al mensaje publicitario con una frecuencia igual o superior a la frecuencia efectiva mínima. El objetivo es lograr que la disposición hacia la compra supere un determinado nivel crítico, considerando tres elementos fundamentales:

- Brand awareness (notoriedad de marca, memoria)
- Brand attitude (actitud de marca, hacie el uso de la marca)
- Brand purchase intention (disposición a la compra, intención)

#### Frecuencia efectiva

Es el número de veces ( _oportunidades de ver_ ) que un individuo debe exponerse a un mensaje publicitario dentro del ciclo publicitario para que la publicidad logre **disponer al individuo hacia la compra de la marca**. 

#### Frecuencia Efectiva Mínima (FEM)

Es el número mínimo de exposiciones necesarias para que la disposición a la compra supere el umbral crítico que activará el comportamiento deseado. Este umbral varía según el tipo de publicidad:

1. _Low risk/informacional_: Para productos/servicios de bajo riesgo donde el mensaje es principalmente informativo. Por ejemplo, productos de conveniencia o compra frecuente como detergentes o productos de limpieza, donde la comunicación se centra en características funcionales y beneficios directos del producto.

2. _Low risk/transformacional_: Para productos/servicios de bajo riesgo donde el mensaje busca transformar percepciones/actitudes. Por ejemplo, snacks, refrescos o productos de cuidado personal donde la comunicación se centra en aspectos emocionales, estilo de vida o beneficios experienciales.

3. _High risk/informacional_: Para productos/servicios de alto riesgo donde el mensaje es principalmente informativo. Por ejemplo, seguros o servicios financieros, donde el mensaje se centra en explicar características específicas, condiciones y beneficios concretos del servicio.

4. _High risk/transformacional_: Para productos/servicios de alto riesgo donde el mensaje busca transformar percepciones/actitudes. Por ejemplo, automóviles de lujo o joyería de alta gama, donde la comunicación busca crear una conexión emocional y transformar la percepción de estatus o estilo de vida del consumidor.

La determinación precisa de estos parámetros es fundamental para:

- Optimizar la inversión publicitaria
- Lograr los objetivos de comunicación de forma eficiente
- Evitar tanto la infraexposición (por debajo del umbral) como la sobreexposición (que puede generar desgaste publicitario)

***
### Guía de cálculo de la frecuencia efectiva mínima

La frecuencia efectiva mínima (MEF) se determina mediante la fórmula:

$$
\text{MEF/c} = 1 + \text{VA} \times (\text{TA} + \text{BA} + \text{BATT} + \text{PI})
$$

Donde:

$$
\begin{aligned}
\text{VA} & = \text{Vehicle Attention (Atención al medio)} \\
\text{TA} & = \text{Target Audience (Audiencia objetivo)} \\
\text{BA} & = \text{Brand Awareness} \\
\text{BATT} & = \text{Brand Attitude} \\
\text{PI} & = \text{Personal Influence (Influencia personal)}
\end{aligned}
$$

![FE_Ostrow_1982](./img/img_FEM_table.png){width=75%}

Los factores que determinan el nivel de la MEF son:

1. **Atención al vehículo publicitario**:

  - Medios de alta atención (TV prime time, revistas principales)
  - Medios de baja atención (otros horarios TV, radio)

2. **Tipo de audiencia objetivo**:

  - Leales a la marca 
  - Switchers de marca
  - Usuarios de otras marcas
  - Nuevos usuarios de categoría

3. **Objetivos de comunicación**:

  - Reconocimiento 
  - Recuerdo  
  - Estrategia de marca informativa 
  - Estrategia de marca transformativa 

4. **Influencia personal**:

- Alta (reduce la frecuencia necesaria)
- Baja (requiere mayor frecuencia publicitaria)

***

A continuación, te ofrecemos una propuesta alternativa de Ostrow (1982) basada en **factores de marketing, _copy_ y medios** que determinan los niveles de frecuencia efectiva.

![FE_Ostrow_1982](./img/img_factors_FE_Ostrow_1982.png)

***

### Estrategias de cobertura y distribución de exposición

Los patrones de alcance constituyen el fundamento de la planificación estratégica en medios publicitarios. Se dividen en dos grandes categorías según la etapa del producto en el mercado: patrones para productos nuevos y patrones para productos establecidos. Cada patrón responde a necesidades específicas de comunicación y objetivos de marketing.

_Las imágenes han sido tomadas de "Advanced Media Planning", por J. R. Rossiter y P. J. Danaher, 1998, Kluwer Academic Publishers. Copyright 1998 por Kluwer Academic Publishers. Reproducido con fines académicos._

#### Patrones para Productos Nuevos**

**_Blitz_: Máxima Intensidad Inicial**

Un blitz publicitario representa la estrategia más intensiva de entrada al mercado. Mantiene un alcance del 100% del público objetivo durante todo un año, con al menos 50 exposiciones semanales por consumidor. Su objetivo es maximizar la ventaja del first-mover en el mercado.

Para implementar un blitz efectivo, los productos informativos requieren entre 2 y 4 ejecuciones publicitarias diferentes, mientras que los productos transformacionales necesitan de 4 a 6 ejecuciones para mantener el impacto sin generar desgaste.

![FE_Ostrow_1982](./img/img_blitz_pattern.png){width=75%}

**_Wedge_: La Estrategia de la Cuña**

El wedge pattern representa el enfoque más común para lanzamientos. Su estructura es distintiva: comienza con una alta intensidad (400 GRPs semanales) que se reduce gradualmente (hasta 100 GRPs), manteniendo el alcance pero ajustando la frecuencia.

Este patrón se adapta especialmente bien a productos de compra regular. Los datos Nielsen nos muestran ejemplos concretos de ciclos de compra: margarina (19 días), papel higiénico (20 días) y mantequilla de cacahuete (48 días). La estrategia acompaña estos ciclos naturales de compra.

![FE_Ostrow_1982](./img/img_wedge_pattern.png){width=75%}

**_Reverse-Wedge/PI_: La Estrategia del Contagio**

El reverse-wedge aprovecha la influencia personal (PI) como catalizador de la adopción. Comienza con un alcance limitado que se expande progresivamente. Un caso ejemplar fue Toohey's Brewery en Australia, cuyo éxito llevó a que otras marcas replicaran la estrategia.

Este patrón resulta particularmente efectivo para:

- Innovaciones industriales
- Productos que requieren aprendizaje
- Situaciones donde la influencia personal es crucial para la adopción

![FE_Ostrow_1982](./img/img_reverse_wedge_pattern.png){width=75%}

**_Short Fad_: La Estrategia del Momento**

Diseñado para productos con ciclo de vida corto, el short fad actúa como un blitz condensado. Se aplica en:

- Lanzamientos de películas
- Programas de pérdida de peso
- Moda de temporada
- Juguetes y juegos
- Productos "get-fit"

![FE_Ostrow_1982](./img/img_short_fad_pattern.png){width=75%}

#### Patrones para Productos Establecidos

**_Regular Purchase Cycle_: Ritmo y Constancia**
Este patrón sincroniza la publicidad con los ciclos naturales de compra. La clave está en alternar períodos de actividad publicitaria con hiatus, siguiendo el ritmo de compra del consumidor.

Los ciclos de compra varían según el producto. Nielsen documenta ciclos específicos:

- Margarina: 19 días
- Papel higiénico: 20 días
- Mantequilla de cacahuete: 48 días

![FE_Ostrow_1982](./img/img_regular_pattern.png){width=75%}

**_Awareness_: Mantener la Presencia**

Diseñado para productos con ciclos de compra extensos y decisiones prolongadas, como:

- Viajes de larga distancia
- Automóviles nuevos
- Artículos de lujo
- Equipamiento industrial
- Servicios de consultoría

![FE_Ostrow_1982](./img/img_awareness_pattern.png){width=75%}

**_Shifting Reach_: Movimiento Estratégico**

Esta estrategia se mueve entre diferentes segmentos del mercado, alcanzando aproximadamente 12% en cada ciclo. Es ideal para servicios como:

- Limpieza de alfombras domésticas
- Remodelación de oficinas
- Servicios de emergencia
- Servicios de mantenimiento

![FE_Ostrow_1982](./img/img_shifting_pattern.png){width=75%}

**_Seasonal Priming_: Anticipación y Temporalidad**

Se aplica a productos con marcada estacionalidad. Distingue entre:

Productos de bajo riesgo:

- Remedios para resfriados
- Condimentos para barbacoa

Productos de alto riesgo:

- Equipamiento de snowboard/ski
- Piscinas residenciales
- Servicios de consultoría fiscal

![FE_Ostrow_1982](./img/img_seasonal_pattern.png){width=75%}

#### Conclusión

La efectividad de cada patrón depende de su correcta aplicación según el tipo de producto, ciclo de compra y comportamiento del consumidor. La clave está en seleccionar el patrón que mejor se ajuste a estos factores, considerando siempre el presupuesto disponible y los objetivos de marketing.


<details>
<summary>Haz clic para mayor desarrollo</summary>

***

### 1. BLITZ PATTERN

**Ejemplos de Productos/Categorías:**
- Smartphones de nueva generación (ej: lanzamiento iPhone)
- Nuevos modelos de automóviles
- Plataformas de streaming al entrar en un mercado
- Nuevas cadenas de retail
- Servicios financieros innovadores

**Características Estratégicas:**
- Alcance continuo y elevado (100% target)
- Frecuencia alta sostenida (mínimo 1 exposición semanal)
- Sin ciclos/flighting - Presión continua
- Duración típica: 1 año (puede requerir hasta 2 años)

**Planificación Táctica:**
1. Base creativa:
   - Pool de 2-4 ejecuciones para mensajes informacionales
   - 4-6 ejecuciones para mensajes transformacionales
   - Rotación para evitar desgaste

2. Mix de medios:
   - Medios masivos de alta cobertura
   - Complemento con medios de alta afinidad
   - Sin huecos en la planificación

3. Distribución de la presión:
   - GRPs semanales estables y elevados
   - Distribución homogénea de impactos

**Justificación:**
- Maximiza ventaja first-mover
- Supera barreras de entrada en mercado
- Maximiza tasa de prueba
- Suprime efectos publicidad competitiva

### 2. WEDGE PATTERN

**Ejemplos de Productos/Categorías:**
- Productos de cuidado personal innovadores
- Nuevas marcas de alimentación
- Servicios de suscripción
- Apps y servicios digitales
- Productos de limpieza con nueva tecnología

**Características Estratégicas:**
- Intensidad decreciente en el tiempo
- Frecuencia alta inicial que decrece
- Alcance mantenido con menor frecuencia
- Patrón más común en lanzamientos

**Planificación Táctica:**
1. Fases:
   - Fase 1: Blitz inicial (alta inversión)
   - Fase 2: Reducción gradual de presión
   - Fase 3: Mantenimiento

2. Mix de medios:
   - Inicio: Medios masivos + alta afinidad
   - Evolución: Optimización hacia medios eficientes
   - Final: Foco en medios de mantenimiento

3. Distribución de presión:
   - GRPs decrecientes por fase
   - Mantenimiento de cobertura neta
   - Optimización de frecuencia efectiva

**Justificación:**
- Eficiente para productos de compra regular
- Early adopters requieren menor frecuencia posterior
- Permite optimización presupuestaria
- Adecuado cuando hay lealtad post-prueba

### 3. REVERSE-WEDGE/PI PATTERN

**Ejemplos de Productos/Categorías:**
- Software empresarial
- Equipamiento industrial innovador
- Nuevas tecnologías B2B
- Servicios profesionales especializados
- Soluciones de energía renovable

**Características Estratégicas:**
- Frecuencia creciente en el tiempo
- Alcance 100% con aumento de frecuencia
- Expansión progresiva de target
- Rol clave de influencia personal

**Planificación Táctica:**
1. Fases:
   - Fase 1: Innovadores/early adopters
   - Fase 2: Expansión a early majority
   - Fase 3: Mercado masivo

2. Mix de medios:
   - Inicio: Medios segmentados/especializados
   - Evolución: Incorporación medios masivos
   - Final: Mix completo con alta presión

3. Distribución de presión:
   - GRPs crecientes por fase
   - Expansión de cobertura
   - Aumento progresivo de frecuencia

**Justificación:**
- Óptimo cuando influencia personal es clave
- Efectivo para innovaciones industriales
- Permite construcción gradual de mercado
- Aprovecha difusión social

### 4. SHORT FAD PATTERN

**Ejemplos de Productos/Categorías:**
- Películas y estrenos de cine
- Videojuegos
- Juguetes de temporada
- Eventos y festivales
- Colecciones de moda fast-fashion

**Características Estratégicas:**
- Concentración intensa y breve (máx. 6 meses)
- Frecuencia muy alta en período corto
- Similar a blitz pero concentrado
- Sin tiempo para construcción gradual

**Planificación Táctica:**
1. Fases:
   - Fase 1: Introducción intensiva
   - Fase 2: Crecimiento acelerado
   - Fase 3: Capitalización rápida

2. Mix de medios:
   - Medios de rápida construcción de cobertura
   - Alta presión en todos los medios
   - Optimización para velocidad vs. eficiencia

3. Distribución de presión:
   - GRPs muy elevados
   - Máxima cobertura en mínimo tiempo
   - Sin períodos de baja intensidad

**Justificación:**
- Para productos de ciclo corto
- Necesidad de rápida penetración
- Categorías de moda/tendencia
- Productos estacionales cortos

### 5. REGULAR PURCHASE CYCLE PATTERN

**Ejemplos de Productos/Categorías:**
- Productos de alimentación básica
- Artículos de higiene personal
- Productos de limpieza del hogar
- Servicios de telecomunicaciones
- Seguros y servicios bancarios básicos

**Características Estratégicas:**
- Ciclos sincronizados con compra
- Alternancia actividad-hiatos planificada
- Aprovechamiento de carryover
- Adaptación a comportamiento real

**Planificación Táctica:**
1. Ciclos:
   - Duración según ciclo de compra real
   - Planificación por momento de compra
   - Coordinación con distribución/promoción

2. Mix de medios:
   - Base en medios afines al ciclo
   - Complemento con medios de continuidad
   - Optimización por momento de compra

3. Distribución de presión:
   - GRPs alineados con ciclo
   - Cobertura efectiva en momento clave
   - Frecuencia efectiva por ciclo

**Justificación:**
- Eficiencia en timing
- Optimización presupuestaria
- Maximización de efectividad
- Adaptación a comportamiento consumidor

### 6. AWARENESS PATTERN

**Ejemplos de Productos/Categorías:**
- Bienes inmobiliarios
- Vehículos de alta gama
- Servicios educativos
- Servicios financieros complejos
- Turismo de lujo

**Características Estratégicas:**
- Ciclos regulares espaciados
- Baja frecuencia por ciclo
- Alta continuidad anual
- Objetivo: recordación vs. acción inmediata

**Planificación Táctica:**
1. Ciclos:
   - Regularidad en presencia
   - Espaciado óptimo entre oleadas
   - Mantenimiento de awareness

2. Mix de medios:
   - Combinación medios caros/económicos
   - Prioridad a medios de construcción de marca
   - Complemento con medios de mantenimiento

3. Distribución de presión:
   - GRPs moderados pero regulares
   - Cobertura sostenida
   - Frecuencia efectiva mínima por ciclo

**Justificación:**
- Productos de ciclo largo
- Decisiones complejas/caras
- Necesidad de presencia continua
- Eficiencia en mantenimiento de marca

### CONSIDERACIONES OPERATIVAS PARA TODOS LOS PATRONES

**1. Factores Cuantitativos:**
- Cálculo MEF específico del patrón
- Determinación MaxEF para evitar desgaste
- Métricas VA por medio
- GRPs/TRPs necesarios
- SOV objetivo vs. competencia

**2. Factores Cualitativos:**
- Características del TA
- Objetivos BA/BATT
- Rol de PI según categoría
- Contexto competitivo
- Estacionalidad

**3. Aspectos Presupuestarios:**
- Distribución temporal
- Cost per Point por medio
- Eficiencia en negociación
- Flexibilidad para ajustes
- Reserva para oportunidades

**4. Sistema de Medición:**
- KPIs específicos por patrón
- Herramientas de tracking
- Métricas de respuesta
- Indicadores de eficiencia
- Sistemas de optimización

**5. Criterios de Corrección:**
- Umbrales de ajuste
- Timing de evaluación
- Mecanismos de compensación
- Flexibilidad táctica
- Protocolos de crisis

</details>

***

# Guía de Media Planning por Patrón de Alcance

## PLANIFICACIÓN PARA PRODUCTOS NUEVOS

### 1. Plan de Medios - Patrón Blitz

**Objetivo:** 100% de alcance con frecuencia sostenida durante un año completo.

**Estructura del Plan:**
- Duración: 12 meses continuos
- Frecuencia mínima: 50+ exposiciones semanales
- Ejecuciones publicitarias:
  * Productos informativos: 2-4 ejecuciones diferentes
  * Productos transformacionales: 4-6 ejecuciones diferentes

**Consideraciones de Planificación:**
- Requiere "pool" amplio de piezas publicitarias
- Mismo posicionamiento estratégico en todas las ejecuciones
- Calendario intensivo y constante
- No se contemplan períodos de hiatus

### 2. Plan de Medios - Patrón Wedge

**Objetivo:** Alto impacto inicial con reducción gradual manteniendo alcance.

**Estructura del Plan:**
- Primera fase: 400 GRPs semanales
- Reducción gradual hasta: 100 GRPs semanales
- Mantener alcance ajustando frecuencia

**Consideraciones Temporales:**
- Duración según categoría
- Para new brands regulares: primer año
- Para promociones introductorias: primeros 6 meses

### 3. Plan de Medios - Patrón Reverse-Wedge/PI

**Objetivo:** Construir adopción gradual a través de influenciadores.

**Estructura del Plan:**
- Fase 1: Alcance concentrado en innovadores
- Fase 2: Expansión gradual
- Fase 3: Alcance de mercado masivo

**Medios y Frecuencia:**
- Incremento progresivo de la frecuencia
- Mantener 100% de alcance en el grupo objetivo de cada fase
- Enfoque en medios que faciliten la influencia personal

### 4. Plan de Medios - Patrón Short Fad

**Objetivo:** Máximo impacto en período corto.

**Estructura del Plan:**
- Fase introducción: alta frecuencia y alcance amplio
- Fase crecimiento: sostener intensidad
- Duración total: según ciclo del producto

## PLANIFICACIÓN PARA PRODUCTOS ESTABLECIDOS

### 5. Plan de Medios - Regular Purchase Cycle

**Objetivo:** Sincronización con ciclos de compra.

**Estructura del Plan:**
- Ciclos de 45 días de publicidad
- Períodos de hiatus de 45 días
- Alineación con ciclos de compra documentados:
  * Margarina: 19 días
  * Papel higiénico: 20 días
  * Mantequilla de cacahuete: 48 días

### 6. Plan de Medios - Awareness

**Objetivo:** Mantener disposición de compra en ciclos largos.

**Estructura del Plan:**
- Alto alcance
- Baja frecuencia
- Intervalos amplios entre ciclos
- Inclusión de elementos de respuesta directa

**Ejemplo Documentado:**
Comisión de Turismo Australiana:
- Comerciales TV con doble función
- Números 800 para respuesta
- Integración con sitio web

### 7. Plan de Medios - Shifting Reach

**Objetivo:** Alcance rotativo de diferentes segmentos.

**Estructura del Plan:**
- 8 ciclos publicitarios
- Cada ciclo: ~12% del mercado
- Duración ciclo: aproximadamente 12%
- Meta: 100% acumulado antes de repetir

**Implementación Práctica:**
- Ciclo 1: TV matutina
- Ciclo 2: Series nocturnas
- Ciclo 3: Prime time
- Ciclo 4: Programación nocturna
- Rotación de medios por ciclo

### 8. Plan de Medios - Seasonal Priming

**Objetivo:** Preparación y maximización de temporada alta.

**Estructura del Plan:**
- Fase Priming: 1-2 meses antes del pico
  * Alto alcance
  * Baja frecuencia
- Fase Pico Estacional:
  * Incremento de frecuencia
  * Mantener alcance alto

**Consideraciones Especiales:**
- Productos pueden tener múltiples picos anuales
- Priming debe considerar estado de necesidad de categoría
- Interferencia competitiva alta en temporada

## Notas de Implementación

### Consideraciones Generales:
1. MEF (Minimum Effective Frequency) debe ajustarse según patrón
2. Carryover effects influyen en la planificación de hiatus
3. La frecuencia se basa en el promedio del ciclo de compra
4. El alcance se mantiene como prioridad en todos los patrones

### Factores de Ajuste:
- Presupuesto disponible
- Competencia en categoría
- Objetivos específicos de marketing
- Ciclos de compra documentados

***

### Resultados (esperados) del plan de medios

#### Cobertura

Se refiere al número de personas expuestas durante una oleada o campaña publicitaria **al menos una vez dentro** de un período de tiempo específico. En otras palabras, la cobertura mide el alcance ( _reach_ ), es decir, cuántas personas tienen la oportunidad de ver, leer o escuchar el anuncio.

Proponemos un ejemplo de estimación de la cobertura (o alcance):

**_Tu_ (hipotética campaña de ropa), una inserción por soporte**

| Soportes        | Alcance estimado             |
|------------------------|------------------------------|
| Instagram  | 30% del público     |
| Audio en Spotify | 20% del público |
| Exterior en la Universidad   | 15% del público  |

**Modo de calcular la cobertura conociendo las n-plicaciones**

| Paso                                                | Cálculo                  | Resultado |
|-----------------------------------------------------|--------------------------|-----------|
| 1. Alcance bruto combinado                                | 30% + 20% + 15%          | 65%       |
| 2. Restar duplicaciones                   | 65% - 5% - 3% - 2%       | 55%       |
| 3. Añadir la triplicación (se restó tres veces) | 55% + 1% | 56%       |

Así pues, se calcula el alcance neto de esta campaña en un 56%, y no en el 65% _bruto combinado_ inicial. Permite tomar decisiones más inteligentes sobre la inversión en publicidad y evitar sobrestimar su impacto.

#### Duplicación

La duplicación ocurre cuando una misma persona se expone (o _tiene la oportunidad de ver_, OTS) más de una vez al anuncio durante una campaña publicitaria (en el mismo soporte o en distinto soporte). La audiencia duplicada se define pues como aquellas personas que están expuestas más de una vez a un anuncio en una campaña. 

En la campaña anterior, se estimó una duplicación del 5% entre Instagram y Spotify, un 3% entre Instagram y carteles, y un 2% entre Spotify y carteles.

#### Frecuencia media

Es el número promedio de veces que un individuo se expone durante una campaña publicitaria. La frecuencia media se calcula sumando todas las exposiciones (impactos) y dividiéndolas por el tamaño de la cobertura. Es decir, si la campaña anterior generó 280.000 impactos y alcanzó (al menos una vez) a 100.000 personas, la frecuencia media sería igual a 2,8 oportunidades _de ver el anuncio_ por persona de la cobertura.

La expresión matemática para el cálculo de la frecuencia media es la siguiente:

$Frecuencia = \frac{\sum_{i=1}^{n} A_i \times n_i}{Cobertura}$

#### Distribución de contactos

Se refiere al número de personas de la población (o la cobertura) que se exponen **exclusivamente i veces** al anuncio durante la campaña publicitaria. Describe pues cómo se distribuyen las exposiciones entre la población (o la cobertura). La distribución de contactos puede ser uniforme, donde todos los individuos tienen un número similar de exposiciones, o desigual, donde algunos individuos se exponen el anuncio muchas veces y otros muy pocas. 

Este concepto está relacionado con la frecuencia media; no obstante, la distribución de contactos proporciona una visión más detallada de cómo se alcanzan los niveles de frecuencia efectiva.

En la campaña de ropa _TU_, la distribución de contactos fue la siguiente:

Exclus. 1 vez: 40.000 personas

Exclus. 2 veces: 30.000 personas

Exclus. 3 veces: 30.000 personas


#### Distribución de contactos acumulada

Muestra el número total de personas que han sido expuestas a un anuncio **al menos una vez, dos veces, tres veces, etc.**, durante la campaña publicitaria. La distribución de contactos acumulada permite visualizar el progreso de la campaña en términos de alcance y frecuencia a medida que avanza el tiempo. Es una herramienta útil para analizar la efectividad de la campaña en términos de su frecuencia media efectiva.

En la campaña de ropa _TU_, la distribución de contactos acumulada fue la siguiente:

+1 vez: 100.000 personas

+2 veces: 60.000 personas

+3 veces: 30.000 personas

***

A continuación, te muestro las principales funciones del paquete mediaPlanR.

## Funciones de mediaPlanR

Modelos:
- calc_sainsbury() 
- calc_beta_binomial()     
- calc_binomial() 
- calc_hofmans()           
- calc_MBBD()             
- calc_metheringham() 
- calc_R1_R2() 

Métricas:
- calcular_metricas_medios() 
- calc_cpm()                  
- calc_grps()  
- plot_grp_metricas()  

Optimización:
- optimizar_d()               
- optimizar_dc()              
- optimize_media_plan() 

Aplicaciones Shiny:
- run_aud_util_explorer()     
- run_beta_binomial_explorer() 
- run_reach_converg_explorer()

***

## Modelos de Estimación de Cobertura y Distribución

### Fundamentos y Consideraciones Iniciales

La elección de un modelo de estimación de cobertura y distribución requiere una comprensión profunda de las hipótesis subyacentes. Estas hipótesis, que simplifican la realidad para facilitar la modelización, tienen un impacto directo en la precisión de las estimaciones. En este capítulo, examinaremos las diferentes hipótesis y tipos de modelos disponibles.

### Hipótesis sobre las Probabilidades de Exposición

#### Estacionariedad de las Probabilidades de Exposición

La hipótesis de estacionariedad asume que la probabilidad de exposición de un individuo a un soporte permanece constante a lo largo del tiempo. Esta hipótesis se puede desglosar en dos componentes:

1. **Estacionariedad respecto a los individuos**: La probabilidad de exposición ($p_{ijk}$) de un individuo $j$ a la inserción $k$ en el soporte $i$ es constante para todas las inserciones $k$ en ese soporte.

2. **Estacionariedad respecto a las inserciones**: La probabilidad de exposición ($p_{ijk}$) de un individuo $j$ a la inserción $k$ en el soporte $i$ es idéntica para todos los individuos $j$ que consumen ese soporte.

#### Otras Hipótesis Fundamentales

- **Homogeneidad de la Población**: Asume que todos los individuos de la población objetivo tienen igual probabilidad de exposición a un soporte.

- **Homogeneidad de los Soportes**: Considera que todos los soportes del plan de medios tienen igual capacidad de generar exposición.

- **Aleatoriedad de la Duplicación**: Establece que la probabilidad de exposición a dos soportes diferentes es independiente de la exposición a otros soportes.

- **Aleatoriedad de la Acumulación**: Postula que la probabilidad de exposición a múltiples inserciones en un mismo soporte es independiente de la exposición a otras inserciones.

### Taxonomía de Modelos según Soportes e Inserciones

Los modelos se pueden clasificar en tres categorías principales según su aplicación:

1. **Modelos de Acumulación de Audiencias**

   - Diseñados para planes con $n$ inserciones en un único soporte
   - Focalizados en el efecto acumulativo de exposiciones repetidas

2. **Modelos de Duplicación de Audiencias**

   - Aplicables a planes con una inserción en $n$ soportes diferentes
   - Centrados en el efecto de la exposición a través de múltiples soportes

3. **Modelos de Audiencia Neta Acumulada**

   - Desarrollados para planes con $n$ inserciones en $m$ soportes diferentes
   - Combinan los efectos de acumulación y duplicación

### Clasificación según Enfoque Metodológico

#### Modelos Empíricos (ad hoc)

Estos modelos se caracterizan por:

- Buscar funciones matemáticas que se ajusten a los datos de audiencia disponibles
- No considerar la naturaleza probabilística de la exposición
- Enfocarse en reproducir la evolución de la cobertura según el número de inserciones

**Limitaciones principales**:

- No proporcionan información sobre la distribución de contactos
- No permiten determinar la campaña óptima al no considerar la frecuencia de exposición

#### Modelos Estocásticos

Estos modelos se distinguen por:

- Representar los patrones de audiencia mediante distribuciones de probabilidad
- Considerar la exposición como fenómeno aleatorio
- Asumir probabilidades individuales de exposición

**Características clave**:

- Requieren hipótesis adicionales sobre la probabilidad individual
- Las hipótesis específicas diferencian los distintos modelos estocásticos

### Criterios para la Selección del Modelo

La elección del modelo debe considerar múltiples factores:

1. **Precisión de las Estimaciones**
   - Evaluación del error en la estimación de cobertura
   - Análisis del error en la distribución de contactos

2. **Complejidad del Modelo**
   - Balance entre simplicidad y precisión
   - Evaluación del coste-beneficio de levantar hipótesis simplificadoras

3. **Características del Plan de Medios**
   - Audiencia bruta
   - Niveles de acumulación y duplicación
   - Tamaño relativo de los soportes

### Conclusiones

La selección del modelo de estimación debe basarse en un análisis riguroso que considere:

- Las hipótesis subyacentes
- El tipo de plan de medios a evaluar
- La precisión requerida en las estimaciones
- Los recursos disponibles para la implementación

La comprensión de estos aspectos permite una elección informada que optimiza el balance entre precisión y complejidad del modelo.

***

## Funciones principales de mediaPlanR

### Modelo de Sainsbury (`calc_sainsbury`)

Implementa el modelo de Sainsbury, desarrollado por E. J. Sansbury en la London Press Exchange, para calcular la cobertura y la distribución de contactos para un conjunto de soportes publicitarios y una única inserción por soporte. 

El modelo considera la duplicación aleatoria, las probabilidades individuales de exposición homogéneas, y las probabilidades de exposición del soporte heterogéneas para una estimación más precisa de la cobertura y la distribución de contactos (y acumulada). De las dos últimas hipótesis se deriva que la probabilidad de que un individuo resulte expuesto al soporte i vendrá dado por el cociente entre la audiencia del soporte i (casos favorables) y la población (casos totales). Por su parte, de la asunción de la duplicación aleatoria se deriva que la probabilidad de exposición continuará siendo una variable Bernouilli con diferentes probabilidadades de exposición en cada soporte.

#### Características:
- Considera la independencia entre soportes, es decir, la exposición a un soporte no modifica la probabilidad de resultar expuesto a otro (duplicación aleatoria)
- Asume que las probabilidades de exposición individuales son homogéneas
- Las probabilidades de exposición edl soporte son heterogéneas

***

Cobertura neta (probabilida de al menos 1 contacto):

![Sainsbury Coverage Extended](https://latex.codecogs.com/png.image?C=1-\prod_{i=1}^{n}(1-\frac{A_i}{P}))

Donde:

* C es la cobertura
* n es el número de soportes
* Ai es la audiencia del soporte i
* P es la población total

Aplicando la función de Sainsbury (simplificado) a los datos anteriormente expuestos, este sería el valor (en tanto por uno) de la cobertura neta:

$Cobertura_{neta} = 1 - (1-0,30) \times (1-0,20) \times (1-0,15) = 0,524$

***

Distribución de contactos (probabilidad de exactamente k contactos):

![Sainsbury Distribution](https://latex.codecogs.com/png.image?P(X=k)=\sum_{|S|=k}\prod_{i\in%20S}p_i\prod_{j\notin%20S}(1-p_j))

Donde:

* |S| = k significa que sumamos sobre todas las combinaciones posibles de k soportes
* pi es la probabilidad de exposición al soporte i (Ai/P)
* El primer producto corresponde a las probabilidades de exposición a los soportes i
* El segundo producto corresponde a las probabilidades de no exposición a los soportes j

***

#### Aplicación de la función:

```R
audiencias <- c(300000, 400000, 200000)  
pob_total <- 1000000                     
resultado <- calc_sainsbury(audiencias, pob_total)

# Examinar resultados
print(paste("Cobertura total:", resultado$reach$porcentaje, "%"))
print(resultado$distribucion$personas)    

# Verificar suma de distribuciones
sum_dist <- sum(resultado$distribucion$porcentaje)/100
print(paste("Suma distribución:", round(sum_dist, 4)))
```

### Modelo Binomial (`calc_binomial`)

Implementa el modelo Binomial, desarrollado por Chandon (1985), para calcular la cobertura y distribución de contactos (y acumulada) de plan de medios de n soportes y una única inserción por soporte. El modelo Binomial asume la duplicación aleatoria (i.e.,la exposición a un soporte no modifica la probabilidad de resultar expuesto a otro), y la homogeneidad de las probabilidades de exposición del soporte y las probabilidades individuales de exposición. Uniendo estas dos hipótesis últimas, la probabilidad de exposición de cualquier individuo a un soporte determinado se calcula como la media de las audiencias de cada soporte. Las probabilidades de exposición son estacionarias respecto al tiempo.

#### Características:
- Cada individuo de la población tiene la misma probabilidad de exposición a un soporte i
- La probabilidad de exposición a cada soporte es la misma para cada uno de ellos
- La duplicación de las audiencias es un suceso aleatorio
- Las probabilidades de exposición son estacionarias

***

Cobertura neta (probabilidad de al menos 1 contacto):

![Average Probability](https://latex.codecogs.com/png.image?p=\frac{1}{n}\sum_{i=1}^{n}\frac{A_i}{P})

Donde:

* p es la probabilidad media
* n es el número de soportes
* Ai es la audiencia del soporte i
* P es la población total

***

Distribución de contactos (probabilidad de exactamente k contactos):

![Binomial Distribution](https://latex.codecogs.com/png.image?P(X=k)=\binom{n}{k}p^k(1-p)^{n-k})

Donde:

* k es el número de contactos
* n es el número de soportes
* p es la probabilidad media calculada anteriormente

***

#### Aplicación de la función:

```R
audiencias <- c(300000, 400000, 200000)
pob_total <- 1000000
resultado <- calc_binomial(audiencias, pob_total)

print(paste("Cobertura total:", resultado$reach$porcentaje, "%"))
print(paste("Probabilidad media:", resultado$probabilidad_media))
```

### Modelo Beta-Binomial (`calc_beta_binomial`)

Implementa el modelo Beta-Binomial para calcular la audiencia neta acumulada y la distribución de contactos (y acumulada). El modelo Beta-Binomial considera la heterogeneidad en la probabilidad de exposición de los individuos. 
Combina dos pasos: modela la probabilidad de éxito aplicando la distribución Beta de parámetros alpha y beta -lo cual reduce a dos los datos necesarios para su estimación; y emplea la probabilidad en la distribución Binomial (combinada con la distribución Beta) para valorar la distribución de contactos (y acumulada). Es útil cuando la probabilidad de éxito no es conocida a priori, y puede variar entre los individuos. Los parámetros alpha y beta precisamente permiten ajustar la forma de la distribución para que refleje la incertidumbre en relación con la probabilidad de éxito.


#### Características:
- Modela heterogeneidad de la población en sus probabilidades de exposición
- La acumulación de audiencias no es aleatoria
- Asume la estacionariedad (estabilidad en el tiempo) de las probabilidades de exposición respecto a los individuos o a las inserciones
- Requiere datos de audiencias acumuladas (A1 y A2)
- Mayor precisión para poblaciones heterogéneas

***

Distribución de contactos ((probabilidad de exactamente k contactos))

![Beta-Binomial PMF](https://latex.codecogs.com/png.image?P(X=k|n,\alpha,\beta)=\binom{n}{k}\frac{B(k+\alpha,n-k+\beta)}{B(\alpha,\beta)})

Donde:

* k es el número de contactos
* n es el número de inserciones
* α (alpha) y β (beta) son los parámetros de forma
* B(alpha, beta) es la función beta

***

![R1](https://latex.codecogs.com/png.image?R_1=\frac{\alpha}{\alpha+\beta})

![R2](https://latex.codecogs.com/png.image?R_2=\frac{\alpha(\alpha+1)}{(\alpha+\beta)(\alpha+\beta+1)})

Donde:

* R1 es la proporción de audiencia alcanzada (al menos 1 vez) tras la primera inserción
* R2 es la proporción de audiencia alcanzada (al menos 1 vez) tras la segunda inserción

***
![Alpha](https://latex.codecogs.com/png.image?\alpha=\frac{R_1(R_2-R_1)}{2R_1-R_1^2-R_2})

![Beta](https://latex.codecogs.com/png.image?\beta=\alpha\frac{1-R_1}{R_1})

Donde:

* α (alpha) controla la asimetría hacia valores altos de probabilidad
* β (beta) controla la asimetría hacia valores bajos de probabilidad

***

#### Aplicación de la función:

```R
resultado <- calc_beta_binomial(
  A1 = 500000,    
  A2 = 550000,    
  P = 1000000,    
  n = 5           
)

print(paste("Cobertura:", round(resultado$reach$porcentaje, 2), "%"))
print(paste("Alpha:", round(resultado$parametros$alpha, 4)))
print(paste("Beta:", round(resultado$parametros$beta, 4)))

# Verificar consistencia
sum_dist <- sum(resultado$distribucion$porcentaje)/100
print(paste("Suma distribución:", round(sum_dist +
                                        resultado$parametros$prob_cero_contactos/100, 4)))
```

### Modelo de Hofmans (`calc_hofmans`)

El modelo de Hofmans (1966) aborda específicamente el problema de la acumulación de audiencias para múltiples inserciones en un mismo soporte. Su aportación fundamental radica en adaptar la formulación de Agostini (1961), diseñada originalmente para el cálculo de cobertura entre diferentes soportes, al caso de inserciones sucesivas en un único soporte.

El modelo se basa en dos supuestos simplificadores fundamentales: la constancia de la audiencia del soporte para todas sus inserciones, y la existencia de una duplicación constante entre cualquier par de inserciones. Su principal innovación es el reconocimiento y corrección del comportamiento no lineal de la acumulación de audiencias mediante la introducción de un parámetro de ajuste (α) que modifica el factor de acumulación según el número de inserciones.

Para su aplicación práctica, el modelo requiere únicamente conocer las coberturas de las tres primeras inserciones, permitiendo estimar la cobertura para cualquier número posterior de inserciones. Esta estructura lo hace especialmente útil para la planificación de campañas con múltiples inserciones en un mismo soporte, ofreciendo una estimación más precisa del comportamiento real de la acumulación de audiencias a medio y largo plazo.

#### Características:

Objetivo del modelo:

* Calcular la audiencia acumulada de múltiples inserciones en un ÚNICO soporte

Supuestos fundamentales:

* La audiencia de un soporte es constante para todos sus números
* La duplicación entre dos inserciones cualesquiera es constante e igual a d
* La duplicación no depende de qué par de inserciones estemos considerando
* Para N = 3: Usa una formulación directa
* Para N > 3: Incorpora el parámetro alpha para ajustar el comportamiento no lineal
* alpha es un parámetro de ajuste que mejora la precisión del modelo para un número de inserciones mayor que 3, corrigiendo la suposición inicial errónea de que k era constante.

Datos de partida:

* R1: Cobertura de la primera inserción (proporción entre 0 y 1)
* R2: Cobertura acumulada tras la segunda inserción (proporción entre 0 y 1)
* N ≥ 3: Número de inserciones para las que queremos calcular la cobertura

El modelo calculará como datos adicionales:

* k = 2 * R1 / R2   
* d = 2 * R1 - R2 
* alpha         

***

Imagina un periódico que tiene estas audiencias:

* Lunes: 100,000 lectores
* Martes: 100,000 lectores
* Miércoles: 100,000 lectores

La duplicación constante significa que el número de personas que leen DOS DÍAS CUALESQUIERA es siempre el mismo. Por ejemplo:

* Entre lunes y martes: 60,000 leen ambos días
* Entre martes y miércoles: 60,000 leen ambos días
* Entre lunes y miércoles: 60,000 leen ambos días

Es decir, d = 60,000 para cualquier par de días.

Si NO fuera constante, podría ser:

* Entre lunes y martes: 60,000 leen ambos días
* Entre martes y miércoles: 55,000 leen ambos días
* Entre lunes y miércoles: 40,000 leen ambos días

En el modelo de Hofmans, esta simplificación (duplicación constante) permite calcular:

d = 2R1 - R2

Donde:

* R1 es la cobertura de un día (por ejemplo 100,000)
* R2 es la cobertura acumulada de dos días (por ejemplo 140,000)
* d sería entonces: 2(100,000) - 140,000 = 60,000 lectores duplicados

Esta constante d se utiliza luego en la fórmula para calcular la cobertura para N inserciones, asumiendo que la duplicación entre cualquier par de días será siempre la misma.

***

#### Aplicación de la función:

```R
R1 <- 0.06    
R2 <- 0.103   
resultado <- calc_hofmans(R1, R2, N = 5)

print(resultado$results)
print(resultado$parametros)
```

### Modelo MBBD (Morgensztern Beta Binomial Distribution)

Este modelo se basa en el procedimiento seguido por Leckenby y Boyd  (1984a) en el desarrollo del modelo Hofmans beta binomial, con la salvedad ya  señalada de que la cobertura se estimaría mediante la fórmula propuesta por  Morgensztem (1970). 

#### Características:

1. Estimación Iterativa de los Parámetros A y B:

- El código comienza con un valor arbitrario A₀ y calcula un valor inicial B₀ siguiendo el método MBBD
- Se realiza un ajuste de A basado en la diferencia entre la cobertura BBD y la cobertura de Morgenstern (RM)
- Se utiliza un factor de ajuste (adj_factor) para refinar el valor de A

2. Cálculo de la Cobertura BBD:

- El código emplea la función 'dbbinom' de la librería de distribuciones extraDistr
- Calcula la probabilidad de cero exposiciones (p_zero)
- La cobertura BBD se obtiene como (1 - p_zero)

3. Proceso Iterativo:

- La iteración continúa hasta que la cobertura calculada por BBD se aproxime lo suficiente a RM
- Esta convergencia es un aspecto fundamental en el ajuste del MBBD

4. Distribución de Contactos Final:

- Al finalizar la iteración, se calcula la distribución de contactos usando los valores finales de A y B (AF y BF)
- Esto permite modelar la distribución de contactos para distintas exposiciones según los requerimientos del modelo MBBD

5. Nota Importante sobre RM:

- El valor RM debe calcularse previamente usando la fórmula de  Morgensztern

***

#### Aplicación de la función:

```R
resultado <- calc_MBBD(
  m = 3,                          
  insertions = c(5, 7, 4),        
  audiences = c(500000, 550000, 600000),  
  RM = 550000,                    
  universe = 1000000,             
  A0 = 0.1                        
)
```

### Optimización de Distribución de Contactos (`optimizar_d`)

Optimiza la distribución de contactos publicitarios utilizando el modelo Beta-Binomial. Esta función optimiza la distribución de contactos publicitarios y calcula los coeficientes de duplicación (R1 y R2) utilizando la distribución Beta-Binomial. El proceso busca la mejor combinación de parámetros alpha y beta y número de inserciones que satisfaga los criterios de cobertura efectiva y frecuencia efectiva (FE) especificados por el usuario.

#### Características principales:
- Calcula parámetros óptimos alpha y beta
- Determina número óptimo de inserciones
- Genera distribución de contactos completa
- Permite ajustar tolerancia y criterios de convergencia

***

#### Aplicación de la función:

```R
resultado2 <- optimizar_d(
  Pob = 1000000,
  FE = 4,
  cob_efectiva = 600000,
  A1 = 450000,
  max_inserciones = 8,
  tolerancia = 0.03,     
  step_A = 0.01,         
  step_B = 0.01,
  min_soluciones = 20    
)

# Examinar resultados
print(head(resultado$mejores_combinaciones))
print(resultado$data)
```

### Optimización de Distribución de Contactos Acumulada (`optimizar_dc`)

Esta función optimiza la distribución de contactos publicitarios y calcula los coeficientes de duplicación (R1 y R2) utilizando la distribución Beta-Binomial. El proceso busca la mejor combinación de parámetros alpha y beta y número de inserciones que satisfaga los criterios de cobertura efectiva y frecuencia efectiva mínima (FEM) especificados por el usuario. La función calcula la cobertura acumulada para individuos que han visto el anuncio FEM o más veces.

#### Características principales:
- Calcula parámetros óptimos alpha y beta
- Determina número óptimo de inserciones
- Genera distribución de contactos completa
- Permite ajustar tolerancia y criterios de convergencia

***

#### Aplicación de la función:

```R
resultado <- optimizar_dc(
  Pob = 500000,
  FEM = 4,               
  cob_efectiva = 250000,
  A1 = 200000,
  max_inserciones = 10,
  tolerancia = 0.03,
  step_A = 0.05,
  step_B = 0.05,
  min_soluciones = 15
)
```

### Optimización de Plan de Medios (`optimize_media_plan`)

Optimiza planes de medios con restricciones mediante procesamiento por lotes.

#### Características:
- Permite elegir entre modelo Sainsbury o Binomial
- Maneja restricciones presupuestarias
- Permite exclusión de soportes específicos
- Trabaja con audiencias brutas o útiles

***

#### Aplicación de la función:

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
## Características Generales del Paquete

- Múltiples modelos de cobertura y frecuencia
- Optimización con restricciones presupuestarias
- Soporte para audiencias brutas y ponderadas
- Procesamiento por lotes para cálculos eficientes
- Salida detallada con distribuciones de contactos
- Validación y manejo de errores integrado
- Seguimiento de progreso para operaciones largas

### Manejo de Errores
El paquete incluye validación de entrada y manejo de errores:

- Validación de rangos de parámetros
- Verificaciones de consistencia
- Mensajes de error descriptivos
- Seguimiento de progreso

## Referencias

Aldás Manzano, J. (1998). Modelos de determinación de la cobertura y la distribución de contactos en la planificación de medios publicitarios impresos. Tesis doctoral, Universidad de Valencia, España.
Díez de Castro, E.C., Sánchez-Franco, M.J., y Martín Armario, E. (2011). Comunicaciones de marketing. Planificación y Control. Pirámide, España.
Kelley, L. D., Jugenheimer, D. W., y Sheehan, K. B. (2015). Advertising Media Planning: A Brand Management Approach (4ª ed.). Routledge.
Ostrow , J. W. (1982) Setting Frequency Levels. In Effective Frequency: The State of the Art. New York: Advertising Research Foundation, Key Issues Workshop.
Rossiter, J.R. y & Danaher, P.J. (1998). Advanced Media Planning. Kluwer Academic Publishers, MAS, USA.

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
