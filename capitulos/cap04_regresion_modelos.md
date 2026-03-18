# Capítulo 4: Regresión y Modelos Estadísticos

> **Objetivos del capítulo:**
> Al finalizar este capítulo, el estudiante será capaz de: construir e interpretar modelos de regresión lineal simple y múltiple en R; realizar diagnóstico completo de supuestos; aplicar criterios de selección de variables; introducir la regresión logística; y aplicar todo el flujo de modelización sobre datos reales del Caribe y la Sierra Nevada de Colombia.

---

## Introducción a la modelización estadística

### ¿Qué es un modelo estadístico?

Un **modelo estadístico** es una descripción matemática simplificada de un fenómeno real. No pretende reproducir la realidad con exactitud absoluta —eso sería imposible—, sino capturar las relaciones más importantes entre variables con el mínimo de complejidad necesaria.

En términos formales, un modelo estadístico especifica:

1. Una **estructura determinística** $f(X)$: la parte del comportamiento de $Y$ que podemos explicar con las variables predictoras.
2. Un **componente estocástico** $\varepsilon$: el error aleatorio que recoge todo lo que el modelo no explica (variabilidad natural, variables omitidas, error de medición).

El modelo general queda expresado como:

$$Y = f(X) + \varepsilon$$

donde $Y$ es la **variable dependiente** (también llamada variable respuesta o variable de salida) y $X$ representa el conjunto de **variables independientes** (predictoras, explicativas o de entrada).

### Variable dependiente vs. variables independientes

| Concepto | Notación | Descripción |
|---|---|---|
| Variable dependiente | $Y$ | Lo que queremos explicar o predecir |
| Variables independientes | $X_1, X_2, \ldots, X_p$ | Variables usadas como predictoras |
| Error aleatorio | $\varepsilon$ | Variabilidad no explicada por el modelo |

**Ejemplos con nuestros datos:**

- En `biodiversidad_sierra.csv`: queremos explicar `temperatura_C` (Y) a partir de `altura_msnm` (X). A mayor altitud, menor temperatura: existe una relación física clara.
- En `palma_cesar.csv`: queremos predecir `toneladas_ha` (Y) usando `fertilizante_kg`, `precipitacion_mm` y `variedad` (X's múltiples).
- En `logistica_puerto_baq.csv`: queremos predecir si la `eficiencia_porcentaje` supera un umbral (Y binario) a partir de variables operativas.

### El principio de parsimonia (navaja de Occam)

El principio de parsimonia establece que, entre dos modelos que explican igualmente bien los datos, se debe preferir el más simple. En estadística esto se traduce en:

- No agregar variables al modelo si no mejoran significativamente el ajuste.
- Usar el $R^2$ ajustado en lugar del $R^2$ simple para penalizar la complejidad.
- Utilizar criterios como AIC y BIC que balancean ajuste vs. número de parámetros.

> "Todo modelo debería ser tan simple como sea posible, pero no más." — atribuido a Albert Einstein.

---

## Correlación

Antes de ajustar cualquier modelo, es fundamental entender la **relación lineal** entre las variables. El coeficiente de correlación cuantifica esta relación.

### Correlación de Pearson

La **correlación de Pearson** mide la fuerza y dirección de la asociación lineal entre dos variables continuas:

$$r = \frac{\sum_{i=1}^{n}(x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum_{i=1}^{n}(x_i - \bar{x})^2 \cdot \sum_{i=1}^{n}(y_i - \bar{y})^2}}$$

**Propiedades importantes:**

- $r \in [-1, 1]$
- $r = 1$: correlación positiva perfecta
- $r = -1$: correlación negativa perfecta
- $r = 0$: ausencia de correlación lineal (no necesariamente independencia)
- Es sensible a valores atípicos
- Asume que ambas variables son aproximadamente normales y la relación es lineal

### Correlación de Spearman (no paramétrica)

Cuando los datos no cumplen normalidad, o cuando hay valores atípicos pronunciados, se usa la **correlación de Spearman** $\rho$ (rho), basada en los rangos:

$$\rho = 1 - \frac{6 \sum d_i^2}{n(n^2 - 1)}$$

donde $d_i = \text{rango}(x_i) - \text{rango}(y_i)$.

Spearman detecta monotonía (no solo linealidad) y es más robusta ante distribuciones asimétricas.

### Aplicación en R: correlación con biodiversidad y palma

```r
# ============================================================
# CAPÍTULO 4 — Correlaciones
# Archivo: analisis_correlaciones.R
# ============================================================

# Cargamos los datasets del proyecto
biodiversidad <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/biodiversidad_sierra.csv",
                          stringsAsFactors = TRUE)
palma         <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv",
                          stringsAsFactors = TRUE)
logistica     <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/logistica_puerto_baq.csv",
                          stringsAsFactors = TRUE)

# Inspeccionamos la estructura de cada dataset
str(biodiversidad)  # 200 observaciones: especie, altura_msnm, temperatura_C, etc.
str(palma)          # 150 observaciones: municipio, variedad, toneladas_ha, etc.
str(logistica)      # 100 observaciones: fecha, tipo_carga, contenedores, etc.

# ----------------------------------------------------------
# 2.1 Correlación de Pearson entre dos variables continuas
# ----------------------------------------------------------

# Correlación entre altura y temperatura en Sierra Nevada
r_pearson <- cor(biodiversidad$altura_msnm,
                 biodiversidad$temperatura_C,
                 method = "pearson")

cat("Correlación de Pearson (altura ~ temperatura):", round(r_pearson, 4), "\n")
# Esperamos r negativo: a mayor altitud, menor temperatura

# Prueba de hipótesis: H0: rho = 0
test_pearson <- cor.test(biodiversidad$altura_msnm,
                         biodiversidad$temperatura_C,
                         method = "pearson")

print(test_pearson)
# Interpretamos: p-value, t-statistic, intervalo de confianza de r

# ----------------------------------------------------------
# 2.2 Correlación de Spearman (más robusta)
# ----------------------------------------------------------

r_spearman <- cor(biodiversidad$humedad_relativa,
                  biodiversidad$temperatura_C,
                  method = "spearman")

cat("Correlación de Spearman (humedad ~ temperatura):", round(r_spearman, 4), "\n")

# ----------------------------------------------------------
# 2.3 Matriz de correlaciones para variables numéricas
# ----------------------------------------------------------

# Seleccionamos solo columnas numéricas del dataset biodiversidad
vars_bio <- biodiversidad[, c("altura_msnm", "temperatura_C", "humedad_relativa")]

# Calculamos la matriz de correlaciones de Pearson
mat_cor_bio <- cor(vars_bio, method = "pearson")
print(round(mat_cor_bio, 3))

# Lo mismo para palma del Cesar
vars_palma <- palma[, c("toneladas_ha", "fertilizante_kg", "precipitacion_mm")]
mat_cor_palma <- cor(vars_palma, method = "pearson", use = "complete.obs")
print(round(mat_cor_palma, 3))

# ----------------------------------------------------------
# 2.4 Visualización con corrplot
# ----------------------------------------------------------

# Instalamos corrplot si no está disponible
if (!require(corrplot)) install.packages("corrplot")
library(corrplot)

# Gráfico de correlaciones con métodos visuales distintos
par(mfrow = c(1, 2))   # Dos gráficos lado a lado

# Método "circle": el tamaño del círculo indica la fuerza
corrplot(mat_cor_bio,
         method  = "circle",        # Representación visual
         type    = "upper",         # Solo triángulo superior
         tl.cex  = 0.9,             # Tamaño de etiquetas
         addCoef.col = "black",     # Mostrar coeficientes numéricos
         title   = "Biodiversidad Sierra Nevada",
         mar     = c(0, 0, 2, 0))

# Método "color": gradiente de colores para palma
corrplot(mat_cor_palma,
         method  = "color",
         type    = "upper",
         tl.cex  = 0.9,
         addCoef.col = "black",
         title   = "Palma de Aceite — Cesar",
         mar     = c(0, 0, 2, 0))

par(mfrow = c(1, 1))   # Restauramos disposición original

# ----------------------------------------------------------
# 2.5 corrplot con clustering jerárquico (agrupa variables similares)
# ----------------------------------------------------------
corrplot(mat_cor_palma,
         method   = "ellipse",      # Elipses orientadas según signo
         order    = "hclust",       # Ordenar por clustering jerárquico
         addrect  = 2,              # Dibuja rectángulos alrededor de grupos
         tl.col   = "black")
```

### ¡Correlación no implica causalidad!

Este es uno de los errores más frecuentes en el análisis estadístico. Veamos ejemplos ilustrativos:

- Las ventas de helado correlacionan positivamente con los ahogamientos en playas. ¿Los helados causan ahogamientos? No: ambos son consecuencia del calor veraniego (variable de confusión).
- En Colombia, el número de escuelas construidas en un departamento correlaciona con la tasa de criminalidad. ¿Las escuelas causan crimen? No: ambas variables crecen con la densidad poblacional.
- En nuestro dataset de Sierra Nevada: la `humedad_relativa` puede correlacionar con la `temperatura_C`, pero la humedad no "causa" la temperatura; ambas dependen de la altitud y la circulación atmosférica.

> Siempre que detectes una correlación fuerte, pregúntate: ¿existe un mecanismo causal plausible? ¿Podría haber una tercera variable que explique ambas?

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.42\textwidth]{../output/figuras/fig_cap4_01_capa_base.png}
  \hfill
  \includegraphics[width=0.42\textwidth]{../output/figuras/fig_cap4_02_capa_puntos.png}
  \caption{Construcción progresiva de un gráfico en \texttt{ggplot2}. \textbf{Izquierda:} Capa 1 — solo el canvas vacío con los mapeos estéticos definidos (\texttt{aes}). \textbf{Derecha:} Capa 2 — adición de \texttt{geom\_point()} para visualizar cada finca palmera del Cesar como un punto.}
  \label{fig:cap4_capas_1_2}
