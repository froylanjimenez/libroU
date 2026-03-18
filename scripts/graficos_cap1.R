# =============================================================================
# CAPÍTULO 1: Introducción a R
# Archivo: graficos_cap1.R
# Descripción: Visualizaciones sobre estructuras de datos y vectorización en R
# =============================================================================

rm(list = ls())
setwd("/home/froylan/Documents/Libro stat")

if(!require(ggplot2))   install.packages("ggplot2");   library(ggplot2)
if(!require(dplyr))     install.packages("dplyr");     library(dplyr)
if(!require(patchwork)) install.packages("patchwork"); library(patchwork)
if(!require(forcats))   install.packages("forcats");   library(forcats)
if(!require(viridis))   install.packages("viridis");   library(viridis)

# Rutas de salida
dir_out <- "output/figuras"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# Función auxiliar para guardar PNG + PDF
guardar_grafico <- function(p, nombre_base, ancho = 10, alto = 6) {
  ruta_png <- file.path(dir_out, paste0(nombre_base, ".png"))
  ruta_pdf <- file.path(dir_out, paste0(nombre_base, ".pdf"))

  ggsave(ruta_png, plot = p, width = ancho, height = alto, dpi = 300, units = "in")
  cat("✓ Guardado:", ruta_png, "\n")

  ggsave(ruta_pdf, plot = p, width = ancho, height = alto, units = "in",
         device = cairo_pdf)
  cat("✓ Guardado:", ruta_pdf, "\n")
}

# =============================================================================
# GRÁFICO 1: Estructuras de Datos Fundamentales en R
# fig_cap1_01_tipos_objetos.png / .pdf
# =============================================================================

# Construir datos manualmente
objeto     <- c("Vector", "Matriz", "Data Frame", "Lista", "Factor", "Función")
dimension  <- c("1D", "2D", "2D", "nD", "1D", "—")
uso_tipico <- c("Serie de valores", "Álgebra lineal", "Análisis de datos",
                "Contenedor mixto", "Variable categórica", "Reutilizar código")
complejidad <- c(1, 2, 3, 4, 2, 3)

df_objetos <- data.frame(
  objeto      = objeto,
  dimension   = dimension,
  uso_tipico  = uso_tipico,
  complejidad = complejidad,
  stringsAsFactors = FALSE
)

# Ordenar por complejidad usando fct_reorder
df_objetos <- df_objetos %>%
  mutate(objeto = fct_reorder(objeto, complejidad))

p1 <- ggplot(df_objetos, aes(x = complejidad, y = objeto, fill = complejidad)) +
  geom_col(width = 0.65, color = "white", linewidth = 0.3) +
  geom_text(
    aes(label = uso_tipico),
    x       = 0.08,
    hjust   = 0,
    color   = "white",
    size    = 3.3,
    fontface = "italic"
  ) +
  geom_text(
    aes(label = complejidad),
    hjust   = -0.4,
    color   = "#1A5276",
    size    = 4,
    fontface = "bold"
  ) +
  scale_fill_gradient(low = "#AED6F1", high = "#1A5276") +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.12)),
    breaks = 1:4
  ) +
  labs(
    title    = "Estructuras de Datos Fundamentales en R",
    subtitle = "Ordenadas por complejidad estructural",
    x        = "Nivel de Complejidad Relativa",
    y        = ""
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "none",
    plot.title         = element_text(face = "bold", size = 14),
    plot.subtitle      = element_text(color = "#555555"),
    axis.text.y        = element_text(size = 11, face = "bold")
  )

guardar_grafico(p1, "fig_cap1_01_tipos_objetos", ancho = 10, alto = 6)

# =============================================================================
# GRÁFICO 2: Vectorización en R con datos de Sierra Nevada
# fig_cap1_02_vectorizacion.png / .pdf
# =============================================================================

# Cargar datos reales
bio <- read.csv("data/biodiversidad_sierra.csv", stringsAsFactors = FALSE)

# Panel izquierdo: gradiente altitudinal calculado vectorialmente
alturas      <- seq(0, 5000, 100)
temp_gradiente <- 28.5 - (alturas / 1000) * 6.5
df_gradiente <- data.frame(altura = alturas, temperatura = temp_gradiente)

p_left <- ggplot() +
  geom_line(
    data  = df_gradiente,
    aes(x = altura, y = temperatura),
    color = "#E74C3C",
    linewidth = 1.1
  ) +
  geom_point(
    data  = bio,
    aes(x = altura_msnm, y = temperatura_C),
    color = "#2980B9",
    alpha = 0.4,
    size  = 1.8
  ) +
  labs(
    title = "Operación vectorial: T(h) = 28.5 − 6.5·(h/1000)",
    x     = "Altitud (m s.n.m.)",
    y     = "Temperatura (°C)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title   = element_text(face = "bold", size = 10),
    panel.grid.minor = element_blank()
  )

# Panel derecho: conteo de registros por zona_vida
# Ordenar zonas de vida aproximadamente por altitud (de menor a mayor)
orden_zonas <- c(
  "Bosque Seco Tropical",
  "Bosque Humedo Tropical",
  "Bosque Nublado",
  "Bosque Muy Humedo Montano",
  "Paramo"
)

df_conteo <- bio %>%
  count(zona_vida) %>%
  mutate(
    zona_vida = factor(zona_vida, levels = orden_zonas)
  ) %>%
  filter(!is.na(zona_vida))

p_right <- ggplot(df_conteo, aes(x = zona_vida, y = n, fill = zona_vida)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_text(
    aes(label = n),
    vjust  = -0.5,
    size   = 3.5,
    fontface = "bold"
  ) +
  scale_fill_viridis_d(option = "D", direction = -1) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(
    title = "Distribución de observaciones\npor zona de vida",
    x     = "Zona de Vida",
    y     = "Número de registros"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x      = element_text(angle = 35, hjust = 1, size = 8),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title       = element_text(face = "bold", size = 10)
  )

# Combinar con patchwork
p2 <- (p_left | p_right) +
  plot_annotation(
    title = "R aplicado a datos de la Sierra Nevada de Santa Marta",
    theme = theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
    )
  )

guardar_grafico(p2, "fig_cap1_02_vectorizacion", ancho = 10, alto = 6)

# =============================================================================
cat("=== Script completado. 2 gráficos generados. ===\n")
