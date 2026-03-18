# Capítulo 1: Introducción a R para el Análisis Estadístico

> *"El objetivo del análisis estadístico no es la certeza, sino la reducción inteligente de la incertidumbre."*
> — John W. Tukey

---

## Tabla de Contenidos

1. [¿Por qué R?](#1-por-qué-r)
2. [Instalación del entorno](#2-instalación-del-entorno)
3. [Primeros pasos en R](#3-primeros-pasos-en-r)
4. [Tipos de objetos en R](#4-tipos-de-objetos-en-r)
5. [Lógica de programación](#5-lógica-de-programación)
6. [Funciones en R](#6-funciones-en-r)
7. [Aplicación práctica integrada](#7-aplicación-práctica-integrada)
8. [Ejercicios prácticos](#8-ejercicios-prácticos)

---

## ¿Por qué R?

### Contexto histórico

R nació en 1993 cuando **Ross Ihaka** y **Robert Gentleman** de la Universidad de Auckland (Nueva Zelanda) desarrollaron un lenguaje estadístico de código abierto basado en S, creado en los Laboratorios Bell en los años 70. En 1995 se liberó públicamente bajo licencia GNU GPL, y en 1997 se formó el **R Core Team**, que mantiene el lenguaje hasta hoy.

Hoy R es el *lingua franca* de la estadística: más de **20.000 paquetes** en CRAN (*Comprehensive R Archive Network*), adoptado por universidades, bancos centrales, organismos internacionales (OMS, FAO, DANE) y empresas de tecnología.

### R frente a otras herramientas

| Criterio | R | Python | Excel | SPSS/SAS |
|---|---|---|---|---|
| Costo | Gratuito | Gratuito | Pago | Pago |
| Visualización estadística | Excelente | Buena | Limitada | Buena |
| Reproducibilidad | Alta | Alta | Baja | Media |
| Comunidad estadística | Muy grande | Grande | N/A | Pequeña |
| Curva de aprendizaje | Media | Media | Baja | Media |
| Integración LaTeX/PDF | Nativa | Mediante Jupyter | No | No |

R no es simplemente un lenguaje de programación: es un **ecosistema estadístico**. Cada función, cada paquete, fue diseñado pensando en el análisis de datos. Donde otros lenguajes añaden estadística, R *es* estadística.

### El ecosistema Tidyverse

El **Tidyverse** (Wickham et al., 2019) es una colección de paquetes que comparten una filosofía común de datos ordenados (*tidy data*):

> *"Cada variable es una columna, cada observación es una fila, cada unidad observacional es una tabla."*

```r
# Los pilares del Tidyverse
library(tidyverse)   # Carga: ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats
```

---

## Instalación del entorno

### Instalar R base

**Windows / macOS:**
Descargar el instalador desde [https://cran.r-project.org](https://cran.r-project.org) y ejecutarlo con opciones por defecto.

**Ubuntu / Debian Linux:**
```bash
# Agregar repositorio oficial CRAN
sudo apt update
sudo apt install -y r-base r-base-dev

# Verificar instalación
R --version
```

**Fedora / RHEL / Rocky Linux:**
```bash
sudo dnf install R
```

### Instalar RStudio

RStudio es el IDE (*Integrated Development Environment*) estándar para R. Descargar desde [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/).

RStudio organiza el trabajo en cuatro paneles: **Editor de scripts** (código fuente), **Consola** (ejecución interactiva), **Environment/History** (objetos en memoria) y **Files/Plots/Packages/Help**. Los atajos más usados son `Ctrl+Enter` para ejecutar la línea actual y `Tab` para autocompletar.

---

## Primeros pasos en R

### R como calculadora

R evalúa expresiones matemáticas directamente en la consola:

```r
# Operaciones aritméticas básicas
2 + 3
#> [1] 5
10 - 4
#> [1] 6
3 * 7
#> [1] 21
15 / 4
#> [1] 3.75
2^10           # potencia
#> [1] 1024
17 %% 5        # módulo: resto de la división
#> [1] 2
17 %/% 5       # división entera
#> [1] 3

# Funciones matemáticas
sqrt(144)
#> [1] 12
abs(-7.3)
#> [1] 7.3
log(exp(1))    # logaritmo natural
#> [1] 1
log10(1000)    # logaritmo base 10
#> [1] 3
log(8, base=2) # logaritmo base 2
#> [1] 3
round(3.14159, digits = 2)
#> [1] 3.14
```

### El operador de asignación

En R se usa `<-` para asignar valores (convención de estilo tidyverse). El signo `=` también funciona, pero se reserva para argumentos de funciones:

```r
# Asignación con <- (recomendado)
temperatura <- 28.5
ciudad <- "Barranquilla"
es_tropical <- TRUE

# El objeto existe ahora en el Environment
print(temperatura)
#> [1] 28.5
cat("Ciudad:", ciudad, "\n")
#> Ciudad: Barranquilla

# Atajo de teclado en RStudio: Alt + - (guión)
```

### Tipos de datos atómicos

```r
# Numérico (double)
altura <- 1.75

# Entero
edad <- 25L              # La L indica entero explícito

# Carácter (texto)
especie <- "Espeletia schultzii"

# Lógico (booleano)
es_endemica <- TRUE
es_invasora  <- FALSE

# Verificar tipos
class(altura)
#> [1] "numeric"
class(edad)
#> [1] "integer"
class(especie)
#> [1] "character"
class(es_endemica)
#> [1] "logical"

# Convertir tipos
as.numeric("3.14")
#> [1] 3.14
as.integer(3.9)    # trunca, no redondea
#> [1] 3
as.character(2024)
#> [1] "2024"
as.logical(0)
#> [1] FALSE
as.logical(1)
#> [1] TRUE
```

---

## Tipos de objetos en R

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.82\textwidth]{../output/figuras/fig_cap1_01_tipos_objetos.png}
  \caption{Estructuras de datos fundamentales en R ordenadas por complejidad estructural. Los vectores son la unidad atómica del lenguaje; los data frames y las listas representan las estructuras más usadas en análisis estadístico aplicado.}
  \label{fig:cap1_tipos_objetos}
\end{figure}

### Vectores

El vector es la estructura fundamental de R. **Todo en R es un vector**; un escalar es simplemente un vector de longitud 1.

```r
# Crear vectores con c() (combine)
alturas_msnm <- c(120, 850, 1500, 2300, 3100, 4200)
zonas <- c("Seco", "Humedo", "Humedo", "Montano", "Nublado", "Paramo")
es_bosque <- c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE)

# Secuencias
seq_alt <- seq(from = 0, to = 5000, by = 500)   # 0, 500, 1000, ..., 5000
indices  <- 1:10                                  # 1, 2, 3, ..., 10

# Repetición
rep(c("A", "B"), times = 3)
#> [1] "A" "B" "A" "B" "A" "B"
rep(c("A", "B"), each = 3)
#> [1] "A" "A" "A" "B" "B" "B"

# Longitud y propiedades
length(alturas_msnm)
#> [1] 6
sum(alturas_msnm)
#> [1] 12070
mean(alturas_msnm)
#> [1] 2011.667
max(alturas_msnm)
#> [1] 4200
min(alturas_msnm)
#> [1] 120

# Indexación (base 1 en R, no base 0 como Python)
alturas_msnm[1]
#> [1] 120
alturas_msnm[c(2, 4)]
#> [1]  850 2300
alturas_msnm[-1]         # todos excepto el primero
#> [1]  850 1500 2300 3100 4200
alturas_msnm[alturas_msnm > 2000]   # filtro lógico
#> [1] 2300 3100 4200
```

#### Operaciones vectorizadas

Una de las características más poderosas de R es que las operaciones se aplican elemento a elemento sin necesidad de bucles:

```r
# Temperatura por gradiente altitudinal: T = 28.5 - (h/1000) * 6.5
alturas_msnm <- c(0, 500, 1000, 2000, 3000, 4000, 5000)
temperatura   <- 28.5 - (alturas_msnm / 1000) * 6.5

print(round(temperatura, 1))
#> [1] 28.5 25.2 22.0 15.5  9.0  2.5 -4.0
```

Esto corresponde a la fórmula del gradiente adiabático:

$$T(h) = T_0 - \Gamma \cdot \frac{h}{1000}$$

donde $T_0 = 28.5\,°C$ es la temperatura en la costa, $\Gamma = 6.5\,°C/\text{km}$ es el gradiente adiabático estándar y $h$ es la altura en metros.

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap1_02_vectorizacion.png}
  \caption{Izquierda: gradiente térmico altitudinal calculado con una operación vectorial sobre 51 altitudes simultáneamente; los puntos azules corresponden a las 200 parcelas de \texttt{biodiversidad\_sierra.csv}. Derecha: distribución de las observaciones por zona de vida, evidenciando mayor cobertura en las zonas húmedas medias.}
  \label{fig:cap1_vectorizacion}
\end{figure}

### Matrices

Una matriz es un vector bidimensional donde **todos los elementos son del mismo tipo**:

```r
# Crear matriz (se llena por filas con byrow = TRUE)
datos_parcela <- matrix(
  data = c(120, 25.1, 78,
           850, 21.3, 83,
           1500, 18.0, 89,
           2300, 13.5, 94),
  nrow = 4,
  ncol = 3,
  byrow = TRUE
)

colnames(datos_parcela) <- c("altura_msnm", "temperatura_C", "humedad_pct")
rownames(datos_parcela) <- paste0("Parcela_", 1:4)

print(datos_parcela)
#>          altura_msnm temperatura_C humedad_pct
#> Parcela_1         120          25.1          78
#> Parcela_2         850          21.3          83
#> Parcela_3        1500          18.0          89
#> Parcela_4        2300          13.5          94

# Indexación: matriz[fila, columna]
datos_parcela[2, 3]
#> [1] 83
datos_parcela["Parcela_3", "temperatura_C"]
#> [1] 18

# Álgebra matricial
A <- matrix(c(2, 1, 1, 3), nrow = 2)
det(A)
#> [1] 5
solve(A)      # Inversa de A
#>      [,1]  [,2]
#> [1,]  0.6  -0.2
#> [2,] -0.2   0.4
```

La inversa de una matriz $A$ se define como la matriz $A^{-1}$ tal que:

$$A \cdot A^{-1} = A^{-1} \cdot A = I$$

donde $I$ es la matriz identidad. En estadística, esto es central para la estimación por mínimos cuadrados: $\hat{\boldsymbol{\beta}} = (X^TX)^{-1}X^T\mathbf{y}$.

### Data Frames

El data frame es el objeto más utilizado en análisis estadístico: una tabla donde **cada columna puede ser de tipo diferente** (numérico, texto, factor, fecha).

```r
# Crear un data frame manualmente
parcelas <- data.frame(
  id              = 1:5,
  zona_vida       = c("Seco", "Humedo", "Montano", "Nublado", "Paramo"),
  altura_msnm     = c(400, 1200, 2200, 3200, 4100),
  temperatura_C   = c(26.9, 20.7, 14.2, 8.0, 2.0),
  humedad_relativa = c(68, 82, 91, 96, 81),
  stringsAsFactors = FALSE
)

# Propiedades del data frame
nrow(parcelas)
#> [1] 5
ncol(parcelas)
#> [1] 5
dim(parcelas)
#> [1] 5 5
str(parcelas)
#> 'data.frame':	5 obs. of  5 variables:
#>  $ id              : int  1 2 3 4 5
#>  $ zona_vida       : chr  "Seco" "Humedo" "Montano" "Nublado" ...
#>  $ altura_msnm     : num  400 1200 2200 3200 4100
#>  $ temperatura_C   : num  26.9 20.7 14.2 8 2
#>  $ humedad_relativa: num  68 82 91 96 81

# Acceder a columnas: tres formas equivalentes
parcelas$temperatura_C
parcelas[["temperatura_C"]]
parcelas[, "temperatura_C"]

# Filtrar filas
parcelas[parcelas$altura_msnm > 2000, ]
subset(parcelas, humedad_relativa > 85)

# Agregar columna calculada
parcelas$temp_fahrenheit <- parcelas$temperatura_C * 9/5 + 32

# Con dplyr (estilo tidyverse)
library(dplyr)
parcelas |>
  filter(altura_msnm > 1000) |>
  select(zona_vida, temperatura_C, humedad_relativa) |>
  arrange(desc(altura_msnm))
```

#### Cargar datos reales del proyecto

```r
# Cargar los datasets del proyecto
biodiversidad <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/biodiversidad_sierra.csv", encoding = "UTF-8")
palma         <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv",          encoding = "UTF-8")
logistica     <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/logistica_puerto_baq.csv", encoding = "UTF-8")

# Inspección rápida
head(biodiversidad, 3)
tail(palma, 3)
glimpse(logistica)
```

### Factores

Los factores representan **variables categóricas** con niveles definidos. Son esenciales para análisis estadísticos (ANOVA, regresión) y para que los gráficos respeten un orden lógico:

```r
# Factor nominal (sin orden)
zona <- factor(c("Paramo", "Seco", "Humedo", "Seco", "Nublado", "Paramo"),
               levels = c("Seco", "Humedo", "Montano", "Nublado", "Paramo"))

levels(zona)
#> [1] "Seco"    "Humedo"  "Montano" "Nublado" "Paramo"
nlevels(zona)
#> [1] 5
table(zona)
#> zona
#>    Seco  Humedo Montano Nublado  Paramo
#>       2       1       0       1       2

# Factor ordinal (con orden)
tamano <- factor(c("Mediana", "Grande", "Pequeña", "Grande"),
                 levels = c("Pequeña", "Mediana", "Grande"),
                 ordered = TRUE)
tamano[1] < tamano[2]   # Mediana < Grande
#> [1] TRUE

# En los datos de palma
palma$variedad <- factor(palma$variedad,
                         levels = c("Dura", "Tenera", "Hibrido OxG"))
summary(palma$variedad)
```

### Listas

Las listas son contenedores heterogéneos: pueden almacenar objetos de **cualquier tipo y tamaño**. Son el tipo de retorno habitual de las funciones estadísticas en R:

```r
# Crear una lista con información de una estación meteorológica
estacion_minca <- list(
  nombre       = "Estación Minca",
  coordenadas  = c(latitud = 11.15, longitud = -74.12),
  altura_msnm  = 650,
  variables    = c("temperatura", "humedad", "precipitacion"),
  datos_recientes = data.frame(
    mes   = c("Enero", "Febrero", "Marzo"),
    temp  = c(24.1, 24.8, 25.3),
    precip_mm = c(45, 38, 62)
  )
)

# Acceder a elementos
estacion_minca$nombre
#> [1] "Estación Minca"
estacion_minca[["altura_msnm"]]
#> [1] 650
estacion_minca$datos_recientes$temp
#> [1] 24.1 24.8 25.3

# Los modelos estadísticos devuelven listas
modelo <- lm(temperatura_C ~ altura_msnm, data = biodiversidad)
class(modelo)
#> [1] "lm"
is.list(modelo)
#> [1] TRUE
names(modelo)
#>  [1] "coefficients"  "residuals"     "effects"       "rank"
#>  [5] "fitted.values" "assign"        "qr"            "df.residual"
#>  [9] "xlevels"       "call"          "terms"         "model"
modelo$coefficients
#>  (Intercept)  altura_msnm
#> 28.47856452 -0.00649312
```

---

## Lógica de programación

### Operadores relacionales y lógicos

```r
# Relacionales
5 > 3
#> [1] TRUE
5 == 5     # igualdad: doble igual
#> [1] TRUE
5 != 4     # diferente
#> [1] TRUE
"a" < "b"  # orden alfabético
#> [1] TRUE

# Lógicos
TRUE & FALSE     # AND elemento a elemento
#> [1] FALSE
TRUE | FALSE     # OR elemento a elemento
#> [1] TRUE
!TRUE
#> [1] FALSE

# Pertenencia
"Paramo" %in% c("Seco", "Humedo", "Paramo")
#> [1] TRUE

# Aplicados a vectores (vectorización)
alturas <- c(200, 1500, 3000, 4500)
alturas > 2000
#> [1] FALSE FALSE  TRUE  TRUE
alturas[alturas > 2000]
#> [1] 3000 4500
which(alturas > 2000)    # índices
#> [1] 3 4
any(alturas > 4000)
#> [1] TRUE
all(alturas > 100)
#> [1] TRUE
```

### Estructuras condicionales: `if / else`

```r
# Clasificar una muestra de biodiversidad según su altitud
clasificar_zona <- function(altura) {
  if (altura < 800) {
    return("Bosque Seco Tropical")
  } else if (altura < 1800) {
    return("Bosque Humedo Tropical")
  } else if (altura < 2800) {
    return("Bosque Muy Humedo Montano")
  } else if (altura < 3800) {
    return("Bosque Nublado")
  } else {
    return("Paramo")
  }
}

clasificar_zona(1200)
#> [1] "Bosque Humedo Tropical"
clasificar_zona(4100)
#> [1] "Paramo"

# ifelse() vectorizado (eficiente para columnas)
biodiversidad$es_paramo <- ifelse(biodiversidad$altura_msnm >= 3800, "Sí", "No")
table(biodiversidad$es_paramo)
```

### Bucles: `for`, `while`, `repeat`

```r
# for: iterar sobre un vector de valores conocidos
zonas_vida <- c("Seco", "Humedo", "Montano", "Nublado", "Paramo")

for (zona in zonas_vida) {
  n_obs <- sum(biodiversidad$zona_vida == zona)
  cat(sprintf("  %-30s : %d observaciones\n", zona, n_obs))
}
#>   Seco                           : 38 observaciones
#>   Humedo                         : 42 observaciones
#>   Montano                        : 40 observaciones
#>   Nublado                        : 41 observaciones
#>   Paramo                         : 39 observaciones

# while: iterar mientras se cumpla una condición
set.seed(42)
intentos <- 0
muestra   <- 0

while (muestra < 20) {
  muestra   <- round(runif(1, 10, 30))
  intentos  <- intentos + 1
}
cat("Se necesitaron", intentos, "intentos para obtener muestra >=20\n")
#> Se necesitaron 3 intentos para obtener muestra >=20

# NOTA: En R, los bucles son lentos. Para operaciones sobre vectores/columnas
# usar funciones vectorizadas o apply/purrr (mucho más eficiente):
resultado <- tapply(biodiversidad$altura_msnm,
                    biodiversidad$zona_vida,
                    length)
print(resultado)
#>  Humedo Montano Nublado  Paramo    Seco
#>      42      40      41      39      38
```

### Familia `apply`

```r
# apply(): aplica función a filas (1) o columnas (2) de una matriz/data frame
datos_num <- biodiversidad[, c("altura_msnm", "temperatura_C", "humedad_relativa")]

apply(datos_num, 2, mean)    # Media de cada columna
#>    altura_msnm  temperatura_C humedad_relativa
#>     2445.350         12.606           86.545

apply(datos_num, 2, sd)      # Desviación estándar de cada columna
#>    altura_msnm  temperatura_C humedad_relativa
#>    1341.729         8.715            7.892

# sapply(): devuelve vector o matriz
sapply(datos_num, range)
#>      altura_msnm temperatura_C humedad_relativa
#> [1,]         120          -0.4             70.0
#> [2,]        4980          28.2            100.0

# lapply(): siempre devuelve lista
lapply(zonas_vida, function(z) {
  sub <- biodiversidad[biodiversidad$zona_vida == z, ]
  c(n = nrow(sub), media_temp = round(mean(sub$temperatura_C), 1))
})

# Con purrr (tidyverse): más legible y consistente
library(purrr)
map_dbl(datos_num, mean)    # Media de cada columna (devuelve vector nombrado)
```

---

## Funciones en R

### Anatomía de una función

```r
nombre_funcion <- function(argumento1, argumento2, argumento_con_default = valor) {
  # Cuerpo de la función
  resultado <- argumento1 + argumento2
  return(resultado)   # Valor de retorno (opcional: R devuelve la última expresión)
}
```

### Principios de buenas funciones

Una función debe hacer **una sola cosa** y hacerla bien. Debe tener:
- Nombre descriptivo en `snake_case`
- Argumentos con nombres claros
- Valores por defecto para parámetros opcionales
- Validación de entradas cuando sea necesario

```r
# Función: calcular el índice de diversidad de Shannon
# H' = -sum(p_i * log(p_i))
# donde p_i es la proporción de cada especie
shannon_diversity <- function(conteos, base = exp(1)) {
  if (!is.numeric(conteos)) stop("'conteos' debe ser numérico")
  if (any(conteos < 0))     stop("Los conteos no pueden ser negativos")

  conteos      <- conteos[conteos > 0]
  proporciones <- conteos / sum(conteos)
  H <- -sum(proporciones * log(proporciones, base = base))
  return(round(H, 4))
}

# Aplicar a biodiversidad: riqueza por zona de vida
conteos_zona <- table(biodiversidad$zona_vida)
shannon_diversity(as.numeric(conteos_zona))
#> [1] 1.6088

# Con base 2 (bits)
shannon_diversity(as.numeric(conteos_zona), base = 2)
#> [1] 2.3207
```

El índice de Shannon se define como:

$$H' = -\sum_{i=1}^{S} p_i \ln(p_i)$$

donde $S$ es el número total de especies, $p_i = n_i / N$ es la proporción de individuos de la especie $i$, $n_i$ es el conteo de la especie $i$ y $N = \sum_i n_i$ es el total de individuos.

```r
# Función: convertir altitud a temperatura con gradiente configurable
temp_por_altitud <- function(altura_m, temp_costa = 28.5, gradiente = 6.5) {
  if (altura_m < 0) stop("La altitud no puede ser negativa")
  T <- temp_costa - (altura_m / 1000) * gradiente
  return(round(T, 2))
}

# Vectorizada automáticamente
temp_por_altitud(c(0, 1000, 2000, 3000, 4000))
#> [1] 28.50 22.00 15.50  9.00  2.50

# Gradiente personalizado (Sierra Nevada costa seca: 7.2°C/km)
temp_por_altitud(2000, gradiente = 7.2)
#> [1] 14.1
```

### Funciones de orden superior

```r
# Calcular estadístico personalizado por grupo
resumen_por_zona <- function(datos, variable, estadistico = mean) {
  tapply(datos[[variable]], datos$zona_vida, estadistico)
}

resumen_por_zona(biodiversidad, "temperatura_C")          # Media por zona
#>   Humedo  Montano  Nublado   Paramo     Seco
#>   19.823   13.025    7.088    1.574   25.347

resumen_por_zona(biodiversidad, "humedad_relativa", sd)   # SD por zona
resumen_por_zona(biodiversidad, "altura_msnm", median)    # Mediana por zona
```

---

## Aplicación práctica integrada

En esta sección integramos todo lo anterior en un flujo de análisis completo.

### Análisis exploratorio: Biodiversidad Sierra Nevada

```r
rm(list = ls())
library(tidyverse)

biodiversidad <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/biodiversidad_sierra.csv", encoding = "UTF-8")

# ── 1. Estructura y calidad de datos ──────────────────────────────────────────
cat("=== ESTRUCTURA DEL DATASET ===\n")
glimpse(biodiversidad)
#> Rows: 200
#> Columns: 5
#> $ especie          <chr> "Especie_47", "Especie_23", ...
#> $ altura_msnm      <dbl> 3421, 1204, 2876, ...
#> $ temperatura_C    <dbl> 6.3, 20.9, 9.7, ...
#> $ humedad_relativa <dbl> 93.2, 81.4, 95.1, ...
#> $ zona_vida        <chr> "Nublado", "Humedo", "Paramo", ...

cat("\n=== VALORES FALTANTES ===\n")
sapply(biodiversidad, function(x) sum(is.na(x)))
#>          especie      altura_msnm    temperatura_C humedad_relativa
#>                0                0                0                0
#>        zona_vida
#>                0

# ── 2. Estadísticos descriptivos por zona ─────────────────────────────────────
cat("\n=== RESUMEN POR ZONA DE VIDA ===\n")
biodiversidad |>
  group_by(zona_vida) |>
  summarise(
    n              = n(),
    altura_media   = round(mean(altura_msnm), 0),
    temp_media     = round(mean(temperatura_C), 1),
    temp_sd        = round(sd(temperatura_C), 2),
    humedad_media  = round(mean(humedad_relativa), 1),
    .groups        = "drop"
  ) |>
  arrange(altura_media) |>
  print()
#> # A tibble: 5 × 6
#>   zona_vida       n altura_media temp_media temp_sd humedad_media
#>   <chr>       <int>        <dbl>      <dbl>   <dbl>         <dbl>
#> 1 Seco           38          724       25.3    1.56          73.2
#> 2 Humedo         42         1412       19.8    1.73          82.1
#> 3 Montano        40         2247       13.0    1.48          90.4
#> 4 Nublado        41         3124        7.1    1.52          95.3
#> 5 Paramo         39         4185        1.6    1.49          83.7

# ── 3. Correlación altitud-temperatura ────────────────────────────────────────
r <- cor(biodiversidad$altura_msnm, biodiversidad$temperatura_C)
cat(sprintf("\nCorrelación altitud-temperatura: r = %.4f\n", r))
#> Correlación altitud-temperatura: r = -0.9981

# ── 4. Visualización básica ───────────────────────────────────────────────────
grafico_dispersion <- ggplot(biodiversidad,
       aes(x = altura_msnm, y = temperatura_C, color = zona_vida)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE,
              color = "black", linetype = "dashed") +
  scale_color_viridis_d(option = "D", name = "Zona de vida") +
  labs(
    title    = "Gradiente altitudinal de temperatura",
    subtitle = "Sierra Nevada de Santa Marta — 200 parcelas",
    x        = "Altura (msnm)",
    y        = "Temperatura (°C)",
    caption  = "Fuente: Dataset sintético reproducible (set.seed = 42)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave("output/cap01_gradiente_termico.png",
       grafico_dispersion, width = 8, height = 5, dpi = 300)
cat("Gráfico guardado en output/\n")
```

### Análisis de productividad palmera en el Cesar

```r
palma <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv", encoding = "UTF-8")

# Condicional vectorizado: clasificar productividad
palma$categoria_productividad <- ifelse(
  palma$toneladas_ha < 14, "Baja",
  ifelse(palma$toneladas_ha < 20, "Media", "Alta")
)
palma$categoria_productividad <- factor(
  palma$categoria_productividad,
  levels = c("Baja", "Media", "Alta"),
  ordered = TRUE
)

# Loop para reportar por municipio
cat("\n=== PRODUCTIVIDAD POR MUNICIPIO ===\n")
municipios_ordenados <- palma |>
  group_by(municipio) |>
  summarise(media = mean(toneladas_ha), n = n()) |>
  arrange(desc(media))

for (i in 1:nrow(municipios_ordenados)) {
  cat(sprintf("  %-25s | %.1f ton/ha | n=%d\n",
              municipios_ordenados$municipio[i],
              municipios_ordenados$media[i],
              municipios_ordenados$n[i]))
}
```

### Eficiencia operacional en el Puerto de Barranquilla

```r
logistica <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/logistica_puerto_baq.csv", encoding = "UTF-8")
logistica$fecha <- as.Date(logistica$fecha)

# Función personalizada: clasificar eficiencia
clasificar_eficiencia <- function(pct) {
  if      (pct >= 90) return("Excelente")
  else if (pct >= 75) return("Buena")
  else if (pct >= 60) return("Regular")
  else                return("Deficiente")
}

logistica$nivel_eficiencia <- sapply(logistica$eficiencia_porcentaje,
                                     clasificar_eficiencia)

# Análisis temporal: promedio mensual de eficiencia por tipo de carga
logistica |>
  mutate(mes = format(fecha, "%Y-%m")) |>
  group_by(mes, tipo_carga) |>
  summarise(efic_media = round(mean(eficiencia_porcentaje), 1),
            .groups = "drop") |>
  pivot_wider(names_from = tipo_carga, values_from = efic_media) |>
  print(n = Inf)
```

---

## Ejercicios prácticos

Los ejercicios utilizan los datasets del proyecto. Se recomienda resolver cada uno en un script R independiente dentro de la carpeta `scripts/`.

---

### Ejercicio 1 — Vectores y operaciones básicas

**Contexto:** El gradiente térmico de la Sierra Nevada de Santa Marta.

**Enunciado:**

a) Crea un vector `altitudes` con los valores: 0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 (en metros).

b) Usando la fórmula $T(h) = 28.5 - 6.5 \cdot (h/1000)$, calcula el vector `temperaturas` correspondiente.

c) ¿Cuántas altitudes tienen temperatura mayor a 15°C? Usa operadores lógicos.

d) Calcula la tasa de cambio promedio de temperatura por cada 500 metros de ascenso.

e) Crea un data frame con las dos variables y nómbralas apropiadamente.

```r
# Plantilla de solución
altitudes    <- seq(0, 5000, by = 500)
temperaturas <- ______________________________

# c)
sum(temperaturas > 15)

# d)
cambios <- diff(temperaturas)    # diferencias consecutivas
mean(cambios)

# e)
gradiente_sierra <- data.frame(
  altura_msnm   = altitudes,
  temperatura_C = temperaturas
)
```

---

### Ejercicio 2 — Estructuras condicionales y funciones

**Contexto:** Clasificación de productividad palmera según estándares Fedepalma.

**Enunciado:**

a) Escribe una función `clasificar_palma(ton_ha)` que devuelva:
   - `"Crítica"` si `ton_ha < 10`
   - `"Baja"` si `10 <= ton_ha < 14`
   - `"Media"` si `14 <= ton_ha < 20`
   - `"Alta"` si `20 <= ton_ha < 25`
   - `"Excepcional"` si `ton_ha >= 25`

b) Aplica la función al vector `palma$toneladas_ha` usando `sapply()`.

