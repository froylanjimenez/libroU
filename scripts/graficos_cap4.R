# =============================================================================
# CAPÍTULO 4: ggplot2 Avanzado — Construcción progresiva por capas
# Archivo: graficos_cap4.R
# Descripción: 8 gráficos que ilustran el sistema de capas de ggplot2
# =============================================================================

rm(list = ls())
set.seed(42)
setwd("/home/froylan/Documents/Libro stat")

if(!require(ggplot2))   install.packages("ggplot2");   library(ggplot2)
if(!require(dplyr))     install.packages("dplyr");     library(dplyr)
if(!require(patchwork)) install.packages("patchwork"); library(patchwork)
if(!require(viridis))   install.packages("viridis");   library(viridis)
if(!require(forcats))   install.packages("forcats");   library(forcats)

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
# Cargar datos
# =============================================================================

palma <- read.csv("data/palma_cesar.csv",          stringsAsFactors = FALSE)
bio   <- read.csv("data/biodiversidad_sierra.csv", stringsAsFactors = FALSE)
log_  <- read.csv("data/logistica_puerto_baq.csv", stringsAsFactors = FALSE)

# Parsear fecha en logística
log_$fecha <- as.Date(log_$fecha)

# =============================================================================
# GRÁFICO 1: Capa base — canvas vacío
# fig_cap4_01_capa_base.png / .pdf  (4×4 in)
# =============================================================================

p_base <- ggplot(palma, aes(x = fertilizante_kg, y = toneladas_ha))

