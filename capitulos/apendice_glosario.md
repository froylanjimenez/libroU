# Apéndice B: Glosario Bilingüe

Este glosario recoge los términos técnicos usados en el libro, con su equivalente en inglés y una definición breve.

---

| Término en español | Término en inglés | Definición |
|---|---|---|
| **Asimetría** | Skewness | Medida del grado de falta de simetría de una distribución. $g_1 > 0$: cola derecha; $g_1 < 0$: cola izquierda. |
| **Coeficiente de determinación** | Coefficient of determination ($R^2$) | Proporción de la variabilidad de $Y$ explicada por el modelo de regresión. |
| **Coeficiente de variación** | Coefficient of variation (CV) | Razón entre la desviación estándar y la media, expresada como porcentaje. Permite comparar dispersión entre variables de distinta escala. |
| **Curtosis** | Kurtosis | Medida del grado de concentración de los datos en el centro versus las colas de la distribución. |
| **Datos ordenados** | Tidy data | Principio de organización de datos donde cada variable es una columna, cada observación una fila y cada unidad observacional una tabla. |
| **Diagrama de caja** | Box plot / Box-and-whisker plot | Representación gráfica de la distribución mediante los cinco estadísticos de orden: mínimo, Q₁, mediana, Q₃ y máximo, con detección visual de valores atípicos. |
| **Error estándar** | Standard error (SE) | Desviación estándar de la distribución muestral de un estadístico. $SE(\bar{X}) = \sigma/\sqrt{n}$. |
| **Error tipo I** | Type I error ($\alpha$) | Rechazar $H_0$ cuando es verdadera. Su probabilidad es el nivel de significancia $\alpha$. |
| **Error tipo II** | Type II error ($\beta$) | No rechazar $H_0$ cuando es falsa. Su probabilidad es $\beta = 1 - \text{Potencia}$. |
| **Grados de libertad** | Degrees of freedom (df) | Número de valores en el cálculo de un estadístico que son libres de variar. En la varianza muestral: $df = n - 1$. |
| **Heterocedasticidad** | Heteroscedasticity | Incumplimiento del supuesto de varianza constante en los residuos de un modelo de regresión. |
| **Homocedasticidad** | Homoscedasticity | Supuesto de que los residuos de un modelo de regresión tienen varianza constante en todos los niveles de $X$. |
| **Inferencia estadística** | Statistical inference | Proceso de extraer conclusiones sobre una población a partir de una muestra, cuantificando la incertidumbre. |
| **Intervalo de confianza** | Confidence interval (CI) | Rango de valores que contiene el parámetro verdadero con un nivel de confianza $(1-\alpha) \times 100\%$ en muestras repetidas. |
| **Mínimos cuadrados ordinarios** | Ordinary least squares (OLS / MCO) | Método de estimación que minimiza la suma de los cuadrados de los residuos para encontrar los coeficientes de regresión óptimos. |
| **Multicolinealidad** | Multicollinearity | Correlación elevada entre dos o más predictores en un modelo de regresión múltiple, que dificulta la estimación de coeficientes individuales. |
| **Odds ratio** | Odds ratio | En regresión logística, razón entre las probabilidades de éxito y fracaso. Un OR > 1 indica mayor probabilidad de éxito al aumentar el predictor. |
| **Operador tubería** | Pipe operator | El operador `\|>` (o `%>%`) encadena funciones de izquierda a derecha: `datos \|> función1() \|> función2()`. |
| **Parámetro** | Parameter | Característica numérica de una **población** (generalmente desconocida). Se denota con letras griegas: $\mu$, $\sigma$, $p$. |
| **Percentil** | Percentile | Valor por debajo del cual se encuentra un determinado porcentaje de los datos. |
| **Potencia estadística** | Statistical power ($1-\beta$) | Probabilidad de rechazar $H_0$ cuando es falsa, es decir, de detectar un efecto real. Umbral convencional: 80%. |
| **Prueba bilateral** | Two-tailed test | Prueba de hipótesis donde la región de rechazo se divide en ambas colas de la distribución. $H_1: \mu \neq \mu_0$. |
| **Regresión logística** | Logistic regression | Modelo estadístico para variables dependientes dicotómicas que estima la probabilidad de un evento mediante la función logística. |
| **Residuo** | Residual | Diferencia entre el valor observado y el valor predicho por el modelo: $e_i = y_i - \hat{y}_i$. |
| **Sobreajuste** | Overfitting | Fenómeno en el que un modelo se ajusta demasiado a los datos de entrenamiento y pierde capacidad de generalización a datos nuevos. |
| **Tamaño del efecto** | Effect size | Medida estandarizada de la magnitud de una diferencia o relación estadística, independiente del tamaño de muestra. El *d* de Cohen clasifica: pequeño (0.2), mediano (0.5), grande (0.8). |
| **Teorema Central del Límite** | Central Limit Theorem (CLT / TCL) | Afirma que la distribución de la media muestral $\bar{X}$ se aproxima a una normal con media $\mu$ y varianza $\sigma^2/n$ conforme $n \to \infty$. |
| **Valor atípico** | Outlier | Observación inusualmente alejada del resto. Según la regla de Tukey: valor fuera del intervalo $[Q_1 - 1.5 \cdot IQR,\ Q_3 + 1.5 \cdot IQR]$. |
| **Valor p** | p-value | Probabilidad de obtener un estadístico de prueba tan extremo como el observado, asumiendo que $H_0$ es verdadera. |
| **Variable dependiente** | Dependent variable / Response variable | Variable que se quiere explicar o predecir en un modelo estadístico. También llamada variable respuesta. |
| **Variable independiente** | Independent variable / Predictor | Variable que se usa para explicar o predecir la variable dependiente. También llamada predictor o covariable. |
| **Vectorización** | Vectorization | Propiedad de R (y otros lenguajes) de aplicar operaciones a todos los elementos de un vector simultáneamente, sin bucles explícitos. |