c) Construye una tabla de frecuencias de las categorías resultantes.

d) ¿Qué porcentaje de las fincas tiene productividad "Alta" o "Excepcional"?

$$\text{Porcentaje} = \frac{n_{\text{Alta}} + n_{\text{Excepcional}}}{N} \times 100$$

---

### Ejercicio 3 — Bucles y familia apply

**Contexto:** Resumen estadístico de los tres datasets del proyecto.

**Enunciado:**

a) Crea una lista llamada `datasets` que contenga los tres data frames: `biodiversidad`, `palma` y `logistica`.

b) Usando un bucle `for`, imprime para cada dataset: nombre, número de filas, número de columnas y nombres de variables.

c) Usando `lapply()`, calcula la media de todas las columnas numéricas de cada dataset.
   *Pista:* Usa `sapply(df, is.numeric)` para identificar columnas numéricas.

d) ¿Cuál es la variable numérica con mayor coeficiente de variación $CV = (s/\bar{x}) \times 100$ entre todos los datasets?

---

### Ejercicio 4 — Data frames y dplyr

**Contexto:** Análisis de operaciones portuarias en Barranquilla.

**Enunciado:**

Usando el dataset `logistica_puerto_baq.csv` y el paquete `dplyr`:

a) Filtra las operaciones del segundo semestre (julio-diciembre de 2023).