\end{figure}

---

## Regresión lineal simple

La **regresión lineal simple** modela la relación entre una variable dependiente $Y$ y una única variable independiente $X$:

$$Y_i = \beta_0 + \beta_1 X_i + \varepsilon_i, \quad \varepsilon_i \sim N(0, \sigma^2)$$

donde:
- $\beta_0$: intercepto (valor de $Y$ cuando $X = 0$)
- $\beta_1$: pendiente (cambio esperado en $Y$ por unidad de aumento en $X$)
- $\varepsilon_i$: error aleatorio, independiente e identicamente distribuido

### Estimación por Mínimos Cuadrados Ordinarios (MCO)

El método MCO minimiza la **suma de cuadrados de los residuos**:

$$SSE = \sum_{i=1}^{n} (y_i - \hat{y}_i)^2 = \sum_{i=1}^{n} (y_i - \hat{\beta}_0 - \hat{\beta}_1 x_i)^2$$

Las soluciones analíticas son:

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{n}(x_i - \bar{x})(y_i - \bar{y})}{\sum_{i=1}^{n}(x_i - \bar{x})^2} = \frac{S_{xy}}{S_{xx}}$$

$$\hat{\beta}_0 = \bar{y} - \hat{\beta}_1 \bar{x}$$

Note que $\hat{\beta}_1 = r \cdot (s_y / s_x)$, es decir, la pendiente MCO es la correlación de Pearson escalada por las desviaciones estándar.

### Bondad de ajuste: el coeficiente $R^2$

$$R^2 = 1 - \frac{SS_{res}}{SS_{tot}} = 1 - \frac{\sum(y_i - \hat{y}_i)^2}{\sum(y_i - \bar{y})^2}$$

El $R^2$ varía entre 0 y 1 e indica qué proporción de la variabilidad total de $Y$ es explicada por el modelo. Un $R^2 = 0.85$ significa que el 85% de la varianza de $Y$ está explicada por $X$.

### Tabla ANOVA de la regresión

| Fuente | GL | SC | CM | F |
|---|---|---|---|---|
| Regresión | 1 | $SS_{reg}$ | $MS_{reg} = SS_{reg}/1$ | $F = MS_{reg}/MSE$ |
| Residuos | $n-2$ | $SS_{res}$ | $MSE = SS_{res}/(n-2)$ | |
| Total | $n-1$ | $SS_{tot}$ | | |

donde $SS_{tot} = SS_{reg} + SS_{res}$.

### Código R completo: temperatura ~ altura en Sierra Nevada

```r
# ============================================================
# SECCIÓN 3: Regresión lineal simple
# Ejemplo: temperatura_C ~ altura_msnm (Sierra Nevada de Santa Marta)
# ============================================================

# Cargamos datos si no están ya en memoria
biodiversidad <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/biodiversidad_sierra.csv",
                          stringsAsFactors = TRUE)

# ----------------------------------------------------------
# 3.1 Visualización exploratoria previa
# ----------------------------------------------------------

# Diagrama de dispersión con línea de tendencia suavizada
plot(biodiversidad$altura_msnm,
     biodiversidad$temperatura_C,
     xlab = "Altitud (m s.n.m.)",
     ylab = "Temperatura (°C)",
     main = "Temperatura vs. Altitud — Sierra Nevada de Santa Marta",
     pch  = 16,                  # Puntos sólidos
     col  = rgb(0.2, 0.4, 0.8,   # Azul semitransparente
                alpha = 0.6),
     cex  = 0.8)                 # Tamaño ligeramente reducido

# Agregamos una línea suavizada LOESS para visualizar la tendencia real
lines(lowess(biodiversidad$altura_msnm,
             biodiversidad$temperatura_C),
      col = "red", lwd = 2)

# ----------------------------------------------------------
# 3.2 Ajuste del modelo lineal con lm()
# ----------------------------------------------------------

# lm(formula, data) es la función principal para regresión en R
modelo_simple <- lm(temperatura_C ~ altura_msnm,
                    data = biodiversidad)

# Resumen completo del modelo
summary(modelo_simple)
# Salida contiene:
#   - Residuos: rango, cuartiles, mediana
#   - Coeficientes: Estimate, Std. Error, t value, Pr(>|t|)
#   - R-squared y R-squared ajustado
#   - Estadístico F de la prueba global

# ----------------------------------------------------------
# 3.3 Extracción de componentes del modelo
# ----------------------------------------------------------

# Coeficientes estimados (beta_0 y beta_1)
coef(modelo_simple)
# (Intercept)   altura_msnm
# ej: 28.50       -0.0065
# Interpretación: por cada metro de altitud adicional,
# la temperatura disminuye ~0.0065 °C = 6.5 °C por cada 1000 m

# Valores ajustados (predicciones sobre los datos de entrenamiento)
y_hat <- fitted(modelo_simple)
head(y_hat, 10)    # Primeras 10 predicciones

# Residuos del modelo: e_i = y_i - y_hat_i
residuos <- residuals(modelo_simple)
head(residuos, 10)

# Verificamos la identidad básica: SC total = SC regresión + SC residuos
SS_tot <- sum((biodiversidad$temperatura_C -
               mean(biodiversidad$temperatura_C))^2)
SS_res <- sum(residuos^2)
SS_reg <- SS_tot - SS_res

R2_manual <- SS_reg / SS_tot
cat("R² calculado manualmente:", round(R2_manual, 4), "\n")
cat("R² del summary:          ", summary(modelo_simple)$r.squared, "\n")
# Deben coincidir

# ----------------------------------------------------------
# 3.4 Visualización final: datos + recta ajustada
# ----------------------------------------------------------

plot(biodiversidad$altura_msnm,
     biodiversidad$temperatura_C,
     xlab = "Altitud (m s.n.m.)",
     ylab = "Temperatura (°C)",
     main = "Regresión lineal: Temperatura ~ Altitud",
     pch  = 16,
     col  = "steelblue",
     cex  = 0.85)

# abline() dibuja la recta usando los coeficientes del modelo
abline(modelo_simple,
       col = "firebrick",
       lwd = 2.5)

# Añadimos texto con el R² dentro del gráfico
R2_val <- round(summary(modelo_simple)$r.squared, 3)
legend("topright",
       legend = bquote(R^2 == .(R2_val)),
       bty = "n",
       cex = 1.1)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.42\textwidth]{../output/figuras/fig_cap4_03_capa_smooth.png}
  \hfill
  \includegraphics[width=0.42\textwidth]{../output/figuras/fig_cap4_04_capa_color.png}
  \caption{Capas 3 y 4 en la construcción progresiva. \textbf{Izquierda:} \texttt{geom\_smooth(method="lm")} añade la recta de regresión MCO y la banda de confianza al 95\%. \textbf{Derecha:} Mapear la variedad al color (\texttt{aes(color=variedad)}) revela que la relación fertilizante--productividad difiere por genotipo.}
  \label{fig:cap4_capas_3_4}
\end{figure}

---

## Inferencia en regresión simple

Una vez estimados los coeficientes, necesitamos saber si son **estadísticamente significativos** y construir intervalos de confianza.

### Error estándar de $\hat{\beta}_1$

$$SE(\hat{\beta}_1) = \sqrt{\frac{MSE}{S_{xx}}} = \sqrt{\frac{MSE}{\sum(x_i - \bar{x})^2}}$$

donde $MSE = SS_{res} / (n-2)$ es la varianza residual estimada.

### Intervalo de confianza para $\beta_1$

$$\hat{\beta}_1 \pm t_{n-2,\, \alpha/2} \cdot SE(\hat{\beta}_1)$$

Un IC del 95% que no contenga el cero indica que $\beta_1$ es significativamente distinto de cero.

### Prueba de significancia

$$H_0: \beta_1 = 0 \quad \text{vs.} \quad H_1: \beta_1 \neq 0$$

Estadístico de prueba:

$$t = \frac{\hat{\beta}_1}{SE(\hat{\beta}_1)} \sim t_{n-2} \text{ bajo } H_0$$

### Intervalos para la predicción

Hay dos tipos de intervalos hacia adelante (para nuevos valores de $X$):

- **IC para la respuesta media** $E[Y|X=x^*]$: más estrecho, refleja incertidumbre sobre la media poblacional.
- **Intervalo de predicción** para una observación individual $Y_{nuevo}$: más ancho, incluye además la variabilidad individual $\sigma^2$.

$$\hat{y}^* \pm t_{n-2,\alpha/2} \cdot SE_{pred}$$

donde $SE_{pred} = \sqrt{MSE\left(1 + \frac{1}{n} + \frac{(x^* - \bar{x})^2}{S_{xx}}\right)}$ para el intervalo de predicción individual.

### Código R: inferencia completa

```r
# ============================================================
# SECCIÓN 4: Inferencia en regresión simple
# ============================================================

