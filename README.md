# Estadística con R: Fundamentos y Aplicaciones

> Un libro práctico de estadística aplicada usando el lenguaje R, diseñado para estudiantes y profesionales que buscan dominar el análisis de datos desde los fundamentos hasta técnicas avanzadas.

---

## Contenido

| Capítulo | Tema | Estado |
|----------|------|--------|
| 1 | Estadística Descriptiva | En desarrollo |
| 2 | Probabilidad y Distribuciones | Pendiente |
| 3 | Inferencia Estadística | Pendiente |
| 4 | Regresión y Modelos | Pendiente |

---

## Estructura del Repositorio

```
.
├── README.md
├── capitulos/          # Contenido de cada capítulo en Markdown
│   ├── cap01_descriptiva.md
│   ├── cap02_probabilidad.md
│   ├── cap03_inferencia.md
│   └── cap04_regresion.md
├── data/               # Datasets en formato CSV
│   └── *.csv
├── scripts/            # Scripts R por capítulo
│   ├── cap01_descriptiva.R
│   ├── cap02_probabilidad.R
│   ├── cap03_inferencia.R
│   └── cap04_regresion.R
├── latex/              # Archivos fuente LaTeX
│   ├── main.tex
│   └── capitulos/
└── output/             # PDF compilado
    └── libro_estadistica_r.pdf
```

---

## Requisitos

### R y paquetes

```r
# R >= 4.2.0
install.packages(c(
  "tidyverse",   # Manipulación y visualización de datos
  "ggplot2",     # Gráficos avanzados
  "dplyr",       # Transformación de datos
  "readr",       # Importación de datos
  "broom",       # Modelos estadísticos ordenados
  "knitr",       # Generación de reportes
  "MASS",        # Funciones estadísticas clásicas
  "car"          # Regresión y diagnóstico
))
```

### LaTeX (para compilar el PDF)

- TeX Live >= 2022 (Linux/macOS) o MiKTeX (Windows)
- Paquetes: `babel`, `inputenc`, `geometry`, `listings`, `hyperref`, `booktabs`

---

## Compilar el libro en PDF

```bash
cd latex
pdflatex main.tex
pdflatex main.tex   # Segunda pasada para referencias cruzadas
```

El PDF resultante se guarda en `output/libro_estadistica_r.pdf`.

---

## Uso de los scripts R

Cada capítulo tiene su script R correspondiente. Ejecutar desde la raíz del proyecto:

```r
source("scripts/cap01_descriptiva.R")
```

Los datasets requeridos se encuentran en `data/` y los scripts los cargan con rutas relativas.

---

## Capítulos

### Capítulo 1 — Estadística Descriptiva
Medidas de tendencia central, dispersión, forma. Tablas de frecuencia y visualizaciones con `ggplot2`.

### Capítulo 2 — Probabilidad y Distribuciones
Fundamentos de probabilidad, distribuciones discretas y continuas, simulación en R.

### Capítulo 3 — Inferencia Estadística
Estimación puntual e intervalar, pruebas de hipótesis, errores tipo I y II, valor p.

### Capítulo 4 — Regresión y Modelos
Regresión lineal simple y múltiple, diagnóstico de modelos, interpretación de resultados.

---

## Convenciones del código R

- Estilo: [tidyverse style guide](https://style.tidyverse.org/)
- Nombres de variables: `snake_case`
- Cada script inicia con limpieza del entorno: `rm(list = ls())`
- Los gráficos se guardan en `output/` con `ggsave()`

---

## Licencia

Este trabajo está bajo la licencia [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

Puedes compartir y adaptar el material siempre que des crédito apropiado al autor.

---

## Autor

Desarrollado con R y escrito en LaTeX y Markdown.
Contribuciones y sugerencias son bienvenidas via [Issues](../../issues).