b) Calcula el tiempo promedio de carga y la eficiencia promedio por `tipo_carga`, ordenado de mayor a menor eficiencia.

c) Crea una nueva columna `carga_por_hora` = `num_contenedores / tiempo_carga_horas`.

d) Identifica las 5 operaciones más eficientes (mayor `eficiencia_porcentaje`) e imprime su fecha, tipo de carga y eficiencia.

e) ¿Existe diferencia en la eficiencia entre el primer y segundo semestre? Calcula la diferencia de medias:

$$\Delta \bar{x} = \bar{x}_{\text{S2}} - \bar{x}_{\text{S1}}$$

---

### Ejercicio 5 — Función completa con validación

**Contexto:** Cálculo de estadísticos descriptivos con informe automático.

**Enunciado:**

Escribe una función `resumen_estadistico(datos, variable, grupo = NULL)` que:

a) Valide que `variable` existe en `datos` y es numérica.

b) Si `grupo = NULL`, calcule y devuelva una lista con: media $\bar{x}$, mediana, desviación estándar $s$, coeficiente de variación $CV$, mínimo, máximo y rango intercuartílico $IQR$.

c) Si se proporciona `grupo`, calcule las mismas estadísticas para cada nivel del grupo.

d) Incluya una opción `verbose = TRUE` que imprima los resultados formateados con `cat()`.

