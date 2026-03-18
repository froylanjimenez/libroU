# Capítulo 2: Estadística Descriptiva

**Nivel:** Pregrado / Introducción universitaria
**Paquetes requeridos:** `tidyverse`, `ggplot2`, `moments`, `psych`, `readr`

---

## Tabla de contenidos

1. [¿Qué es la estadística descriptiva?](#1-qué-es-la-estadística-descriptiva)
2. [Distribución de frecuencias](#2-distribución-de-frecuencias)
3. [Medidas de tendencia central](#3-medidas-de-tendencia-central)
4. [Medidas de dispersión](#4-medidas-de-dispersión)
5. [Medidas de forma](#5-medidas-de-forma)
6. [Medidas de posición relativa](#6-medidas-de-posición-relativa)
7. [Visualización con ggplot2](#7-visualización-con-ggplot2)
8. [Análisis descriptivo completo](#8-análisis-descriptivo-completo)
9. [Ejercicios prácticos](#9-ejercicios-prácticos)

---

## ¿Qué es la estadística descriptiva?

La **estadística descriptiva** es la rama de la estadística que se ocupa de recolectar, organizar, resumir y presentar datos de manera informativa, sin ir más allá de los datos disponibles. Su objetivo es describir las características fundamentales de un conjunto de observaciones mediante tablas, gráficas y medidas numéricas.

Se distingue de la **estadística inferencial**, que utiliza los datos de una muestra para hacer generalizaciones o inferencias sobre una población más grande, siempre con un grado de incertidumbre asociado. La estadística descriptiva no infiere; simplemente describe.

### Población vs. muestra

En estadística, la **población** es el conjunto completo de elementos sobre los que se quiere obtener información. La **muestra** es un subconjunto representativo de esa población, seleccionado para su estudio. Esta distinción es fundamental porque los estadísticos que calculamos cambian de nombre y notación según el origen de los datos:

| Concepto | Población (parámetro) | Muestra (estadístico) |
|---|---|---|
| Media | $\mu$ (mu) | $\bar{x}$ (x barra) |
| Varianza | $\sigma^2$ (sigma cuadrado) | $s^2$ |
| Desviación estándar | $\sigma$ | $s$ |
| Tamaño | $N$ | $n$ |
| Proporción | $\pi$ o $p$ | $\hat{p}$ |

Por ejemplo, si estudiamos la altura sobre el nivel del mar de **todas** las especies registradas en la Sierra Nevada de Santa Marta, hablamos de un **parámetro** poblacional $\mu$. Si solo disponemos de una muestra de 200 registros (como en nuestro dataset `biodiversidad_sierra.csv`), calculamos el **estadístico** $\bar{x}$.

### Tipos de variables

Las variables estadísticas se clasifican en dos grandes categorías:

**Variables cualitativas (categóricas):** Representan atributos o categorías, no cantidades numéricas.

- **Nominal:** Las categorías no tienen orden natural. Ejemplos: especie biológica, municipio, tipo de carga portuaria. No tiene sentido decir que una categoría es "mayor" que otra.
- **Ordinal:** Las categorías tienen un orden natural pero las diferencias entre ellas no son necesariamente iguales. Ejemplos: nivel educativo (primaria < secundaria < universitaria), zona de vida (seca < húmeda < muy húmeda).

**Variables cuantitativas (numéricas):** Representan cantidades medibles.

- **Discreta:** Toma valores enteros contables. Ejemplos: número de contenedores en un puerto, número de individuos por especie.
- **Continua:** Puede tomar cualquier valor dentro de un intervalo. Ejemplos: temperatura en grados Celsius, precipitación en milímetros, eficiencia porcentual.

### Escalas de medición

La escala de medición determina qué operaciones matemáticas y qué pruebas estadísticas son válidas para una variable:

| Escala | Características | Ejemplo en nuestros datos |
|---|---|---|
| **Nominal** | Categorías sin orden; solo igualdad/diferencia | `especie`, `municipio`, `tipo_carga` |
| **Ordinal** | Orden entre categorías; diferencias no uniformes | `zona_vida`, `variedad` (si hay jerarquía) |
| **Intervalo** | Diferencias iguales; cero arbitrario | Temperatura en °C (0 °C no es ausencia de calor) |
| **Razón** | Diferencias iguales; cero absoluto | `altura_msnm`, `toneladas_ha`, `num_contenedores` |

La escala de razón es la más informativa: permite multiplicaciones, divisiones y porcentajes. Por ello, calcular que una finca produce el doble de toneladas que otra es válido para `toneladas_ha` (escala razón), pero no tendría sentido aplicar la misma operación a la temperatura en °C (escala intervalo).

---

## Distribución de frecuencias

Una **tabla de frecuencias** organiza los datos en categorías o clases, mostrando cuántas veces aparece cada valor o rango de valores. Es el primer paso para entender la distribución de una variable.

### Tipos de frecuencia

Para cada clase $i$:

- **Frecuencia absoluta** ($f_i$): número de observaciones que caen en la clase $i$.
- **Frecuencia relativa** ($h_i$): proporción de observaciones en la clase $i$. $$h_i = \frac{f_i}{n}$$
- **Frecuencia acumulada** ($F_i$): suma de frecuencias absolutas hasta la clase $i$. $$F_i = \sum_{j=1}^{i} f_j$$
- **Frecuencia relativa acumulada** ($H_i$): suma de frecuencias relativas hasta la clase $i$. $$H_i = \sum_{j=1}^{i} h_j$$

### Regla de Sturges y amplitud de clase

Para variables continuas, los datos deben agruparse en **clases** (intervalos). La **regla de Sturges** proporciona una guía para determinar el número óptimo de clases $k$:

$$k = 1 + 3.322 \cdot \log_{10}(n)$$

Una vez determinado $k$, la **amplitud de clase** $c$ se calcula como:

$$c = \frac{x_{max} - x_{min}}{k}$$

Para nuestro dataset de biodiversidad con $n = 200$ observaciones:

$$k = 1 + 3.322 \cdot \log_{10}(200) = 1 + 3.322 \times 2.301 \approx 8.65 \approx 9 \text{ clases}$$

### Tablas de frecuencia en R

```r
# ============================================================
# DISTRIBUCIÓN DE FRECUENCIAS
# Dataset: biodiversidad_sierra.csv y palma_cesar.csv
# ============================================================

# Cargar librerías necesarias
library(tidyverse)  # Incluye dplyr, ggplot2, readr, etc.
library(readr)      # Para leer archivos CSV de forma robusta

# --- Cargar los datasets del proyecto ---
biodiversidad <- read_csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/biodiversidad_sierra.csv")
palma         <- read_csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv")
logistica     <- read_csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/logistica_puerto_baq.csv")

# Verificar estructura básica de cada dataset
glimpse(biodiversidad)  # 200 obs: especie, altura_msnm, temperatura_C, humedad_relativa, zona_vida
glimpse(palma)          # 150 obs: municipio, variedad, toneladas_ha, fertilizante_kg, precipitacion_mm
glimpse(logistica)      # 100 obs: fecha, tipo_carga, num_contenedores, tiempo_carga_horas, eficiencia_porcentaje

# ============================================================
# 2A. Frecuencias para variable CUALITATIVA: zona_vida
# ============================================================

# Frecuencia absoluta con table()
# table() cuenta cuántas veces aparece cada categoría
freq_abs_zona <- table(biodiversidad$zona_vida)
print(freq_abs_zona)

# Frecuencia relativa con prop.table()
# prop.table() divide cada conteo entre el total
freq_rel_zona <- prop.table(freq_abs_zona)
print(round(freq_rel_zona, 4))  # Redondear a 4 decimales para legibilidad

# Combinar en una tabla completa usando data.frame
tabla_zona <- data.frame(
  zona_vida        = names(freq_abs_zona),   # Categorías
  frec_absoluta    = as.integer(freq_abs_zona),  # Conteos
  frec_relativa    = as.numeric(freq_rel_zona),  # Proporciones
  frec_acumulada   = cumsum(as.integer(freq_abs_zona)),  # Acumulado absoluto
  frec_rel_acum    = cumsum(as.numeric(freq_rel_zona))   # Acumulado relativo
)

# Agregar columna de porcentaje para facilitar lectura
tabla_zona$porcentaje <- round(tabla_zona$frec_relativa * 100, 2)

print(tabla_zona)

# ============================================================
# 2B. Frecuencias para variable CUANTITATIVA: altura_msnm
# Usamos la regla de Sturges para determinar el número de clases
# ============================================================

n <- nrow(biodiversidad)          # n = 200 observaciones
k <- round(1 + 3.322 * log10(n)) # Regla de Sturges: k ≈ 9

x_min <- min(biodiversidad$altura_msnm, na.rm = TRUE)   # Valor mínimo
x_max <- max(biodiversidad$altura_msnm, na.rm = TRUE)   # Valor máximo
amplitud <- (x_max - x_min) / k                         # Amplitud de clase c

cat("n =", n, "\n")
cat("k (clases) =", k, "\n")
cat("Rango: [", x_min, ",", x_max, "]\n")
cat("Amplitud c =", round(amplitud, 1), "msnm\n")

# Crear los intervalos de clase usando cut()
# breaks define los límites; right = FALSE hace intervalos [a, b)
biodiversidad$clase_altura <- cut(
  biodiversidad$altura_msnm,
  breaks = k,              # Número de clases según Sturges
  right  = FALSE,          # Intervalos cerrados a la izquierda: [a, b)
  include.lowest = TRUE    # Incluir el valor mínimo en la primera clase
)

# Frecuencia absoluta por clase
freq_altura <- table(biodiversidad$clase_altura)

# Construir tabla completa de frecuencias para altura
tabla_altura <- data.frame(
  clase           = names(freq_altura),
  frec_absoluta   = as.integer(freq_altura),
  frec_relativa   = as.numeric(prop.table(freq_altura)),
  frec_acumulada  = cumsum(as.integer(freq_altura)),
  frec_rel_acum   = cumsum(as.numeric(prop.table(freq_altura)))
)

tabla_altura$porcentaje <- round(tabla_altura$frec_relativa * 100, 2)
print(tabla_altura)

# ============================================================
# 2C. Frecuencias para toneladas_ha (palma de aceite)
# ============================================================

n_palma <- nrow(palma)
k_palma <- round(1 + 3.322 * log10(n_palma))  # k para n=150

palma$clase_ton <- cut(
  palma$toneladas_ha,
  breaks = k_palma,
  right  = FALSE,
  include.lowest = TRUE
)

tabla_ton <- palma %>%
  count(clase_ton) %>%                         # Frecuencia absoluta
  mutate(
    frec_rel    = n / sum(n),                  # Frecuencia relativa
    frec_acum   = cumsum(n),                   # Frecuencia acumulada
    pct_acum    = cumsum(frec_rel) * 100       # Porcentaje acumulado
  ) %>%
  rename(clase = clase_ton, frec_abs = n)

print(tabla_ton)
```

---

## Medidas de tendencia central

Las **medidas de tendencia central** son estadísticos que representan el "centro" o valor típico de una distribución. Son el resumen numérico más básico y fundamental en estadística descriptiva.

### Media aritmética

La **media aritmética** $\bar{x}$ (para muestras) o $\mu$ (para poblaciones) es la suma de todos los valores dividida entre el número de observaciones:

$$\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i = \frac{x_1 + x_2 + \cdots + x_n}{n}$$

La media es sensible a valores extremos (outliers). Si la distribución es asimétrica, la media se desplaza hacia la cola más larga, alejándose del centro "visual" de los datos.

### Mediana

La **mediana** $\tilde{x}$ o $Me$ es el valor que divide la distribución en dos mitades iguales cuando los datos están ordenados de menor a mayor.

- Si $n$ es **impar**: la mediana es el valor de la posición $\frac{n+1}{2}$.
- Si $n$ es **par**: la mediana es el promedio de los valores en las posiciones $\frac{n}{2}$ y $\frac{n}{2}+1$.

$$Me = \begin{cases} x_{(m+1)} & \text{si } n = 2m+1 \text{ (impar)} \\ \dfrac{x_{(m)} + x_{(m+1)}}{2} & \text{si } n = 2m \text{ (par)} \end{cases}$$

La mediana es **robusta** frente a valores atípicos; no le afectan los extremos de la distribución.

### Moda

La **moda** $Mo$ es el valor o categoría que aparece con mayor frecuencia en el conjunto de datos. Una distribución puede ser:

- **Unimodal:** un solo valor de máxima frecuencia.
- **Bimodal:** dos valores con la misma frecuencia máxima.
- **Multimodal:** más de dos valores con frecuencias máximas iguales.

Para variables continuas, la moda se identifica como la clase con mayor frecuencia en una tabla de distribución.

### Media ponderada

Cuando cada observación tiene un peso $w_i$ que refleja su importancia relativa, se usa la **media ponderada**:

$$\bar{x}_w = \frac{\sum_{i=1}^{n} w_i \cdot x_i}{\sum_{i=1}^{n} w_i}$$

Ejemplo aplicado: si queremos calcular la productividad media de palma de aceite en el Cesar, pero ponderando por el área sembrada en cada municipio, usaríamos la media ponderada en lugar de la media aritmética simple.

### Media geométrica

La **media geométrica** es apropiada cuando los datos son tasas de crecimiento, índices o proporciones, y cuando la distribución es multiplicativa:

$$G = \left(\prod_{i=1}^{n} x_i\right)^{1/n} = \exp\left(\frac{1}{n}\sum_{i=1}^{n} \ln(x_i)\right)$$

Se usa en finanzas (tasas de rendimiento compuesto), biología (tasas de crecimiento poblacional) y cuando los datos cubren varios órdenes de magnitud.

### Media armónica

La **media armónica** es adecuada cuando se promedian tasas, velocidades o eficiencias (cocientes):

$$H = \frac{n}{\sum_{i=1}^{n} \frac{1}{x_i}}$$

Por ejemplo, si un camión de carga del puerto de Barranquilla recorre la misma distancia a diferentes velocidades, la velocidad media real se calcula con la media armónica.

### ¿Cuándo usar cada media?

| Situación | Media recomendada |
|---|---|
| Datos simétricos sin outliers | Aritmética |
| Datos asimétricos o con outliers | Mediana |
| Datos con pesos o importancias distintas | Ponderada |
| Tasas de crecimiento, índices, ratios multiplicativos | Geométrica |
| Promedios de velocidades, eficiencias, tasas | Armónica |
| Variable nominal/ordinal | Moda |

### Código R: medidas de tendencia central

```r
# ============================================================
# MEDIDAS DE TENDENCIA CENTRAL
# ============================================================

# --- Dataset 1: Biodiversidad Sierra Nevada ---

# Media aritmética de altura sobre el nivel del mar
media_altura <- mean(biodiversidad$altura_msnm, na.rm = TRUE)
# na.rm = TRUE ignora valores faltantes (NA) en el cálculo

# Mediana de altura
mediana_altura <- median(biodiversidad$altura_msnm, na.rm = TRUE)

# Moda: R no tiene función base para moda; la calculamos manualmente
# Usamos table() y which.max() para encontrar el valor más frecuente
moda_zona <- names(which.max(table(biodiversidad$zona_vida)))

cat("=== Biodiversidad Sierra Nevada ===\n")
cat("Media altura (msnm)  :", round(media_altura, 2), "\n")
cat("Mediana altura (msnm):", mediana_altura, "\n")
cat("Zona de vida modal   :", moda_zona, "\n\n")

# --- Dataset 2: Palma de aceite Cesar ---

media_ton    <- mean(palma$toneladas_ha, na.rm = TRUE)   # Media simple
mediana_ton  <- median(palma$toneladas_ha, na.rm = TRUE) # Mediana

# Media ponderada: ponderar toneladas_ha por precipitacion_mm
# Hipótesis: mayor precipitación implica mayor área relativa
media_pond_ton <- sum(palma$toneladas_ha * palma$precipitacion_mm, na.rm = TRUE) /
                  sum(palma$precipitacion_mm, na.rm = TRUE)

# Media geométrica: útil si las toneladas representan índices de productividad
# Equivale a exp(mean(log(x))) para valores positivos
media_geom_ton <- exp(mean(log(palma$toneladas_ha[palma$toneladas_ha > 0]), na.rm = TRUE))

# Media armónica usando la fórmula n / sum(1/x)
n_palma      <- sum(!is.na(palma$toneladas_ha))  # Número de obs no faltantes
media_arm_ton <- n_palma / sum(1 / palma$toneladas_ha[palma$toneladas_ha > 0], na.rm = TRUE)

cat("=== Palma de Aceite - Cesar ===\n")
cat("Media aritmética (ton/ha) :", round(media_ton, 3), "\n")
cat("Mediana (ton/ha)          :", round(mediana_ton, 3), "\n")
cat("Media ponderada (ton/ha)  :", round(media_pond_ton, 3), "\n")
cat("Media geométrica (ton/ha) :", round(media_geom_ton, 3), "\n")
cat("Media armónica (ton/ha)   :", round(media_arm_ton, 3), "\n\n")

# --- Dataset 3: Logística Puerto Barranquilla ---

media_cont   <- mean(logistica$num_contenedores, na.rm = TRUE)
mediana_cont <- median(logistica$num_contenedores, na.rm = TRUE)
media_efic   <- mean(logistica$eficiencia_porcentaje, na.rm = TRUE)

# Moda para tipo de carga (variable nominal)
moda_carga <- names(which.max(table(logistica$tipo_carga)))

cat("=== Logística Puerto Barranquilla ===\n")
cat("Media contenedores    :", round(media_cont, 1), "\n")
cat("Mediana contenedores  :", mediana_cont, "\n")
cat("Media eficiencia (%)  :", round(media_efic, 2), "\n")
cat("Tipo de carga modal   :", moda_carga, "\n\n")

# --- Comparación de medias en una tabla resumen ---
resumen_tendencia <- data.frame(
  Dataset    = c("Biodiversidad", "Palma Cesar", "Puerto Baq"),
  Variable   = c("altura_msnm", "toneladas_ha", "num_contenedores"),
  Media      = c(round(media_altura, 2), round(media_ton, 3), round(media_cont, 1)),
  Mediana    = c(mediana_altura, round(mediana_ton, 3), mediana_cont)
)
print(resumen_tendencia)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.82\textwidth]{../output/figuras/fig_cap2_05_medidas_tendencia.png}
  \caption{Comparación de las cuatro medidas de tendencia central para la productividad palmera en el Cesar (ton/ha). La proximidad entre media, mediana y media recortada indica distribución aproximadamente simétrica con escasa influencia de valores atípicos.}
  \label{fig:cap2_tendencia_central}
\end{figure}

---

## Medidas de dispersión

Las **medidas de dispersión** cuantifican qué tan separados o concentrados están los datos alrededor de la tendencia central. Dos distribuciones pueden tener la misma media pero comportamientos completamente distintos en cuanto a variabilidad.

### Rango

El **rango** $R$ es la diferencia entre el valor máximo y el mínimo:

$$R = x_{max} - x_{min}$$

Es la medida de dispersión más simple, pero la más sensible a valores extremos.

### Varianza muestral

La **varianza muestral** $s^2$ mide la dispersión promedio de los datos respecto a su media. El denominador $n-1$ (en lugar de $n$) corrige el sesgo cuando se estima la varianza poblacional a partir de una muestra (corrección de Bessel):

$$s^2 = \frac{\sum_{i=1}^{n}(x_i - \bar{x})^2}{n - 1}$$

La varianza tiene las unidades elevadas al cuadrado de la variable original, lo que dificulta su interpretación directa.

### Desviación estándar

La **desviación estándar** $s$ es la raíz cuadrada de la varianza, y está en las mismas unidades que los datos originales:

$$s = \sqrt{s^2} = \sqrt{\frac{\sum_{i=1}^{n}(x_i - \bar{x})^2}{n - 1}}$$

### Coeficiente de variación

El **coeficiente de variación** $CV$ expresa la desviación estándar como porcentaje de la media, permitiendo comparar la variabilidad de variables con diferentes unidades o escalas:

$$CV = \frac{s}{\bar{x}} \times 100\%$$

- $CV < 15\%$: baja variabilidad (datos homogéneos).
- $CV$ entre $15\%$ y $30\%$: variabilidad moderada.
- $CV > 30\%$: alta variabilidad (datos heterogéneos).

### Rango intercuartílico

El **rango intercuartílico** $IQR$ mide la dispersión del 50% central de los datos y es robusto frente a outliers:

$$IQR = Q_3 - Q_1$$

donde $Q_1$ es el primer cuartil (percentil 25) y $Q_3$ es el tercer cuartil (percentil 75).

### Regla empírica (68-95-99.7)

Para distribuciones aproximadamente normales (campana de Gauss), se cumple la **regla empírica**:

- El $\approx 68\%$ de los datos cae dentro de $[\bar{x} - s,\ \bar{x} + s]$
- El $\approx 95\%$ de los datos cae dentro de $[\bar{x} - 2s,\ \bar{x} + 2s]$
- El $\approx 99.7\%$ de los datos cae dentro de $[\bar{x} - 3s,\ \bar{x} + 3s]$

Esta regla es útil para detectar valores atípicos: un dato a más de 3 desviaciones estándar de la media es muy inusual bajo una distribución normal.

### Código R: medidas de dispersión

```r
# ============================================================
# MEDIDAS DE DISPERSIÓN
# ============================================================

# --- Dataset 1: Biodiversidad Sierra Nevada ---
cat("=== DISPERSIÓN: Biodiversidad Sierra Nevada ===\n")

# Rango
rango_alt <- diff(range(biodiversidad$altura_msnm, na.rm = TRUE))
# range() devuelve c(min, max); diff() calcula max - min
cat("Rango altura (msnm)         :", rango_alt, "\n")

# Varianza muestral (denominador n-1 por defecto en R)
var_alt <- var(biodiversidad$altura_msnm, na.rm = TRUE)
cat("Varianza muestral (msnm²)   :", round(var_alt, 2), "\n")

# Desviación estándar muestral
sd_alt <- sd(biodiversidad$altura_msnm, na.rm = TRUE)
cat("Desv. estándar (msnm)       :", round(sd_alt, 2), "\n")

# Coeficiente de variación (en porcentaje)
cv_alt <- (sd_alt / mean(biodiversidad$altura_msnm, na.rm = TRUE)) * 100
cat("Coef. de variación (%)      :", round(cv_alt, 2), "%\n")

# Rango intercuartílico
iqr_alt <- IQR(biodiversidad$altura_msnm, na.rm = TRUE)
cat("Rango intercuartílico (msnm):", iqr_alt, "\n")

# Cuartiles completos
q_alt <- quantile(biodiversidad$altura_msnm, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)
cat("Q1 =", q_alt[1], "| Q2 (mediana) =", q_alt[2], "| Q3 =", q_alt[3], "\n\n")

# --- Dataset 2: Palma de aceite ---
cat("=== DISPERSIÓN: Palma de Aceite - Cesar ===\n")

rango_ton <- diff(range(palma$toneladas_ha, na.rm = TRUE))
sd_ton    <- sd(palma$toneladas_ha, na.rm = TRUE)
cv_ton    <- (sd_ton / mean(palma$toneladas_ha, na.rm = TRUE)) * 100
iqr_ton   <- IQR(palma$toneladas_ha, na.rm = TRUE)

cat("Rango (ton/ha)         :", round(rango_ton, 3), "\n")
cat("Desv. estándar (ton/ha):", round(sd_ton, 3), "\n")
cat("CV (%)                 :", round(cv_ton, 2), "%\n")
cat("IQR (ton/ha)           :", round(iqr_ton, 3), "\n\n")

# --- Dataset 3: Logística Puerto ---
cat("=== DISPERSIÓN: Logística Puerto Barranquilla ===\n")

sd_cont  <- sd(logistica$num_contenedores, na.rm = TRUE)
sd_efic  <- sd(logistica$eficiencia_porcentaje, na.rm = TRUE)
cv_cont  <- (sd_cont / mean(logistica$num_contenedores, na.rm = TRUE)) * 100
cv_efic  <- (sd_efic / mean(logistica$eficiencia_porcentaje, na.rm = TRUE)) * 100

cat("Contenedores - SD:", round(sd_cont, 2), "| CV:", round(cv_cont, 2), "%\n")
cat("Eficiencia   - SD:", round(sd_efic, 2), "| CV:", round(cv_efic, 2), "%\n\n")

# --- Aplicación de la regla empírica ---
cat("=== REGLA EMPÍRICA: altura_msnm ===\n")
media_h <- mean(biodiversidad$altura_msnm, na.rm = TRUE)
sd_h    <- sd(biodiversidad$altura_msnm, na.rm = TRUE)

# Contar cuántos datos caen dentro de cada banda
dentro_1sd <- sum(abs(biodiversidad$altura_msnm - media_h) <= 1 * sd_h, na.rm = TRUE)
dentro_2sd <- sum(abs(biodiversidad$altura_msnm - media_h) <= 2 * sd_h, na.rm = TRUE)
dentro_3sd <- sum(abs(biodiversidad$altura_msnm - media_h) <= 3 * sd_h, na.rm = TRUE)
n_total    <- sum(!is.na(biodiversidad$altura_msnm))

cat("Dentro de ±1s:", dentro_1sd, "/", n_total, "=", round(dentro_1sd/n_total*100, 1), "% (esperado: 68%)\n")
cat("Dentro de ±2s:", dentro_2sd, "/", n_total, "=", round(dentro_2sd/n_total*100, 1), "% (esperado: 95%)\n")
cat("Dentro de ±3s:", dentro_3sd, "/", n_total, "=", round(dentro_3sd/n_total*100, 1), "% (esperado: 99.7%)\n")
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.88\textwidth]{../output/figuras/fig_cap2_01_histograma_temp.png}
  \caption{Distribución de temperatura registrada en 200 parcelas de la Sierra Nevada de Santa Marta. La curva de densidad suavizada se superpone al histograma; las líneas verticales indican la media ($\bar{x}$) y la mediana. La distribución es ligeramente asimétrica hacia la derecha por la menor frecuencia de parcelas en alturas extremas.}
  \label{fig:cap2_histograma_temp}
\end{figure}

---

## Medidas de forma

Las **medidas de forma** describen la geometría de la distribución: su simetría y el grado de concentración en la cola versus el centro.

### Asimetría (Skewness)

El coeficiente de **asimetría de Pearson** $g_1$ mide la inclinación de la distribución:

$$g_1 = \frac{1}{n} \cdot \frac{\sum_{i=1}^{n}(x_i - \bar{x})^3}{s^3}$$

Interpretación:
- $g_1 = 0$: distribución simétrica (media = mediana = moda).
- $g_1 > 0$: asimetría positiva (cola a la derecha; media > mediana).
- $g_1 < 0$: asimetría negativa (cola a la izquierda; media < mediana).

Una regla práctica: si $|g_1| < 0.5$, la distribución es aproximadamente simétrica; si $|g_1| > 1$, la asimetría es considerable.

### Curtosis (Kurtosis)

La **curtosis** $g_2$ mide el grado de concentración de los datos en el centro de la distribución versus las colas, relativo a una distribución normal:

$$g_2 = \frac{1}{n} \cdot \frac{\sum_{i=1}^{n}(x_i - \bar{x})^4}{s^4} - 3$$

El término $-3$ hace que la distribución normal tenga curtosis cero (curtosis exceso). Interpretación:

| Tipo | $g_2$ | Características |
|---|---|---|
| **Leptocúrtica** | $g_2 > 0$ | Pico agudo, colas pesadas; mayor concentración central |
| **Mesocúrtica** | $g_2 = 0$ | Forma similar a la distribución normal |
| **Platicúrtica** | $g_2 < 0$ | Pico aplanado, colas ligeras; datos más dispersos |

### Código R: medidas de forma con `moments`

```r
# ============================================================
# MEDIDAS DE FORMA: ASIMETRÍA Y CURTOSIS
# Requiere: install.packages("moments")
# ============================================================

library(moments)  # Proporciona skewness() y kurtosis()

# --- Dataset 1: Biodiversidad ---
cat("=== FORMA: Biodiversidad Sierra Nevada ===\n")

asim_altura  <- skewness(biodiversidad$altura_msnm, na.rm = TRUE)
# skewness() calcula el tercer momento estandarizado (g1)

kurt_altura  <- kurtosis(biodiversidad$altura_msnm, na.rm = TRUE) - 3
# kurtosis() en el paquete moments devuelve la curtosis sin centrar;
# restamos 3 para obtener la curtosis exceso (relativa a la normal)

asim_temp    <- skewness(biodiversidad$temperatura_C, na.rm = TRUE)
kurt_temp    <- kurtosis(biodiversidad$temperatura_C, na.rm = TRUE) - 3

asim_hum     <- skewness(biodiversidad$humedad_relativa, na.rm = TRUE)
kurt_hum     <- kurtosis(biodiversidad$humedad_relativa, na.rm = TRUE) - 3

cat("Variable       | Asimetría | Curtosis (exceso)\n")
cat("altura_msnm    |", round(asim_altura, 4), "|", round(kurt_altura, 4), "\n")
cat("temperatura_C  |", round(asim_temp, 4),   "|", round(kurt_temp, 4),   "\n")
cat("humedad_rel    |", round(asim_hum, 4),     "|", round(kurt_hum, 4),   "\n\n")

# Interpretación automática de la asimetría
interpretar_asimetria <- function(g1) {
  if (abs(g1) < 0.5) return("Aproximadamente simétrica")
  else if (g1 > 0.5) return("Asimetría positiva (cola derecha)")
  else               return("Asimetría negativa (cola izquierda)")
}

# Interpretación automática de la curtosis
interpretar_curtosis <- function(g2) {
  if (abs(g2) < 0.5)  return("Mesocúrtica (similar a normal)")
  else if (g2 > 0.5)  return("Leptocúrtica (pico agudo, colas pesadas)")
  else                return("Platicúrtica (pico aplanado)")
}

cat("Interpretación altura_msnm:\n")
cat(" Asimetría:", interpretar_asimetria(asim_altura), "\n")
cat(" Curtosis :", interpretar_curtosis(kurt_altura), "\n\n")

# --- Dataset 2: Palma ---
asim_ton <- skewness(palma$toneladas_ha, na.rm = TRUE)
kurt_ton <- kurtosis(palma$toneladas_ha, na.rm = TRUE) - 3

cat("=== FORMA: Palma de Aceite ===\n")
cat("toneladas_ha - Asimetría:", round(asim_ton, 4),
    "| Curtosis:", round(kurt_ton, 4), "\n")
cat("Interpretación:", interpretar_asimetria(asim_ton), "\n\n")

# --- Dataset 3: Logística ---
asim_efic <- skewness(logistica$eficiencia_porcentaje, na.rm = TRUE)
kurt_efic <- kurtosis(logistica$eficiencia_porcentaje, na.rm = TRUE) - 3

cat("=== FORMA: Logística Puerto Barranquilla ===\n")
cat("eficiencia_porcentaje - Asimetría:", round(asim_efic, 4),
    "| Curtosis:", round(kurt_efic, 4), "\n")
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap2_04_distribuciones_comparadas.png}
  \caption{Distribuciones de densidad de las variables cuantitativas clave por grupo: temperatura y humedad por zona de vida (Sierra Nevada), productividad por variedad de palma (Cesar) y eficiencia operacional por tipo de carga (Puerto de Barranquilla). Las distribuciones con mayor solapamiento entre grupos indican menor poder discriminatorio de la variable de agrupación.}
  \label{fig:cap2_distribuciones}
\end{figure}

---

## Medidas de posición relativa

Las **medidas de posición relativa** ubican una observación dentro de la distribución, indicando qué porcentaje de los datos queda por debajo de ese valor.

### Percentiles y cuantiles

El **percentil** $P_k$ es el valor tal que el $k\%$ de los datos es menor o igual a ese valor. Casos especiales importantes:

- **Cuartiles:** $Q_1 = P_{25}$, $Q_2 = P_{50}$ (mediana), $Q_3 = P_{75}$
- **Deciles:** $D_1 = P_{10}$, $D_2 = P_{20}$, ..., $D_9 = P_{90}$
- **Quintiles:** $P_{20}$, $P_{40}$, $P_{60}$, $P_{80}$

### Box plot y regla de Tukey para outliers

El **diagrama de caja** (box plot) es la representación gráfica por excelencia de los cuartiles. La **regla de Tukey** define los límites para identificar valores atípicos:

$$\text{Límite inferior} = Q_1 - 1.5 \cdot IQR$$
$$\text{Límite superior} = Q_3 + 1.5 \cdot IQR$$

Cualquier observación fuera de este intervalo $[Q_1 - 1.5 \cdot IQR,\ Q_3 + 1.5 \cdot IQR]$ se considera un **outlier**. Para outliers extremos, se usa el factor 3 en lugar de 1.5.

### Puntuación Z (z-score)

La **puntuación Z** $z_i$ transforma cada observación a unidades de desviaciones estándar respecto a la media:

$$z_i = \frac{x_i - \bar{x}}{s}$$

- $z_i = 0$: la observación está justo en la media.
- $z_i = 1$: la observación está 1 desviación estándar por encima de la media.
- $|z_i| > 3$: la observación es un posible outlier (bajo distribución normal).

La estandarización Z es útil para comparar observaciones de distintas variables o escalas.

### Código R: posición relativa y outliers

```r
# ============================================================
# MEDIDAS DE POSICIÓN RELATIVA, PERCENTILES Y OUTLIERS
# ============================================================

# --- Percentiles de altura_msnm ---
cat("=== PERCENTILES: altura_msnm (Biodiversidad) ===\n")

# quantile() con probs permite especificar cualquier percentil
percentiles_alt <- quantile(
  biodiversidad$altura_msnm,
  probs = c(0.10, 0.25, 0.50, 0.75, 0.90, 0.95),
  na.rm = TRUE
)
print(round(percentiles_alt, 1))

# --- Regla de Tukey para detectar outliers en toneladas_ha ---
cat("\n=== OUTLIERS por regla de Tukey: toneladas_ha ===\n")

q1_ton  <- quantile(palma$toneladas_ha, 0.25, na.rm = TRUE)  # Primer cuartil
q3_ton  <- quantile(palma$toneladas_ha, 0.75, na.rm = TRUE)  # Tercer cuartil
iqr_ton <- q3_ton - q1_ton                                    # Rango intercuartílico

limite_inf_ton <- q1_ton - 1.5 * iqr_ton  # Límite inferior de Tukey
limite_sup_ton <- q3_ton + 1.5 * iqr_ton  # Límite superior de Tukey

cat("Q1 =", round(q1_ton, 3), "| Q3 =", round(q3_ton, 3), "| IQR =", round(iqr_ton, 3), "\n")
cat("Límite inferior Tukey:", round(limite_inf_ton, 3), "\n")
cat("Límite superior Tukey:", round(limite_sup_ton, 3), "\n")

# Identificar outliers
outliers_ton <- palma$toneladas_ha[
  palma$toneladas_ha < limite_inf_ton | palma$toneladas_ha > limite_sup_ton
]
cat("Número de outliers:", length(outliers_ton), "\n")
if (length(outliers_ton) > 0) print(sort(outliers_ton))

# --- Puntuación Z para eficiencia del puerto ---
cat("\n=== PUNTUACIÓN Z: eficiencia_porcentaje ===\n")

media_efic_z <- mean(logistica$eficiencia_porcentaje, na.rm = TRUE)
sd_efic_z    <- sd(logistica$eficiencia_porcentaje, na.rm = TRUE)

# Calcular z-score para cada observación
logistica$z_eficiencia <- (logistica$eficiencia_porcentaje - media_efic_z) / sd_efic_z

# Identificar observaciones con |z| > 2 (posibles outliers moderados)
outliers_z <- logistica[abs(logistica$z_eficiencia) > 2,
                        c("fecha", "tipo_carga", "eficiencia_porcentaje", "z_eficiencia")]

cat("Observaciones con |z| > 2:\n")
print(outliers_z)

# Identificar observaciones con |z| > 3 (outliers severos)
outliers_z3 <- logistica[abs(logistica$z_eficiencia) > 3,
                         c("fecha", "tipo_carga", "eficiencia_porcentaje", "z_eficiencia")]
cat("\nObservaciones con |z| > 3 (outliers severos):\n")
print(outliers_z3)

# Resumen de percentiles para todos los datasets en tabla comparativa
resumen_pos <- data.frame(
  Dataset  = c("Biodiversidad", "Palma", "Puerto"),
  Variable = c("altura_msnm", "toneladas_ha", "num_contenedores"),
  Q1       = c(
    quantile(biodiversidad$altura_msnm, 0.25, na.rm = TRUE),
    quantile(palma$toneladas_ha, 0.25, na.rm = TRUE),
    quantile(logistica$num_contenedores, 0.25, na.rm = TRUE)
  ),
  Mediana  = c(
    median(biodiversidad$altura_msnm, na.rm = TRUE),
    median(palma$toneladas_ha, na.rm = TRUE),
    median(logistica$num_contenedores, na.rm = TRUE)
  ),
  Q3       = c(
    quantile(biodiversidad$altura_msnm, 0.75, na.rm = TRUE),
    quantile(palma$toneladas_ha, 0.75, na.rm = TRUE),
    quantile(logistica$num_contenedores, 0.75, na.rm = TRUE)
  )
)
print(resumen_pos)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.88\textwidth]{../output/figuras/fig_cap2_02_boxplot_variedades.png}
  \caption{Diagrama de cajas y bigotes de la productividad (ton/ha de Racimos de Fruto Fresco) por variedad de palma de aceite en el Cesar. El rombo blanco indica la media. La línea horizontal punteada señala el promedio nacional de referencia (16~t/ha). El híbrido OxG muestra la mayor productividad y menor dispersión, mientras que la variedad Dura presenta el rendimiento más bajo.}
  \label{fig:cap2_boxplot_variedades}
\end{figure}

---

## Visualización con ggplot2

`ggplot2` es el paquete de visualización más poderoso de R, basado en la **gramática de los gráficos** (Grammar of Graphics). Cada gráfico se construye en capas: datos, estéticas (`aes`), geometrías (`geom_*`), escalas, facetas y temas.

La estructura básica es:

```r
ggplot(data = mis_datos, aes(x = variable_x, y = variable_y)) +
  geom_tipo() +
  labs(title = "...", x = "...", y = "...") +
  theme_tipo()
```

### Histogramas

```r
# ============================================================
# HISTOGRAMA: distribución de altura_msnm (Biodiversidad)
# ============================================================

library(ggplot2)

# Histograma básico con densidad superpuesta
p1 <- ggplot(biodiversidad, aes(x = altura_msnm)) +
  # geom_histogram crea las barras del histograma
  # bins define el número de barras; fill el color interior; color el borde
  geom_histogram(
    bins  = 9,              # 9 clases según Sturges para n=200
    fill  = "#2E86AB",      # Azul caribe (color de relleno)
    color = "white",        # Bordes blancos entre barras
    alpha = 0.85            # Transparencia leve
  ) +
  # Añadir línea de densidad escalada a frecuencia absoluta
  geom_density(
    aes(y = after_stat(count)),  # Escala la densidad a frecuencias
    color    = "#E84855",        # Rojo intenso para la curva
    linewidth = 1.2,             # Grosor de la línea
    adjust   = 1.5               # Suavizado de la curva
  ) +
  # Línea vertical en la media
  geom_vline(
    xintercept = mean(biodiversidad$altura_msnm, na.rm = TRUE),
    color = "#F4D35E", linewidth = 1, linetype = "dashed"
  ) +
  # Línea vertical en la mediana
  geom_vline(
    xintercept = median(biodiversidad$altura_msnm, na.rm = TRUE),
    color = "#1B998B", linewidth = 1, linetype = "dotdash"
  ) +
  # Etiquetas del gráfico
  labs(
    title    = "Distribución de Altitud — Sierra Nevada de Santa Marta",
    subtitle = "n = 200 registros de biodiversidad | Líneas: Media (amarillo), Mediana (verde)",
    x        = "Altura sobre el nivel del mar (msnm)",
    y        = "Frecuencia absoluta",
    caption  = "Fuente: Dataset biodiversidad_sierra.csv"
  ) +
  theme_minimal(base_size = 13) +   # Tema limpio con tamaño de fuente base
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5),  # Título centrado y negrita
    plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
    panel.grid.minor = element_blank()   # Quitar grilla menor
  )

print(p1)

# Guardar en la carpeta output/
ggsave(
  filename = "output/cap02_histograma_altura.png",
  plot     = p1,
  width    = 10, height = 6, dpi = 300
)
```

### Gráfico de densidad

```r
# ============================================================
# GRÁFICO DE DENSIDAD por zona_vida
# Permite comparar distribuciones de temperatura entre zonas
# ============================================================

p2 <- ggplot(biodiversidad, aes(x = temperatura_C, fill = zona_vida, color = zona_vida)) +
  # geom_density con alpha para ver las curvas superpuestas
  geom_density(alpha = 0.3, linewidth = 1) +
  scale_fill_brewer(palette  = "Set2", name = "Zona de vida") +
  scale_color_brewer(palette = "Set2", name = "Zona de vida") +
  labs(
    title    = "Distribución de Temperatura por Zona de Vida",
    subtitle = "Sierra Nevada de Santa Marta — Caribe Colombiano",
    x        = "Temperatura (°C)",
    y        = "Densidad de probabilidad",
    caption  = "Fuente: biodiversidad_sierra.csv"
  ) +
  theme_classic(base_size = 12) +
  theme(
    legend.position = "top",                          # Leyenda en la parte superior
    plot.title = element_text(face = "bold")
  )

print(p2)
ggsave("output/cap02_densidad_temperatura_zona.png", p2, width = 10, height = 6, dpi = 300)
```

### Box plots comparativos

```r
# ============================================================
# BOX PLOTS: toneladas_ha por variedad y municipio (Palma Cesar)
# ============================================================

p3 <- ggplot(palma, aes(x = variedad, y = toneladas_ha, fill = variedad)) +
  # geom_boxplot dibuja: caja (Q1-Q3), línea mediana, bigotes y outliers
  geom_boxplot(
    outlier.color = "red",      # Outliers en rojo
    outlier.shape = 21,         # Forma del punto outlier
    outlier.size  = 2,
    alpha = 0.7
  ) +
  # Superponer puntos individuales con jitter (dispersión aleatoria en x)
  geom_jitter(
    width = 0.15,       # Amplitud del desplazamiento horizontal
    alpha = 0.4,        # Transparencia de los puntos
    size  = 1.5
  ) +
  scale_fill_manual(
    values = c("#A8DADC", "#457B9D", "#1D3557", "#E63946", "#F1FAEE")
  ) +
  labs(
    title    = "Productividad de Palma de Aceite por Variedad — Cesar",
    subtitle = "Distribución de toneladas por hectárea | Puntos rojos: outliers Tukey",
    x        = "Variedad de palma",
    y        = "Producción (toneladas/ha)",
    caption  = "Fuente: palma_cesar.csv",
    fill     = "Variedad"
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position  = "none",     # Sin leyenda (el eje x ya identifica las variedades)
    axis.text.x      = element_text(angle = 30, hjust = 1),  # Etiquetas inclinadas
    plot.title       = element_text(face = "bold")
  )

print(p3)
ggsave("output/cap02_boxplot_palma_variedad.png", p3, width = 10, height = 6, dpi = 300)
```

### Gráfico de barras para variables categóricas

```r
# ============================================================
# GRÁFICO DE BARRAS: frecuencia de tipo_carga (Puerto Barranquilla)
# ============================================================

# Preparar tabla de frecuencias para graficar
freq_carga <- logistica %>%
  count(tipo_carga) %>%                          # Contar por categoría
  mutate(
    porcentaje = n / sum(n) * 100,               # Calcular porcentaje
    tipo_carga = reorder(tipo_carga, -n)         # Ordenar de mayor a menor
  )

p4 <- ggplot(freq_carga, aes(x = tipo_carga, y = n, fill = tipo_carga)) +
  geom_col(show.legend = FALSE, alpha = 0.85) +   # geom_col usa los valores de y directamente
  # Añadir etiquetas con el porcentaje sobre cada barra
  geom_text(
    aes(label = paste0(round(porcentaje, 1), "%")),
    vjust = -0.5,    # Posición ligeramente encima de la barra
    size  = 4,
    fontface = "bold"
  ) +
  scale_fill_brewer(palette = "Set3") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +  # Espacio para etiquetas
  labs(
    title    = "Distribución de Operaciones por Tipo de Carga",
    subtitle = "Puerto de Barranquilla — 100 operaciones registradas",
    x        = "Tipo de carga",
    y        = "Número de operaciones",
    caption  = "Fuente: logistica_puerto_baq.csv"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x  = element_text(angle = 20, hjust = 1),
    plot.title   = element_text(face = "bold", hjust = 0.5),
    panel.grid.major.x = element_blank()   # Quitar rejilla vertical
  )

print(p4)
ggsave("output/cap02_barras_tipo_carga.png", p4, width = 9, height = 6, dpi = 300)
```

### Diagrama de dispersión

```r
# ============================================================
# DIAGRAMA DE DISPERSIÓN: fertilizante_kg vs toneladas_ha
# Palma de aceite — ¿Más fertilizante implica más producción?
# ============================================================

p5 <- ggplot(palma, aes(x = fertilizante_kg, y = toneladas_ha, color = variedad)) +
  # Puntos de dispersión
  geom_point(alpha = 0.7, size = 2.5) +
  # Línea de tendencia lineal por variedad (con intervalo de confianza)
  geom_smooth(
    method  = "lm",     # Método: regresión lineal
    se      = TRUE,     # Mostrar banda del intervalo de confianza al 95%
    alpha   = 0.15,     # Transparencia de la banda
    linewidth = 1
  ) +
  scale_color_brewer(palette = "Dark2", name = "Variedad") +
  labs(
    title    = "Relación entre Fertilización y Productividad de Palma",
    subtitle = "Departamento del Cesar — Por variedad cultivada",
    x        = "Fertilizante aplicado (kg/ha)",
    y        = "Productividad (toneladas/ha)",
    caption  = "Fuente: palma_cesar.csv | Línea: regresión lineal + IC 95%"
  ) +
  theme_light(base_size = 12) +
  theme(
    legend.position = "right",
    plot.title      = element_text(face = "bold", hjust = 0.5)
  )

print(p5)
ggsave("output/cap02_dispersion_fertilizante_ton.png", p5, width = 10, height = 7, dpi = 300)

# ============================================================
# DIAGRAMA DE DISPERSIÓN CON FACETAS: eficiencia vs tiempo_carga
# Por tipo de carga en el puerto
# ============================================================

p6 <- ggplot(logistica, aes(x = tiempo_carga_horas, y = eficiencia_porcentaje)) +
  geom_point(aes(size = num_contenedores, color = eficiencia_porcentaje),
             alpha = 0.7) +
  # facet_wrap divide el gráfico en paneles por categoría
  facet_wrap(~ tipo_carga, scales = "free_x", ncol = 3) +
  scale_color_gradient(low = "#E63946", high = "#2DC653", name = "Eficiencia (%)") +
  scale_size_continuous(name = "Contenedores", range = c(1, 5)) +
  labs(
    title   = "Eficiencia vs Tiempo de Carga por Tipo de Mercancía",
    subtitle = "Puerto de Barranquilla | Tamaño del punto: número de contenedores",
    x       = "Tiempo de carga (horas)",
    y       = "Eficiencia (%)",
    caption = "Fuente: logistica_puerto_baq.csv"
  ) +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "#457B9D"),   # Fondo de etiqueta de faceta
    strip.text       = element_text(color = "white", face = "bold"),
    plot.title       = element_text(face = "bold", hjust = 0.5)
  )

print(p6)
ggsave("output/cap02_dispersion_eficiencia_facetas.png", p6, width = 12, height = 8, dpi = 300)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.90\textwidth]{../output/figuras/fig_cap2_03_dispersion_altitud_temp.png}
  \caption{Diagrama de dispersión del gradiente altitudinal de temperatura en la Sierra Nevada de Santa Marta (n = 200 parcelas). Cada punto representa una parcela, coloreada por zona de vida. La recta de regresión global (línea punteada) confirma la relación lineal negativa predicha por el gradiente adiabático estándar; el $R^2$ indica la proporción de variabilidad explicada por la altitud.}
  \label{fig:cap2_dispersion_altitud}
\end{figure}

---

## Análisis descriptivo completo

Un **análisis descriptivo completo** integra todas las medidas anteriores en un flujo estructurado: cargar datos, limpiar, describir numéricamente y visualizar.

### Función `summary()` y `describe()` de `psych`

```r
# ============================================================
# ANÁLISIS DESCRIPTIVO COMPLETO
# Paquetes: base R (summary), psych (describe), dplyr (tablas)
# ============================================================

library(psych)     # Para la función describe() enriquecida
library(dplyr)     # Para manipulación de datos

# --- summary() de base R ---
# Proporciona: min, Q1, mediana, media, Q3, max (y NA count si hay)
cat("=== summary() — Biodiversidad Sierra Nevada ===\n")
print(summary(biodiversidad))

cat("\n=== summary() — Palma de Aceite Cesar ===\n")
print(summary(palma))

cat("\n=== summary() — Logística Puerto Barranquilla ===\n")
print(summary(logistica))

# --- describe() del paquete psych ---
# Agrega: n, media, sd, mediana, mad (desv. mediana abs.), min, max,
#         rango, asimetría (skew), curtosis (kurtosis), error estándar
cat("\n=== describe() [psych] — Biodiversidad (variables numéricas) ===\n")
vars_num_bio <- biodiversidad %>%
  select(where(is.numeric))         # Seleccionar solo columnas numéricas
print(describe(vars_num_bio))

cat("\n=== describe() [psych] — Palma de Aceite ===\n")
vars_num_palma <- palma %>% select(where(is.numeric))
print(describe(vars_num_palma))

# --- Tablas cruzadas con table() ---
cat("\n=== Tabla cruzada: zona_vida × especie (top 5 especies) ===\n")
# Primero identificar las 5 especies más frecuentes
top5_especies <- names(sort(table(biodiversidad$especie), decreasing = TRUE))[1:5]

# Filtrar y crear tabla cruzada
bio_top5 <- biodiversidad[biodiversidad$especie %in% top5_especies, ]
tabla_cruzada <- table(bio_top5$zona_vida, bio_top5$especie)
print(tabla_cruzada)

# Proporciones por fila (dentro de cada zona de vida)
cat("\nProporciones por zona de vida (filas suman 1):\n")
print(round(prop.table(tabla_cruzada, margin = 1), 3))  # margin=1: por filas

# --- xtabs(): tablas cruzadas con fórmula ---
cat("\n=== xtabs: municipio × variedad (Palma) ===\n")
xtab_palma <- xtabs(~ municipio + variedad, data = palma)
print(xtab_palma)

# Agregar marginales (totales por fila y columna)
print(addmargins(xtab_palma))

# ============================================================
# FLUJO COMPLETO: cargar → limpiar → describir → visualizar
# Ejemplo integrador con los 3 datasets
# ============================================================

analisis_descriptivo_completo <- function(datos, nombre_dataset, var_cuantitativa) {
  # Función que ejecuta un análisis descriptivo básico automatizado

  cat(rep("=", 60), "\n", sep = "")
  cat("ANÁLISIS DESCRIPTIVO:", nombre_dataset, "\n")
  cat(rep("=", 60), "\n", sep = "")

  x <- datos[[var_cuantitativa]]   # Extraer la variable de interés

  # 1. Estadísticos de tendencia central
  cat("\n1. TENDENCIA CENTRAL\n")
  cat("   Media   :", round(mean(x, na.rm = TRUE), 4), "\n")
  cat("   Mediana :", round(median(x, na.rm = TRUE), 4), "\n")

  # 2. Estadísticos de dispersión
  cat("\n2. DISPERSIÓN\n")
  cat("   Rango   :", diff(range(x, na.rm = TRUE)), "\n")
  cat("   SD      :", round(sd(x, na.rm = TRUE), 4), "\n")
  cat("   CV (%)  :", round(sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE) * 100, 2), "%\n")
  cat("   IQR     :", IQR(x, na.rm = TRUE), "\n")

  # 3. Estadísticos de forma
  cat("\n3. FORMA\n")
  cat("   Asimetría:", round(skewness(x, na.rm = TRUE), 4), "\n")
  cat("   Curtosis :", round(kurtosis(x, na.rm = TRUE) - 3, 4), "\n")

  # 4. Percentiles clave
  cat("\n4. PERCENTILES\n")
  pcts <- quantile(x, probs = c(0.10, 0.25, 0.50, 0.75, 0.90), na.rm = TRUE)
  cat("   P10 =", pcts[1], "| Q1 =", pcts[2], "| Q2 =", pcts[3],
      "| Q3 =", pcts[4], "| P90 =", pcts[5], "\n")

  cat(rep("-", 60), "\n", sep = "")
}

# Ejecutar para los 3 datasets
analisis_descriptivo_completo(biodiversidad, "Biodiversidad Sierra Nevada", "altura_msnm")
analisis_descriptivo_completo(palma,         "Palma de Aceite Cesar",       "toneladas_ha")
analisis_descriptivo_completo(logistica,     "Logística Puerto Barranquilla","eficiencia_porcentaje")
```

### Reporte descriptivo con `dplyr`

```r
# ============================================================
# REPORTE DESCRIPTIVO AGRUPADO CON dplyr
# Estadísticas de toneladas_ha por municipio (Palma Cesar)
# ============================================================

reporte_municipio <- palma %>%
  group_by(municipio) %>%               # Agrupar por municipio
  summarise(
    n          = n(),                   # Número de registros
    media      = round(mean(toneladas_ha, na.rm = TRUE), 3),
    mediana    = round(median(toneladas_ha, na.rm = TRUE), 3),
    sd         = round(sd(toneladas_ha, na.rm = TRUE), 3),
    cv_pct     = round(sd(toneladas_ha, na.rm = TRUE) /
                       mean(toneladas_ha, na.rm = TRUE) * 100, 1),
    q1         = round(quantile(toneladas_ha, 0.25, na.rm = TRUE), 3),
    q3         = round(quantile(toneladas_ha, 0.75, na.rm = TRUE), 3),
    .groups    = "drop"                 # Desagrupar el resultado
  ) %>%
  arrange(desc(media))                  # Ordenar por productividad media descendente

cat("=== Estadísticas de productividad por municipio (Cesar) ===\n")
print(reporte_municipio)

# Reporte similar para eficiencia por tipo_carga (Puerto)
reporte_carga <- logistica %>%
  group_by(tipo_carga) %>%
  summarise(
    n           = n(),
    efic_media  = round(mean(eficiencia_porcentaje, na.rm = TRUE), 2),
    efic_sd     = round(sd(eficiencia_porcentaje, na.rm = TRUE), 2),
    tiempo_med  = round(mean(tiempo_carga_horas, na.rm = TRUE), 2),
    cont_total  = sum(num_contenedores, na.rm = TRUE),
    .groups     = "drop"
  ) %>%
  arrange(desc(efic_media))

cat("\n=== Estadísticas por tipo de carga — Puerto Barranquilla ===\n")
print(reporte_carga)
```

---

## Ejercicios prácticos

Los siguientes ejercicios están diseñados para consolidar los conceptos del capítulo en el contexto económico, ambiental y logístico del Caribe Colombiano. Se recomienda resolverlos en RStudio después de haber cargado los tres datasets del proyecto.

---

### Ejercicio 1: Biodiversidad vertical en la Sierra Nevada

La Sierra Nevada de Santa Marta alberga ecosistemas que van desde el nivel del mar hasta los 5.775 msnm del Pico Simón Bolívar, siendo el sistema montañoso litoral más alto del mundo. Utiliza el dataset `biodiversidad_sierra.csv` para responder:

**a)** Construye manualmente una tabla de distribución de frecuencias para la variable `humedad_relativa` aplicando la regla de Sturges. Calcula el número de clases $k$ y la amplitud $c$:

$$k = 1 + 3.322 \cdot \log_{10}(200) \approx 9 \text{ clases}$$

Verifica tus cálculos implementándolo en R con `cut()` y `table()`.

**b)** Calcula para `temperatura_C`:
- $\bar{x}$, $Me$, $Mo$
- $s^2$, $s$, $CV$
- Coeficiente de asimetría $g_1$ e interpreta si la distribución de temperatura es simétrica o sesgada
- ¿Se cumple la regla empírica 68-95-99.7 para esta variable?

**c)** Crea un histograma de `temperatura_C` coloreado por `zona_vida` con `ggplot2`. Guárdalo en `output/ej1_temperatura_zonav.png`.

**Pista:** Usa `geom_histogram()` con `facet_wrap(~ zona_vida)` para ver la distribución en cada zona de vida.

---

### Ejercicio 2: Productividad de palma en el Cesar

El Cesar es el segundo productor de palma de aceite de Colombia, con municipios como Agustín Codazzi y La Paz entre los más productivos. Usa `palma_cesar.csv`:

**a)** Calcula la media aritmética, media ponderada (ponderada por `precipitacion_mm`) y media geométrica de `toneladas_ha`. Compara los tres resultados y explica las diferencias:

$$\bar{x} = \frac{1}{n}\sum x_i \qquad \bar{x}_w = \frac{\sum w_i x_i}{\sum w_i} \qquad G = \left(\prod x_i\right)^{1/n}$$

**b)** Para cada municipio, calcula la media, desviación estándar y coeficiente de variación de `toneladas_ha`. ¿Qué municipio presenta mayor homogeneidad productiva (menor CV)?

**c)** Aplica la regla de Tukey para identificar fincas con rendimiento atípicamente alto o bajo:

$$\text{outlier si} \quad x_i < Q_1 - 1.5 \cdot IQR \quad \text{o} \quad x_i > Q_3 + 1.5 \cdot IQR$$

¿Cuántos registros son considerados outliers? ¿Qué municipios concentran los outliers superiores?

**d)** Crea un box plot de `toneladas_ha` por `municipio` ordenado de menor a mayor mediana. Usa un color diferente para cada municipio y agrega el número de observaciones con `stat_summary()` o `geom_text()`.

---

### Ejercicio 3: Eficiencia operativa en el Puerto de Barranquilla

El Puerto de Barranquilla es el principal hub logístico fluvial de Colombia y uno de los más importantes del Caribe. Analiza `logistica_puerto_baq.csv`:

**a)** Construye una tabla cruzada de `tipo_carga` × si la operación fue eficiente (`eficiencia_porcentaje >= 85`). Para crear la variable dicotómica usa:

```r
logistica$alta_eficiencia <- ifelse(logistica$eficiencia_porcentaje >= 85, "Alta", "Baja")
```

Calcula las proporciones por filas y columnas (`prop.table(tabla, margin = 1)` y `margin = 2`).

**b)** Calcula la puntuación Z para `tiempo_carga_horas`. Identifica las operaciones con $|z| > 2$ y determina qué tipo de carga concentra más operaciones con tiempo excesivo.

**c)** La relación entre número de contenedores y tiempo de carga debería ser positiva. Verifica esto calculando:
- Correlación de Pearson: $r = \frac{\sum(x_i - \bar{x})(y_i - \bar{y})}{(n-1) \cdot s_x \cdot s_y}$

En R: `cor(logistica$num_contenedores, logistica$tiempo_carga_horas)`.

Crea un diagrama de dispersión con línea de tendencia, coloreado por `tipo_carga`.

---

### Ejercicio 4: Análisis comparativo multivariable

Este ejercicio integra los tres datasets para practicar comparaciones entre distribuciones de distintas escalas.

**a)** Estandariza (z-score) las variables `altura_msnm`, `toneladas_ha` y `eficiencia_porcentaje`. Para cada una, verifica que la media sea $\approx 0$ y la desviación estándar sea $\approx 1$ después de la transformación:

$$z_i = \frac{x_i - \bar{x}}{s}$$

```r
# Estandarización usando scale()
biodiversidad$z_altura <- scale(biodiversidad$altura_msnm)
palma$z_toneladas      <- scale(palma$toneladas_ha)
logistica$z_eficiencia <- scale(logistica$eficiencia_porcentaje)
```

**b)** Para cada dataset, calcula la curtosis y la asimetría. Clasifica cada distribución como:
- Simétrica / asimétrica positiva / asimétrica negativa
- Leptocúrtica / mesocúrtica / platicúrtica

**c)** Crea un gráfico Q-Q (quantile-quantile) para las tres variables estandarizadas. ¿Cuál de ellas se aproxima más a una distribución normal?

```r
# Q-Q plot en R base
qqnorm(biodiversidad$z_altura, main = "Q-Q Plot: altura_msnm")
qqline(biodiversidad$z_altura, col = "red", lwd = 2)
```

---

### Ejercicio 5: Reporte descriptivo profesional

En el contexto de un estudio de competitividad agropecuaria y logística del Caribe Colombiano, elabora un reporte descriptivo completo que integre los hallazgos de los tres datasets.

**a)** Usando `dplyr`, crea una tabla resumen con las siguientes estadísticas para cada dataset:

| Dataset | Variable | $n$ | $\bar{x}$ | $Me$ | $s$ | $CV\%$ | $g_1$ | $g_2$ |
|---|---|---|---|---|---|---|---|---|
| Biodiversidad | `altura_msnm` | ... | ... | ... | ... | ... | ... | ... |
| Palma Cesar | `toneladas_ha` | ... | ... | ... | ... | ... | ... | ... |
| Puerto Baq | `eficiencia_pct` | ... | ... | ... | ... | ... | ... | ... |

**b)** Crea un panel de 6 gráficos (2 filas × 3 columnas) usando `gridExtra::grid.arrange()` o `patchwork`:
- Fila 1: histogramas de las tres variables principales
- Fila 2: box plots de las mismas variables agrupados por su variable categórica principal

```r
library(patchwork)  # Combinar gráficos ggplot2
# (p1 | p2 | p3) / (p4 | p5 | p6)   — sintaxis de patchwork
```

**c)** Redacta un párrafo (100-150 palabras) interpretando los resultados desde la perspectiva del desarrollo regional del Caribe Colombiano. Considera: ¿Son homogéneas las zonas de biodiversidad? ¿Existe alta variabilidad en la productividad de palma? ¿Es consistente la eficiencia del puerto? Apoya cada afirmación con un estadístico concreto ($CV$, $g_1$, $IQR$, etc.).

---

## Resumen del capítulo

En este capítulo desarrollamos el núcleo de la estadística descriptiva aplicada al contexto del Caribe Colombiano:

- **Conceptos fundamentales:** distinción entre estadística descriptiva e inferencial, población vs. muestra ($\mu$ vs. $\bar{x}$, $\sigma$ vs. $s$), tipos de variables y escalas de medición.
- **Distribución de frecuencias:** construcción de tablas con `table()`, `prop.table()` y `cut()`; regla de Sturges ($k = 1 + 3.322 \cdot \log_{10}(n)$) para determinar el número de clases.
- **Tendencia central:** media aritmética, mediana, moda, media ponderada, geométrica y armónica; criterios para elegir la medida más apropiada.
- **Dispersión:** rango, varianza ($s^2$), desviación estándar ($s$), coeficiente de variación ($CV$), rango intercuartílico ($IQR$) y regla empírica 68-95-99.7.
- **Forma:** asimetría de Pearson ($g_1$) y curtosis ($g_2$) con el paquete `moments`; clasificación en distribuciones simétricas, asimétricas, leptocúrticas y platicúrticas.
- **Posición relativa:** percentiles, cuartiles, regla de Tukey para outliers $[Q_1 - 1.5 \cdot IQR,\ Q_3 + 1.5 \cdot IQR]$ y puntuación Z.
- **Visualización:** histogramas, curvas de densidad, box plots, gráficos de barras y diagramas de dispersión con `ggplot2`; guardado en `output/` con `ggsave()`.
- **Análisis completo:** `summary()`, `describe()` (psych), tablas cruzadas con `table()` y `xtabs()`, y reportes agrupados con `dplyr`.

### Funciones R clave del capítulo

| Función | Paquete | Descripción |
|---|---|---|
| `table()` | base | Tabla de frecuencias absolutas |
| `prop.table()` | base | Frecuencias relativas desde `table()` |
| `cut()` | base | Agrupar variable continua en clases |
| `mean()`, `median()` | base | Media y mediana |
| `var()`, `sd()` | base | Varianza y desviación estándar |
| `IQR()`, `quantile()` | base | Rango intercuartílico y percentiles |
| `range()`, `diff()` | base | Rango (max-min) |
| `skewness()` | moments | Coeficiente de asimetría |
| `kurtosis()` | moments | Curtosis |
| `describe()` | psych | Estadísticos descriptivos completos |
| `xtabs()` | base | Tablas cruzadas con fórmula |
| `geom_histogram()` | ggplot2 | Histograma |
| `geom_density()` | ggplot2 | Curva de densidad |
| `geom_boxplot()` | ggplot2 | Diagrama de caja |
| `geom_col()` | ggplot2 | Gráfico de barras |
| `geom_point()` | ggplot2 | Diagrama de dispersión |
| `ggsave()` | ggplot2 | Guardar gráfico en archivo |
| `group_by()` + `summarise()` | dplyr | Estadísticas agrupadas |

---