# Intervalos de confianza para los coeficientes al 95%
confint(modelo_simple, level = 0.95)
# Columnas: 2.5%  y  97.5%
# Si el IC de altura_msnm no contiene 0 → efecto significativo

# IC al 99% si quisiéramos ser más conservadores
confint(modelo_simple, level = 0.99)

# ----------------------------------------------------------
# 4.1 Predicción puntual e IC sobre nuevos datos
# ----------------------------------------------------------

# Creamos un data.frame con nuevas altitudes de interés
nuevas_altitudes <- data.frame(
  altura_msnm = c(500, 1000, 1500, 2000, 2500, 3000, 3500, 4000)
)

# Predicciones con IC para la media (confidence = incertidumbre en la media)
pred_media <- predict(modelo_simple,
                      newdata  = nuevas_altitudes,
                      interval = "confidence",
                      level    = 0.95)

# Predicciones con intervalo de predicción individual (más ancho)
pred_indiv <- predict(modelo_simple,
                      newdata  = nuevas_altitudes,
                      interval = "prediction",
                      level    = 0.95)

# Tabla comparativa
tabla_pred <- cbind(nuevas_altitudes, pred_media, pred_indiv[, -1])
colnames(tabla_pred) <- c("Altitud_msnm",
                          "Pred", "IC_inf_media", "IC_sup_media",
                          "IP_inf_indiv", "IP_sup_indiv")
print(round(tabla_pred, 2))

# ----------------------------------------------------------
# 4.2 Gráfico con bandas de confianza y predicción
# ----------------------------------------------------------

# Creamos una secuencia densa de altitudes para trazar curvas suaves
x_seq <- data.frame(altura_msnm = seq(min(biodiversidad$altura_msnm),
                                       max(biodiversidad$altura_msnm),
                                       length.out = 200))

# Calculamos ambas bandas
banda_conf <- predict(modelo_simple,
                      newdata  = x_seq,
                      interval = "confidence")
banda_pred <- predict(modelo_simple,
                      newdata  = x_seq,
                      interval = "prediction")

# Graficamos
plot(biodiversidad$altura_msnm,
     biodiversidad$temperatura_C,
     xlab = "Altitud (m s.n.m.)",
     ylab = "Temperatura (°C)",
     main = "Regresión con bandas de confianza y predicción",
     pch  = 16, col = "gray60", cex = 0.7)

# Banda de predicción (más ancha, en gris claro)
polygon(c(x_seq$altura_msnm, rev(x_seq$altura_msnm)),
        c(banda_pred[, "lwr"], rev(banda_pred[, "upr"])),
        col = rgb(1, 0.8, 0.8, 0.4), border = NA)

# Banda de confianza (más estrecha, en azul claro)
polygon(c(x_seq$altura_msnm, rev(x_seq$altura_msnm)),
        c(banda_conf[, "lwr"], rev(banda_conf[, "upr"])),
        col = rgb(0.6, 0.8, 1.0, 0.5), border = NA)

# Recta ajustada
lines(x_seq$altura_msnm, banda_conf[, "fit"],
      col = "firebrick", lwd = 2.5)

legend("topright",
       legend = c("Observaciones", "Recta ajustada",
                  "IC 95% para media", "IP 95% individual"),
       pch    = c(16, NA, NA, NA),
       lty    = c(NA,  1, NA, NA),
       fill   = c(NA, NA, rgb(0.6, 0.8, 1.0, 0.5), rgb(1, 0.8, 0.8, 0.4)),
       border = c(NA, NA, "black", "black"),
       col    = c("gray60", "firebrick", NA, NA),
       bty    = "n", cex = 0.85)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap4_05_facet_wrap.png}
  \caption{\texttt{facet\_wrap} aplicado a las 5 zonas de vida de la Sierra Nevada. Cada panel muestra la relación altitud--temperatura con su propia regresión lineal; el color codifica la humedad relativa (escala viridis). La pendiente es similar entre zonas, pero la variabilidad aumenta en las zonas medias con mayor heterogeneidad microclimática.}
  \label{fig:cap4_facet_wrap}
\end{figure}

---

## Diagnóstico del modelo

El ajuste de una regresión lineal no termina con la obtención de coeficientes: es **obligatorio** verificar que se cumplen los supuestos del MCO.

### Supuestos clásicos de MCO (LINEHI)

1. **Linealidad**: la relación entre $X$ y $Y$ es lineal en los parámetros.
2. **Independencia**: los errores $\varepsilon_i$ son independientes entre sí.
3. **Normalidad**: $\varepsilon_i \sim N(0, \sigma^2)$.
4. **Homocedasticidad**: la varianza del error es constante $\text{Var}(\varepsilon_i) = \sigma^2$ para todo $i$.
5. **No multicolinealidad** (en regresión múltiple): las variables predictoras no son combinaciones lineales exactas entre sí.

### Los 4 gráficos estándar de diagnóstico en R