p01 <- p_base +
  labs(
    title    = "Capa 1: Canvas (ggplot + aes)",
    subtitle = "Solo define datos y estéticas — sin geometría visible",
    x        = "Fertilizante (kg/ha)",
    y        = "Productividad (ton/ha)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

guardar_grafico(p01, "fig_cap4_01_capa_base", ancho = 4, alto = 4)

# =============================================================================
# GRÁFICO 2: + geom_point
# fig_cap4_02_capa_puntos.png / .pdf  (4×4 in)
# =============================================================================

p02 <- p_base +
  geom_point(alpha = 0.6, color = "#2E86AB", size = 2.5) +
  labs(
    title    = "Capa 2: + geom_point()",
    subtitle = "Agrega puntos — cada finca palmera del Cesar",
    x        = "Fertilizante (kg/ha)",
    y        = "Productividad (ton/ha)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

guardar_grafico(p02, "fig_cap4_02_capa_puntos", ancho = 4, alto = 4)

# =============================================================================
# GRÁFICO 3: + geom_smooth
# fig_cap4_03_capa_smooth.png / .pdf  (4×4 in)
# =============================================================================

p03 <- p_base +
  geom_point(alpha = 0.6, color = "#2E86AB", size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "#E63946") +
  labs(
    title    = "Capa 3: + geom_smooth(method='lm')",
    subtitle = "Agrega línea de tendencia con banda de confianza",
    x        = "Fertilizante (kg/ha)",
    y        = "Productividad (ton/ha)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

guardar_grafico(p03, "fig_cap4_03_capa_smooth", ancho = 4, alto = 4)

# =============================================================================
# GRÁFICO 4: + color por variedad
# fig_cap4_04_capa_color.png / .pdf  (5×4 in)
# =============================================================================

p04 <- p_base +
  geom_point(aes(color = variedad), alpha = 0.6, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "#E63946") +
  scale_color_manual(values = c("#2E86AB", "#A23B72", "#F18F01")) +
  labs(
    title    = "Capa 4: + color por grupo",
    subtitle = "Variedad como estética color",
    x        = "Fertilizante (kg/ha)",
    y        = "Productividad (ton/ha)",
    color    = "Variedad"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

guardar_grafico(p04, "fig_cap4_04_capa_color", ancho = 5, alto = 4)

# =============================================================================
# GRÁFICO 5: facet_wrap — gradiente altitudinal por zona de vida
# fig_cap4_05_facet_wrap.png / .pdf  (8×6 in)
# =============================================================================

p05 <- ggplot(bio, aes(x = altura_msnm, y = temperatura_C,
                       color = humedad_relativa)) +
  geom_point(alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.7) +
  facet_wrap(~ zona_vida, ncol = 3, scales = "free_x") +
  scale_color_viridis_c(name = "Humedad (%)", option = "plasma") +
  labs(
    title    = "facet_wrap: Gradiente altitudinal por zona de vida",
    subtitle = "Cada panel = una zona de vida; escala libre en eje x",
    x        = "Altitud (m s.n.m.)",
    y        = "Temperatura (°C)"
  ) +
  theme_light(base_size = 10) +
  theme(
    strip.background = element_rect(fill = "#2C3E50", color = NA),
    strip.text       = element_text(color = "white", face = "bold", size = 9),
    plot.title       = element_text(face = "bold"),
    legend.position  = "right"
  )

guardar_grafico(p05, "fig_cap4_05_facet_wrap", ancho = 8, alto = 6)

# =============================================================================
# GRÁFICO 6: facet_grid — eficiencia por tipo de carga y semestre
# fig_cap4_06_facet_grid.png / .pdf  (9×7 in)
# =============================================================================

log_ <- log_ %>%
  mutate(
    mes       = format(fecha, "%b"),
    semestre  = ifelse(mes %in% c("Jan", "Feb", "Mar", "Apr", "May", "Jun"),
                       "S1", "S2"),
    efic_cat  = cut(
      eficiencia_porcentaje,
      breaks = c(0, 65, 80, 100),
      labels = c("Baja", "Media", "Alta"),
      include.lowest = TRUE
    )
  )

p06 <- ggplot(log_, aes(x = efic_cat, fill = efic_cat)) +
  geom_bar(stat = "count") +
  facet_grid(semestre ~ tipo_carga, scales = "free_y") +
  scale_fill_manual(values = c("Baja" = "#E63946",
                                "Media" = "#457B9D",
                                "Alta"  = "#2D6A4F")) +
  labs(
    title    = "facet_grid: Categorías de eficiencia por tipo de carga y semestre",
    subtitle = "Filas = semestre; Columnas = tipo de carga",
    x        = "",
    y        = "Número de operaciones",
    fill     = "Eficiencia"
  ) +
  theme_minimal(base_size = 9) +
  theme(
    axis.text.x      = element_blank(),
    axis.ticks.x     = element_blank(),
    strip.text.x     = element_text(angle = 0, face = "bold", size = 8),
    strip.text.y     = element_text(face = "bold"),
    strip.background = element_rect(fill = "#ECF0F1", color = "#BDC3C7"),
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

guardar_grafico(p06, "fig_cap4_06_facet_grid", ancho = 9, alto = 7)

# =============================================================================
# GRÁFICO 7: Comparación de temas (2×2 con patchwork)
# fig_cap4_07_temas_comparados.png / .pdf  (10×8 in)
# =============================================================================

# Boxplot base: toneladas_ha por variedad
p_box_base <- ggplot(palma, aes(x = variedad, y = toneladas_ha, fill = variedad)) +
  geom_boxplot(alpha = 0.8, outlier.size = 1.5) +
  scale_fill_manual(values = c("#2E86AB", "#A23B72", "#F18F01")) +
  labs(x = "Variedad", y = "ton/ha") +
  theme(legend.position = "none")

# Tema personalizado
tema_custom <- theme(
  plot.background   = element_rect(fill = "#F8F9FA", color = NA),
  panel.background  = element_rect(fill = "#F8F9FA", color = NA),
  panel.grid.major  = element_line(color = "#E9ECEF"),
  panel.grid.minor  = element_blank(),
  axis.text         = element_text(color = "#2C3E50"),
  axis.title        = element_text(color = "#2C3E50", face = "bold"),
  plot.title        = element_text(color = "#2C3E50", face = "bold"),
  legend.position   = "none"
)

p_gray    <- p_box_base + theme_gray(base_size = 10)    + labs(title = "theme_gray()") +
  theme(legend.position = "none")
p_minimal <- p_box_base + theme_minimal(base_size = 10) + labs(title = "theme_minimal()") +
  theme(legend.position = "none")
p_classic <- p_box_base + theme_classic(base_size = 10) + labs(title = "theme_classic()") +
  theme(legend.position = "none")
p_custom  <- p_box_base + theme_minimal(base_size = 10) + tema_custom +
  labs(title = "Tema personalizado") +
  theme(legend.position = "none")

p07 <- (p_gray | p_minimal) / (p_classic | p_custom) +
  plot_annotation(
    title = "Personalización de Temas en ggplot2",
    theme = theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
    )
  )

guardar_grafico(p07, "fig_cap4_07_temas_comparados", ancho = 10, alto = 8)

# =============================================================================
# GRÁFICO 8: Gráfico complejo final — gradiente térmico altitudinal
# fig_cap4_08_grafico_complejo.png / .pdf  (11×7 in)
# =============================================================================

# Etiqueta de anotación para el gradiente adiabático estándar
anotacion_texto <- "Gradiente adiabático\nestándar: −6.5 °C / 1000 m"

p08 <- ggplot(bio, aes(x = altura_msnm, y = temperatura_C,
                       color = zona_vida, size = humedad_relativa)) +
  geom_point(alpha = 0.7) +
  geom_smooth(aes(group = zona_vida, color = zona_vida),
              method = "lm", se = FALSE, linewidth = 0.8, alpha = 0.8,
              show.legend = FALSE) +
  annotate(
    "label",
    x        = 4200,
    y        = 26,
    label    = anotacion_texto,
    size     = 3.2,
    color    = "#2C3E50",
    fill     = "#FDFEFE",
    fontface = "italic"
  ) +
  scale_color_viridis_d(option = "D", name = "Zona de Vida") +
  scale_size_continuous(
    range = c(1, 4),
    name  = "Humedad (%)"
  ) +
  guides(
    color = guide_legend(nrow = 2, override.aes = list(size = 3)),
    size  = guide_legend(nrow = 1)
  ) +
  labs(
    title    = "Gradiente Térmico Altitudinal por Zona de Vida",
    subtitle = "Sierra Nevada de Santa Marta — Cada punto representa una parcela de muestreo",
    caption  = "Datos: Proyecto Estadística con R | Líneas: regresión lineal por zona",
    x        = "Altitud (m s.n.m.)",
    y        = "Temperatura (°C)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position  = "bottom",
    legend.box       = "horizontal",
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(color = "#555555"),
    plot.caption     = element_text(color = "#888888", size = 8),
    panel.grid.minor = element_blank()
  )

guardar_grafico(p08, "fig_cap4_08_grafico_complejo", ancho = 11, alto = 7)

# =============================================================================
cat("=== Script completado. 8 gráficos generados. ===\n")