Las fórmulas a implementar son:

$$\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i \qquad s = \sqrt{\frac{\sum_{i=1}^{n}(x_i - \bar{x})^2}{n-1}} \qquad CV = \frac{s}{\bar{x}} \times 100$$

**Ejemplo de uso esperado:**

```r
resumen_estadistico(biodiversidad, "temperatura_C", verbose = TRUE)
resumen_estadistico(palma, "toneladas_ha", grupo = "variedad", verbose = TRUE)
resumen_estadistico(logistica, "eficiencia_porcentaje", grupo = "tipo_carga")
```

---

## Referencias

- Ihaka, R., & Gentleman, R. (1996). R: A language for data analysis and graphics. *Journal of Computational and Graphical Statistics*, 5(3), 299-314.
- Wickham, H., et al. (2019). Welcome to the Tidyverse. *Journal of Open Source Software*, 4(43), 1686.
- Holdridge, L. R. (1967). *Life Zone Ecology*. Tropical Science Center, San José.
- Fedepalma (2022). *Anuario Estadístico: La agroindustria de la palma de aceite en Colombia*. Federación Nacional de Cultivadores de Palma de Aceite.
- R Core Team (2024). *R: A Language and Environment for Statistical Computing*. R Foundation for Statistical Computing, Vienna, Austria.

---