```r
# ============================================================
# SECCIÓN 5: Diagnóstico del modelo
# ============================================================

# plot() aplicado a un objeto lm produce 4 gráficos de diagnóstico
par(mfrow = c(2, 2))   # Disposición 2x2
plot(modelo_simple)
par(mfrow = c(1, 1))   # Restaurar

# Gráfico 1 — "Residuals vs Fitted":
#   Detecta falta de linealidad y heterocedasticidad.
#   Esperamos: nube aleatoria sin patrón, línea roja horizontal en y=0.

# Gráfico 2 — "Normal Q-Q":
#   Verifica normalidad de los residuos.
#   Esperamos: puntos sobre la diagonal. Colas pesadas = desviación.

# Gráfico 3 — "Scale-Location" (Spread-Location):
#   Detecta heterocedasticidad más claramente.
#   Esperamos: línea horizontal y varianza constante.

# Gráfico 4 — "Residuals vs Leverage":
#   Identifica observaciones influyentes (alto leverage + gran residuo).
#   La distancia de Cook >1 o >4/(n-p-1) señala puntos problemáticos.

# ----------------------------------------------------------
# 5.1 Prueba de Shapiro-Wilk sobre los residuos
# ----------------------------------------------------------
# H0: los residuos siguen distribución normal
# Rechazamos H0 si p < 0.05

shapiro.test(residuals(modelo_simple))
# Si p > 0.05: no rechazamos normalidad → supuesto satisfecho
# Nota: con muestras grandes (n > 200) puede rechazarse por pequeñas
# desviaciones irrelevantes en práctica. Ver también histograma.

# Histograma de residuos con curva normal superpuesta
hist(residuals(modelo_simple),
     breaks   = 20,
     freq     = FALSE,           # Densidad, no frecuencia
     main     = "Histograma de Residuos",
     xlab     = "Residuos",
     col      = "lightblue",
     border   = "white")

# Curva normal teórica con parámetros estimados de los residuos
curve(dnorm(x,
            mean = mean(residuals(modelo_simple)),
            sd   = sd(residuals(modelo_simple))),
      col = "red", lwd = 2, add = TRUE)

# ----------------------------------------------------------
# 5.2 Prueba de Breusch-Pagan para heterocedasticidad
# ----------------------------------------------------------
# H0: varianza del error es constante (homocedasticidad)

if (!require(lmtest)) install.packages("lmtest")
library(lmtest)

bptest(modelo_simple)
# Si p > 0.05: no rechazamos homocedasticidad → supuesto satisfecho
# Si p < 0.05: hay evidencia de heterocedasticidad → considerar
#   correcciones como errores estándar robustos (paquete sandwich)
#   o transformación de la variable respuesta

# ----------------------------------------------------------
# 5.3 Valores influyentes: distancia de Cook y leverage
# ----------------------------------------------------------

# Distancia de Cook: mide cuánto cambian todos los coeficientes
# si se elimina la observación i
cook_d <- cooks.distance(modelo_simple)

# Leverage (hat values): indica cuánto "influye" cada observación
# en sus propias predicciones. Valor alto = punto extremo en X
hat_vals <- hatvalues(modelo_simple)

# Umbral convencional para distancia de Cook: 4/(n-p-1)
n <- nrow(biodiversidad)
p <- 1   # Un predictor
umbral_cook <- 4 / (n - p - 1)
cat("Umbral de Cook:", round(umbral_cook, 4), "\n")

# Identificamos observaciones influyentes
influyentes <- which(cook_d > umbral_cook)
cat("Número de puntos influyentes:", length(influyentes), "\n")
cat("Índices:", influyentes, "\n")

# Gráfico de distancia de Cook
plot(cook_d, type = "h",
     main = "Distancia de Cook — observaciones influyentes",
     ylab = "Distancia de Cook",
     xlab = "Índice de observación",
     col  = ifelse(cook_d > umbral_cook, "firebrick", "steelblue"))
abline(h = umbral_cook, lty = 2, col = "orange", lwd = 2)

# ----------------------------------------------------------
# 5.4 Transformaciones correctivas
# ----------------------------------------------------------

# Si la relación no es lineal: transformación logarítmica
# Útil cuando la dispersión crece con la media (heterocedasticidad)

modelo_log <- lm(log(temperatura_C) ~ altura_msnm,
                 data = biodiversidad)
summary(modelo_log)

# Transformación raíz cuadrada (útil para datos de conteo)
modelo_sqrt <- lm(sqrt(temperatura_C) ~ altura_msnm,
                  data = biodiversidad)

# Box-Cox: encuentra la transformación óptima de potencia lambda
if (!require(MASS)) install.packages("MASS")
library(MASS)

# Solo aplicable cuando Y > 0 en todas las observaciones
boxcox(modelo_simple, lambda = seq(-2, 2, by = 0.1))
# El gráfico muestra el lambda óptimo (máximo de la log-verosimilitud)
# lambda = 1 → sin transformación
# lambda = 0 → log(Y)
# lambda = 0.5 → sqrt(Y)
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap4_06_facet_grid.png}
  \caption{\texttt{facet\_grid} cruzando semestre (filas) y tipo de carga (columnas) en las operaciones del Puerto de Barranquilla. Permite detectar simultáneamente patrones temporales e interacciones entre variables categóricas. Las operaciones de Granel Líquido concentran mayor eficiencia en ambos semestres.}
  \label{fig:cap4_facet_grid}
\end{figure}

---

## Regresión lineal múltiple

La **regresión lineal múltiple** extiende el modelo simple a $p$ variables independientes:

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \cdots + \beta_p X_{pi} + \varepsilon_i$$

### Forma matricial

Con $n$ observaciones y $p$ predictores, el sistema se escribe:

$$\mathbf{Y} = \mathbf{X}\boldsymbol{\beta} + \boldsymbol{\varepsilon}$$

donde:
- $\mathbf{Y}$: vector $n \times 1$ de respuestas
- $\mathbf{X}$: matriz $n \times (p+1)$ de diseño (primera columna de unos para el intercepto)
- $\boldsymbol{\beta}$: vector $(p+1) \times 1$ de parámetros desconocidos
- $\boldsymbol{\varepsilon}$: vector $n \times 1$ de errores

### Estimador MCO matricial

$$\hat{\boldsymbol{\beta}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{Y}$$

### $R^2$ ajustado: penalizando la complejidad

El $R^2$ simple siempre aumenta al agregar variables, aunque sean irrelevantes. El $R^2$ ajustado penaliza por el número de parámetros:

$$R^2_{adj} = 1 - \frac{(1-R^2)(n-1)}{n-p-1}$$

Si agregar una variable no mejora el ajuste, $R^2_{adj}$ puede disminuir.

### Multicolinealidad y el VIF

La **multicolinealidad** ocurre cuando dos o más predictores están altamente correlacionados. Esto no sesga los estimadores, pero infla sus errores estándar, haciendo difícil determinar el efecto individual de cada variable.

El **Factor de Inflación de la Varianza** (VIF) para el predictor $j$ es:

$$VIF_j = \frac{1}{1 - R^2_j}$$

donde $R^2_j$ es el $R^2$ de regredir $X_j$ sobre los demás predictores.

- $VIF_j < 5$: multicolinealidad leve o nula (aceptable)
- $VIF_j \in [5, 10)$: multicolinealidad moderada (precaución)
- $VIF_j \geq 10$: multicolinealidad grave (considerar eliminar variables)

### Variables categóricas: variables dummy

Cuando un predictor es categórico (como `variedad` en palma), R crea automáticamente **variables dummy** con **codificación de referencia**:

- Si `variedad` tiene niveles: "Dura", "Pisífera", "Ténera"
- R crea dummy: `variedadPisifera` y `variedadTenera` (dejando "Dura" como categoría base)
- El coeficiente de `variedadPisifera` = diferencia media entre Pisífera y Dura, manteniendo constante el resto de variables

### Código R completo: modelo múltiple con palma del Cesar

```r
# ============================================================
# SECCIÓN 6: Regresión lineal múltiple
# Dataset: palma_cesar.csv
# Objetivo: predecir toneladas_ha con múltiples predictores
# ============================================================

palma <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv", stringsAsFactors = TRUE)

# Exploramos el dataset
summary(palma)
head(palma)

# ----------------------------------------------------------
# 6.1 Visualización previa: pares de variables
# ----------------------------------------------------------

# pairs() produce una matriz de diagramas de dispersión
pairs(palma[, c("toneladas_ha", "fertilizante_kg", "precipitacion_mm")],
      pch  = 16,
      col  = as.numeric(palma$variedad),   # Color por variedad
      main = "Palma de Aceite — Cesar: relaciones bivariadas")

# ----------------------------------------------------------
# 6.2 Ajuste del modelo múltiple
# ----------------------------------------------------------

# Modelo con dos predictores numéricos y una variable categórica
modelo_multi <- lm(toneladas_ha ~ fertilizante_kg + precipitacion_mm + variedad,
                   data = palma)

# Resumen del modelo
summary(modelo_multi)
# Interpretación de coeficientes:
#   fertilizante_kg: aumento en toneladas_ha por kg adicional de fertilizante
#   precipitacion_mm: aumento en toneladas_ha por mm adicional de precipitación
#   variedadPisifera: diferencia media vs. Dura (referencia)
#   variedadTenera:   diferencia media vs. Dura (referencia)

# ----------------------------------------------------------
# 6.3 Comparación de R² simple vs. ajustado
# ----------------------------------------------------------

cat("R² simple:   ", round(summary(modelo_multi)$r.squared,     4), "\n")
cat("R² ajustado: ", round(summary(modelo_multi)$adj.r.squared,  4), "\n")

# ----------------------------------------------------------
# 6.4 Diagnóstico de multicolinealidad con VIF
# ----------------------------------------------------------

if (!require(car)) install.packages("car")
library(car)

# vif() calcula el Factor de Inflación de la Varianza
vif(modelo_multi)
# Para variables categóricas con más de 2 niveles se reporta el GVIF
# GVIF^(1/(2*Df)) es comparable al VIF estándar: < 2.24 equivale a VIF < 5

# ----------------------------------------------------------
# 6.5 Modelo alternativo: interacción entre variables
# ----------------------------------------------------------

# Incluimos interacción fertilizante × precipitación
# (¿El efecto del fertilizante depende de la lluvia disponible?)
modelo_interac <- lm(toneladas_ha ~ fertilizante_kg * precipitacion_mm + variedad,
                     data = palma)

summary(modelo_interac)

# Comparamos los dos modelos con ANOVA (test de modelos anidados)
anova(modelo_multi, modelo_interac)
# H0: la interacción no mejora el ajuste
# Si p < 0.05: la interacción es significativa y debe incluirse

# ----------------------------------------------------------
# 6.6 Diagnóstico completo del modelo múltiple
# ----------------------------------------------------------

par(mfrow = c(2, 2))
plot(modelo_multi)
par(mfrow = c(1, 1))

# Prueba de heterocedasticidad
bptest(modelo_multi)

# Prueba de normalidad de residuos
shapiro.test(residuals(modelo_multi))

# ----------------------------------------------------------
# 6.7 Predicción con el modelo múltiple
# ----------------------------------------------------------

# Nuevas condiciones agronómicas para predecir rendimiento
nuevas_condiciones <- data.frame(
  fertilizante_kg  = c(150, 200, 250),
  precipitacion_mm = c(1800, 2000, 2200),
  variedad         = factor(c("Tenera", "Tenera", "Dura"),
                            levels = levels(palma$variedad))
)

# Predicción con intervalo de confianza del 95%
pred_palma <- predict(modelo_multi,
                      newdata  = nuevas_condiciones,
                      interval = "prediction",
                      level    = 0.95)

cat("\nPredicciones de toneladas/ha con IC del 95%:\n")
print(cbind(nuevas_condiciones, round(pred_palma, 2)))
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap4_07_temas_comparados.png}
  \caption{El mismo gráfico de boxplot (productividad palmera por variedad) con cuatro temas de \texttt{ggplot2}. \texttt{theme\_gray} es el tema por defecto; \texttt{theme\_minimal} elimina el fondo gris; \texttt{theme\_classic} imita el estilo de publicaciones científicas; el tema personalizado (\textit{custom}) aplica una paleta corporativa definida manualmente.}
  \label{fig:cap4_temas}
\end{figure}

---

## Selección de variables

### Criterios de información: AIC y BIC

Cuando tenemos muchos predictores candidatos, necesitamos criterios objetivos para seleccionar el mejor subconjunto. Los más usados son:

**Criterio de Información de Akaike (AIC):**

$$AIC = -2\ln(\hat{L}) + 2p$$

**Criterio de Información Bayesiano (BIC, también llamado SBC):**

$$BIC = -2\ln(\hat{L}) + p\ln(n)$$

donde $\hat{L}$ es la verosimilitud maximizada del modelo y $p$ es el número de parámetros. **Un AIC/BIC menor indica mejor modelo.** BIC penaliza más que AIC cuando $n > 7$ (ya que $\ln(n) > 2$), tendiendo a seleccionar modelos más parsimoniosos.

### Stepwise regression en R

```r
# ============================================================
# SECCIÓN 7: Selección automática de variables
# ============================================================

palma <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv", stringsAsFactors = TRUE)

# Preparamos un modelo con muchos predictores candidatos
# (incluyendo interacciones y términos polinomiales)

# Modelo completo (todos los predictores)
modelo_completo <- lm(toneladas_ha ~ fertilizante_kg + precipitacion_mm +
                        variedad + municipio,
                      data = palma)

# Modelo nulo (solo el intercepto)
modelo_nulo <- lm(toneladas_ha ~ 1, data = palma)

# ----------------------------------------------------------
# 7.1 Selección stepwise "both" (hacia adelante y atrás)
# ----------------------------------------------------------

# step() usa AIC por defecto; direction puede ser:
#   "forward"  — empieza con modelo nulo, agrega variables
#   "backward" — empieza con modelo completo, elimina variables
#   "both"     — combinación de ambas estrategias

modelo_step <- step(modelo_completo,
                    direction = "both",    # Estrategia bidireccional
                    trace     = 1)         # trace=1 muestra el proceso

# Resultado: el modelo con menor AIC
summary(modelo_step)

# ----------------------------------------------------------
# 7.2 Selección forward desde el modelo nulo
# ----------------------------------------------------------

modelo_forward <- step(modelo_nulo,
                       scope     = list(lower = modelo_nulo,
                                        upper = modelo_completo),
                       direction = "forward",
                       trace     = 1)

summary(modelo_forward)

# ----------------------------------------------------------
# 7.3 Comparación de AIC y BIC entre modelos
# ----------------------------------------------------------

# AIC de múltiples modelos
AIC(modelo_nulo, modelo_multi, modelo_completo, modelo_step)

# BIC
BIC(modelo_nulo, modelo_multi, modelo_completo, modelo_step)

# Tabla comparativa
comparacion <- data.frame(
  Modelo = c("Nulo", "Multi (3 pred)", "Completo", "Stepwise"),
  AIC    = AIC(modelo_nulo, modelo_multi, modelo_completo, modelo_step)$AIC,
  BIC    = BIC(modelo_nulo, modelo_multi, modelo_completo, modelo_step)$BIC,
  R2_adj = c(
    summary(modelo_nulo)$adj.r.squared,
    summary(modelo_multi)$adj.r.squared,
    summary(modelo_completo)$adj.r.squared,
    summary(modelo_step)$adj.r.squared
  )
)

print(round(comparacion, 2))
# El modelo con menor AIC/BIC y mayor R²_adj es el más equilibrado

# ----------------------------------------------------------
# 7.4 ADVERTENCIA sobre selección automática de variables
# ----------------------------------------------------------

# La selección stepwise tiene limitaciones importantes:
# 1) Optimiza para los datos disponibles (sobreajuste si n es pequeño)
# 2) No considera la coherencia teórica del modelo
# 3) Los p-valores post-selección están sesgados (no deben interpretarse
#    como pruebas independientes)
# 4) Puede omitir variables con efecto real pero baja significancia
#    individual cuando hay multicolinealidad
#
# RECOMENDACIÓN: usar stepwise solo como guía exploratoria,
# no como sustituto del criterio teórico del investigador.
# Siempre valide el modelo final con datos externos (cross-validation).
```

\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figuras/fig_cap4_08_grafico_complejo.png}
  \caption{Gráfico complejo final integrando múltiples capas y estéticas: dispersión altura--temperatura con color por zona de vida (paleta viridis), tamaño de punto proporcional a la humedad relativa, y líneas de regresión independientes por zona. Este gráfico ilustra el poder expresivo de la gramática de gráficos: cinco variables representadas simultáneamente en un único plano.}
  \label{fig:cap4_complejo}
\end{figure}

---

## Regresión logística (introducción)

Cuando la variable dependiente es **binaria** ($Y \in \{0, 1\}$), el modelo de regresión lineal no es apropiado porque podría predecir probabilidades fuera de $[0, 1]$. La solución es la **regresión logística**.

### El modelo logístico

Modelamos directamente la **probabilidad** de que $Y = 1$:

$$\ln\left(\frac{p}{1-p}\right) = \eta = \beta_0 + \beta_1 X$$

El lado izquierdo es el **logit** (log-odds). Despejando $p$:

$$p = \frac{e^{\eta}}{1 + e^{\eta}} = \frac{1}{1 + e^{-\eta}}$$

Esta es la **función logística** (sigmoide), que transforma cualquier valor real de $\eta$ en una probabilidad entre 0 y 1.

### Interpretación con odds ratio

El coeficiente $\beta_1$ no se interpreta directamente como en regresión lineal. El **odds ratio** mide cuánto cambia el cociente de probabilidades:

$$OR = e^{\beta_1}$$

- $OR > 1$: al aumentar $X$ en 1 unidad, aumentan las probabilidades de $Y = 1$
- $OR < 1$: al aumentar $X$ en 1 unidad, disminuyen las probabilidades de $Y = 1$
- $OR = 1$: $X$ no tiene efecto sobre $Y$

### Código R: predecir eficiencia en el Puerto de Barranquilla

```r
# ============================================================
# SECCIÓN 8: Regresión logística
# Dataset: logistica_puerto_baq.csv
# Objetivo: predecir si eficiencia_porcentaje > 80%
# ============================================================

logistica <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/logistica_puerto_baq.csv",
                      stringsAsFactors = TRUE)

# Creamos variable binaria: 1 = eficiencia alta (>80%), 0 = baja
logistica$eficiencia_alta <- as.integer(logistica$eficiencia_porcentaje > 80)

# Exploramos la distribución de la nueva variable
table(logistica$eficiencia_alta)
prop.table(table(logistica$eficiencia_alta))
# ¿Qué porcentaje de operaciones logra eficiencia alta?

# ----------------------------------------------------------
# 8.1 Modelo logístico simple: eficiencia ~ num_contenedores
# ----------------------------------------------------------

# glm() con family = binomial ajusta regresión logística
modelo_logit <- glm(eficiencia_alta ~ num_contenedores,
                    data   = logistica,
                    family = binomial(link = "logit"))  # link por defecto

summary(modelo_logit)
# Coeficientes en escala logit (log-odds)
# Residual deviance vs Null deviance: indicador de ajuste
# AIC: criterio para comparar modelos logísticos

# ----------------------------------------------------------
# 8.2 Interpretación con odds ratio
# ----------------------------------------------------------

# exp() de los coeficientes da los odds ratios
OR <- exp(coef(modelo_logit))
cat("Odds Ratios:\n")
print(round(OR, 4))

# IC para los OR (exponencial de los IC de los log-odds)
IC_log <- confint(modelo_logit, level = 0.95)
IC_OR  <- exp(IC_log)
cat("\nIC 95% para Odds Ratios:\n")
print(round(IC_OR, 4))

# ----------------------------------------------------------
# 8.3 Modelo logístico múltiple
# ----------------------------------------------------------

modelo_logit_multi <- glm(eficiencia_alta ~ num_contenedores +
                            tiempo_carga_horas + tipo_carga,
                          data   = logistica,
                          family = binomial)

summary(modelo_logit_multi)

# Odds ratios del modelo múltiple
OR_multi <- exp(cbind(OR = coef(modelo_logit_multi),
                      confint(modelo_logit_multi)))
print(round(OR_multi, 3))

# ----------------------------------------------------------
# 8.4 Predicción de probabilidades
# ----------------------------------------------------------

# Predecir probabilidades de eficiencia alta para nuevas operaciones
nuevas_op <- data.frame(
  num_contenedores   = c(50, 100, 150, 200),
  tiempo_carga_horas = c(4, 6, 8, 10),
  tipo_carga         = factor(rep("contenedor", 4),
                              levels = levels(logistica$tipo_carga))
)

# type = "response" devuelve probabilidades (no log-odds)
prob_pred <- predict(modelo_logit_multi,
                     newdata = nuevas_op,
                     type    = "response")

cat("\nProbabilidades de eficiencia alta:\n")
print(data.frame(nuevas_op, prob_eficiencia_alta = round(prob_pred, 3)))

# ----------------------------------------------------------
# 8.5 Evaluación del modelo: matriz de confusión
# ----------------------------------------------------------

# Predecimos sobre los datos de entrenamiento
prob_train <- fitted(modelo_logit_multi)

# Umbral de decisión: 0.5 (puede ajustarse según el contexto)
pred_clase <- as.integer(prob_train >= 0.5)

# Matriz de confusión
tabla_conf <- table(Real     = logistica$eficiencia_alta,
                    Predicho = pred_clase)
print(tabla_conf)

# Accuracy (precisión global)
accuracy <- sum(diag(tabla_conf)) / sum(tabla_conf)
cat("Accuracy del modelo:", round(accuracy, 4), "\n")

# Curva ROC (requiere paquete pROC)
if (!require(pROC)) install.packages("pROC")
library(pROC)

roc_obj <- roc(logistica$eficiencia_alta, prob_train,
               quiet = TRUE)
plot(roc_obj,
     main = "Curva ROC — Eficiencia Puerto de Barranquilla",
     col  = "steelblue", lwd = 2)
cat("AUC:", round(auc(roc_obj), 4), "\n")
# AUC = 0.5: modelo sin poder discriminativo (como azar)
# AUC = 1.0: modelo perfecto
# AUC > 0.8: buen discriminador
```

---

## Aplicación integrada: modelo completo paso a paso

Esta sección ilustra el **flujo de trabajo completo** de modelización estadística aplicando todos los conceptos del capítulo sobre el dataset `palma_cesar.csv`.

```r
# ============================================================
# SECCIÓN 9: Flujo completo de modelización
# Dataset: palma_cesar.csv
# ============================================================

palma <- read.csv("https://raw.githubusercontent.com/froylanjimenez/libroU/main/data/palma_cesar.csv", stringsAsFactors = TRUE)

# ======================================================
# PASO 1: Exploración inicial
# ======================================================

cat("=== EXPLORACIÓN INICIAL ===\n")
str(palma)          # Estructura: tipos de variables, dimensiones
summary(palma)      # Estadísticos descriptivos de cada variable
dim(palma)          # 150 observaciones × columnas

# Verificamos valores faltantes
cat("\nValores faltantes por variable:\n")
print(colSums(is.na(palma)))

# Distribución de la variable respuesta
hist(palma$toneladas_ha,
     breaks = 20,
     main   = "Distribución del rendimiento (ton/ha)",
     xlab   = "Toneladas por hectárea",
     col    = "olivedrab3",
     border = "white")

# ======================================================
# PASO 2: Correlaciones
# ======================================================

cat("\n=== MATRIZ DE CORRELACIONES ===\n")

# Solo variables numéricas
vars_num <- palma[, sapply(palma, is.numeric)]
mat_cor  <- cor(vars_num, use = "complete.obs")
print(round(mat_cor, 3))

# Visualización
library(corrplot)
corrplot(mat_cor,
         method      = "color",
         type        = "upper",
         addCoef.col = "black",
         title       = "Correlaciones — Palma Cesar",
         mar         = c(0, 0, 2, 0))

# ======================================================
# PASO 3: Ajuste del modelo múltiple
# ======================================================

cat("\n=== AJUSTE DEL MODELO MÚLTIPLE ===\n")

modelo_palma <- lm(toneladas_ha ~ fertilizante_kg + precipitacion_mm + variedad,
                   data = palma)

print(summary(modelo_palma))

# ======================================================
# PASO 4: Diagnóstico de supuestos
# ======================================================

cat("\n=== DIAGNÓSTICO DE SUPUESTOS ===\n")

# Gráficos estándar
par(mfrow = c(2, 2))
plot(modelo_palma, main.title = "Diagnóstico — Palma Cesar")
par(mfrow = c(1, 1))

# Shapiro-Wilk
sw_test <- shapiro.test(residuals(modelo_palma))
cat("Shapiro-Wilk: W =", round(sw_test$statistic, 4),
    " | p-value =", round(sw_test$p.value, 4), "\n")
if (sw_test$p.value > 0.05) {
  cat("  → No rechazamos normalidad de residuos (p > 0.05)\n")
} else {
  cat("  → Evidencia contra normalidad (p ≤ 0.05)\n")
}

# Breusch-Pagan
library(lmtest)
bp_test <- bptest(modelo_palma)
cat("Breusch-Pagan: BP =", round(bp_test$statistic, 4),
    " | p-value =", round(bp_test$p.value, 4), "\n")
if (bp_test$p.value > 0.05) {
  cat("  → No rechazamos homocedasticidad (p > 0.05)\n")
} else {
  cat("  → Evidencia de heterocedasticidad (p ≤ 0.05)\n")
}

# VIF
library(car)
cat("\nFactor de Inflación de la Varianza (VIF):\n")
print(vif(modelo_palma))

# ======================================================
# PASO 5: Selección de variables con AIC
# ======================================================

cat("\n=== SELECCIÓN DE VARIABLES (AIC) ===\n")

# Modelo con todos los predictores disponibles
modelo_completo_palma <- lm(toneladas_ha ~ fertilizante_kg + precipitacion_mm +
                              variedad + municipio,
                            data = palma)

# Stepwise bidireccional
modelo_aic <- step(modelo_completo_palma,
                   direction = "both",
                   trace     = 0)   # trace=0 suprime el output detallado

cat("Modelo seleccionado por AIC:\n")
print(formula(modelo_aic))
cat("AIC del modelo seleccionado:", AIC(modelo_aic), "\n")
cat("AIC del modelo completo:    ", AIC(modelo_completo_palma), "\n")

# ======================================================
# PASO 6: Interpretación final
# ======================================================

cat("\n=== MODELO FINAL: INTERPRETACIÓN ===\n")
modelo_final <- modelo_aic   # Adoptamos el modelo seleccionado por AIC

coef_final <- coef(modelo_final)
print(round(coef_final, 4))

# Intervalos de confianza al 95% para cada coeficiente
cat("\nIntervalos de confianza al 95%:\n")
print(round(confint(modelo_final), 4))

# R² y R² ajustado del modelo final
cat("\nR² =",     round(summary(modelo_final)$r.squared, 4))
cat("\nR²_adj =", round(summary(modelo_final)$adj.r.squared, 4), "\n")

# ======================================================
# PASO 7: Predicción con nuevos datos
# ======================================================

cat("\n=== PREDICCIONES CON NUEVOS DATOS ===\n")

# Definimos condiciones agronómicas hipotéticas del Cesar
nuevos_datos_cesar <- data.frame(
  fertilizante_kg  = c(180, 210, 240),
  precipitacion_mm = c(1900, 2100, 2300),
  variedad         = factor(c("Tenera", "Dura", "Tenera"),
                            levels = levels(palma$variedad)),
  municipio        = factor(c("Aguachica", "Valledupar", "Codazzi"),
                            levels = levels(palma$municipio))
)

predicciones_finales <- predict(modelo_final,
                                newdata  = nuevos_datos_cesar,
                                interval = "prediction",
                                level    = 0.95)

resultado_final <- cbind(nuevos_datos_cesar[, c("municipio", "variedad",
                                                 "fertilizante_kg")],
                          round(predicciones_finales, 2))
colnames(resultado_final)[4:6] <- c("Prediccion_ton_ha",
                                    "LI_95%", "LS_95%")
print(resultado_final)

cat("\nConclusión: El modelo final predice que un cultivo de variedad Ténera",
    "\nen Aguachica con 180 kg de fertilizante y ~1900 mm de precipitación",
    "\nrendirá aproximadamente", round(predicciones_finales[1, "fit"], 1),
    "toneladas por hectárea (IC 95%: [",
    round(predicciones_finales[1, "lwr"], 1), ",",
    round(predicciones_finales[1, "upr"], 1), "]).\n")
```

---

## Ejercicios prácticos

Los siguientes ejercicios proponen situaciones reales del **Caribe Colombiano** que integran los tres datasets del libro. Se espera que el estudiante aplique el flujo completo: exploración, modelización, diagnóstico e interpretación.

---

### Ejercicio 1: Gradiente altitudinal en la Sierra Nevada

**Contexto:** La Sierra Nevada de Santa Marta es el sistema montañoso costero más alto del mundo, con picos que superan los 5700 m s.n.m. El gradiente altitudinal determina los ecosistemas (pisos térmicos) y la distribución de la biodiversidad.

**Datos:** `data/biodiversidad_sierra.csv`

**Tareas:**

a) Ajusta el modelo de regresión lineal simple:

$$\text{humedad\_relativa}_i = \beta_0 + \beta_1 \cdot \text{altura\_msnm}_i + \varepsilon_i$$

b) Interpreta el coeficiente $\hat{\beta}_1$. ¿La humedad relativa aumenta o disminuye con la altitud en este ecosistema? ¿Es estadísticamente significativa la pendiente ($\alpha = 0.05$)?

c) Calcula el intervalo de predicción al 95% para la humedad relativa a 2500 m s.n.m. Interpreta la diferencia entre el IC de la media y el intervalo de predicción individual.

d) Realiza el diagnóstico completo: prueba de Shapiro-Wilk, Breusch-Pagan, y los 4 gráficos estándar. ¿Se cumplen los supuestos MCO?

e) Añade `temperatura_C` como segundo predictor (regresión múltiple). Compara los AIC del modelo simple y el múltiple. ¿Mejora el modelo?

**Pista:** El gradiente pluviométrico en la Sierra Nevada es complejo: las laderas norte (barlovento) reciben más lluvia que las sur (sotavento). Considera explorar si `zona_vida` actúa como variable moderadora.

---

### Ejercicio 2: Productividad de palma y precipitación en el Cesar

**Contexto:** El departamento del Cesar es uno de los principales productores de palma de aceite en Colombia. La precipitación y el manejo del fertilizante determinan en gran medida los rendimientos en toneladas por hectárea.

**Datos:** `data/palma_cesar.csv`

**Tareas:**

a) Ajusta el modelo:

$$\ln(\text{toneladas\_ha}_i) = \beta_0 + \beta_1 \cdot \text{fertilizante\_kg}_i + \beta_2 \cdot \text{precipitacion\_mm}_i + \varepsilon_i$$

Nota: la transformación logarítmica en $Y$ sugiere una relación multiplicativa. Interpreta $\hat{\beta}_1$ como: "un aumento de 1 kg en fertilizante se asocia con un cambio multiplicativo de $e^{\hat{\beta}_1}$ en el rendimiento".

b) Calcula los VIF del modelo. ¿Hay problemas de multicolinealidad entre `fertilizante_kg` y `precipitacion_mm`?

c) Compara gráficamente los residuos del modelo con $Y$ original vs. el modelo con $\ln(Y)$. ¿Cuál cumple mejor los supuestos?

d) Usando el modelo con $\ln(Y)$, predice el rendimiento esperado para un finca de variedad Ténera en Valledupar con 200 kg de fertilizante y 2000 mm de precipitación. Recuerda retransformar: $\hat{y} = e^{\hat{\ln(y)}}$.

e) Aplica selección stepwise (AIC) incluyendo el predictor `municipio`. ¿Qué municipios del Cesar muestran diferencias significativas en rendimiento después de controlar por fertilizante y precipitación?

---

### Ejercicio 3: Eficiencia portuaria en Barranquilla

**Contexto:** El Puerto de Barranquilla (Sociedad Portuaria del Río) opera en el río Magdalena y maneja carga diversa: contenedores, graneles, carga general. La eficiencia operativa es crítica para la competitividad del Caribe colombiano.

**Datos:** `data/logistica_puerto_baq.csv`

**Tareas:**

a) Ajusta un modelo de regresión lineal múltiple:

$$\text{eficiencia\_porcentaje}_i = \beta_0 + \beta_1 \cdot \text{num\_contenedores}_i + \beta_2 \cdot \text{tiempo\_carga\_horas}_i + \beta_3 \cdot \text{tipo\_carga}_i + \varepsilon_i$$

Interpreta el coeficiente asociado a `tiempo_carga_horas`. ¿Un mayor tiempo de carga se asocia con mayor o menor eficiencia?

b) Crea una variable binaria `alta_eficiencia = 1` si `eficiencia_porcentaje > 75`, y ajusta un modelo de regresión logística con `num_contenedores` y `tipo_carga` como predictores.

c) Calcula e interpreta el odds ratio de `num_contenedores`. ¿Cómo cambia la probabilidad de alta eficiencia con cada contenedor adicional?

d) Evalúa el modelo logístico mediante: (i) matriz de confusión con umbral 0.5; (ii) sensibilidad y especificidad; (iii) AUC de la curva ROC.

e) Propón un umbral de clasificación alternativo al 0.5 que maximice la **sensibilidad** (capacidad de detectar operaciones realmente eficientes). Justifica tu elección en términos del costo de los errores en el contexto portuario.

---

### Ejercicio 4: Modelo integrado multi-dataset — Índice de sostenibilidad

**Contexto:** Un grupo de investigadores de la Universidad del Norte (Barranquilla) quiere construir un **índice de sostenibilidad regional** que combine información ambiental (Sierra Nevada), agropecuaria (Palma — Cesar) y logística (Puerto). Para ello, normalizan cada variable a escala 0-100 y construyen un score compuesto.

**Tareas:**

a) Normaliza las variables `temperatura_C`, `humedad_relativa` y `altura_msnm` del dataset de biodiversidad a escala [0, 100] usando la transformación min-max:

$$x_{norm} = \frac{x - x_{min}}{x_{max} - x_{min}} \times 100$$

b) Calcula la media por `zona_vida` de las variables normalizadas. ¿Qué zona de vida tiene mayor temperatura normalizada? ¿Cuál tiene mayor humedad?

c) En el dataset de palma, ajusta un modelo de regresión de `toneladas_ha` sobre el polinomio de segundo grado de `precipitacion_mm`:

$$\text{toneladas\_ha}_i = \beta_0 + \beta_1 \cdot \text{precip}_i + \beta_2 \cdot \text{precip}_i^2 + \varepsilon_i$$

¿El término cuadrático es significativo? ¿En qué nivel de precipitación se maximiza el rendimiento? (Diferencia $\partial Y / \partial precip = \beta_1 + 2\beta_2 \cdot precip = 0$.)

d) En el dataset logístico, crea la variable `operaciones_por_hora = num_contenedores / tiempo_carga_horas` y regresa `eficiencia_porcentaje` sobre ella. ¿Es mejor predictor que `num_contenedores` y `tiempo_carga_horas` por separado (comparar AIC)?

---

### Ejercicio 5: Proyecto integrador — Reporte técnico para la Gobernación del Magdalena

**Contexto:** La Gobernación del Magdalena solicita un análisis estadístico para apoyar decisiones de política pública en tres ejes: conservación ambiental (Sierra Nevada), desarrollo agropecuario (palma en Cesar) y competitividad logística (puerto). El equipo debe presentar un reporte con modelos estadísticos justificados.

**Tareas:**

a) **Eje ambiental:** Usando `biodiversidad_sierra.csv`, determina qué variable (`altura_msnm`, `temperatura_C` o `humedad_relativa`) es el mejor predictor del número de especies (`especie` convertida a recuento por zona). Justifica con $R^2_{adj}$ y AIC.

b) **Eje agropecuario:** Ajusta un modelo de regresión múltiple completo para `toneladas_ha` incluyendo: `fertilizante_kg`, `precipitacion_mm`, `variedad` y la interacción `fertilizante_kg:variedad`. Interpreta si el efecto del fertilizante difiere según la variedad de palma.

c) **Eje logístico:** Aplica regresión logística para predecir si una operación portuaria alcanzará alta eficiencia. Presenta la ecuación del modelo ajustado en términos de probabilidad:

$$\hat{p} = \frac{1}{1 + e^{-(\hat{\beta}_0 + \hat{\beta}_1 x_1 + \hat{\beta}_2 x_2)}}$$

d) Redacta en no más de 200 palabras las **conclusiones integradas** de los tres modelos, como si fuera el resumen ejecutivo de un informe técnico para tomadores de decisiones no estadísticos de la Gobernación del Magdalena. Usa lenguaje claro, sin jerga técnica, pero con cifras precisas de los modelos.

e) Reflexiona sobre las **limitaciones de los modelos**: ¿Qué variables relevantes no están disponibles en los datasets? ¿Qué supuestos MCO podrían ser más problemáticos en cada contexto? ¿Cómo mejorarías el diseño de recolección de datos para futuros análisis?

---

## Resumen del capítulo

En este capítulo hemos recorrido el núcleo de la modelización estadística en R:

| Concepto | Función R clave |
|---|---|
| Correlación de Pearson/Spearman | `cor()`, `cor.test()` |
| Visualización de correlaciones | `corrplot()` |
| Regresión lineal simple | `lm()`, `summary()` |
| Coeficientes e inferencia | `coef()`, `confint()` |
| Predicción con IC | `predict(..., interval = "confidence/prediction")` |
| Diagnóstico de supuestos | `plot(modelo)`, `shapiro.test()`, `bptest()` |
| Valores influyentes | `cooks.distance()`, `hatvalues()` |
| Regresión múltiple y VIF | `lm()`, `vif()` del paquete `car` |
| Selección de variables | `step()`, `AIC()`, `BIC()` |
| Regresión logística | `glm(..., family = binomial)` |
| Odds ratios | `exp(coef())`, `exp(confint())` |
| Curva ROC y AUC | `roc()`, `auc()` del paquete `pROC` |

**Ideas clave para retener:**

1. La correlación mide asociación lineal, no causalidad.
2. Los supuestos MCO deben verificarse siempre; un buen coeficiente con supuestos violados es poco confiable.
3. El $R^2$ ajustado y los criterios AIC/BIC permiten comparar modelos de distinta complejidad.
4. La regresión logística es la herramienta natural para respuestas binarias; interpretar sus coeficientes requiere el paso $e^{\hat{\beta}}$ (odds ratios).
5. La parsimonia es una virtud: un modelo simple e interpretable suele superar en aplicación práctica a uno complejo y opaco.

---

