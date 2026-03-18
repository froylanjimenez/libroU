# =============================================================================
# SCRIPT: graficos_cap2.R
# CAPÍTULO 2 — ESTADÍSTICA DESCRIPTIVA
# Libro: Estadística Aplicada con R — Colombia
# =============================================================================

rm(list = ls())
setwd("/home/froylan/Documents/Libro stat")
library(ggplot2)
library(dplyr)
library(tidyr)

# Instalar y cargar paquetes adicionales
if (!require(patchwork))  install.packages("patchwork",  repos = "https://cran.r-project.org")
if (!require(viridis))    install.packages("viridis",    repos = "https://cran.r-project.org")
if (!require(scales))     install.packages("scales",     repos = "https://cran.r-project.org")

library(patchwork)
library(viridis)
library(scales)

# -----------------------------------------------------------------------------
# Rutas
# -----------------------------------------------------------------------------
ruta_datos   <- "data/"
ruta_figuras <- "output/figuras/"
dir.create(ruta_figuras, showWarnings = FALSE, recursive = TRUE)

# Función auxiliar para guardar PNG + PDF
guardar_figura <- function(plot_obj, nombre_base, w = 10, h = 6) {
  ruta_png <- file.path(ruta_figuras, paste0(nombre_base, ".png"))
  ruta_pdf <- file.path(ruta_figuras, paste0(nombre_base, ".pdf"))

  ggsave(ruta_png, plot = plot_obj, width = w, height = h,
         dpi = 300, units = "in")
  ggsave(ruta_pdf, plot = plot_obj, width = w, height = h,
         device = cairo_pdf)

  cat("✓ Guardado:", paste0(nombre_base, ".png"), "\n")
  cat("✓ Guardado:", paste0(nombre_base, ".pdf"), "\n")
}

# -----------------------------------------------------------------------------
# Carga de datos
# -----------------------------------------------------------------------------
bio  <- read.csv(file.path(ruta_datos, "biodiversidad_sierra.csv"),
                 stringsAsFactors = FALSE)
palma <- read.csv(file.path(ruta_datos, "palma_cesar.csv"),
                  stringsAsFactors = FALSE)
logis <- read.csv(file.path(ruta_datos, "logistica_puerto_baq.csv"),
                  stringsAsFactors = FALSE)

cat("Datos cargados:\n")
cat("  biodiversidad_sierra :", nrow(bio),  "obs\n")
cat("  palma_cesar          :", nrow(palma),"obs\n")
cat("  logistica_puerto_baq :", nrow(logis),"obs\n\n")


# =============================================================================
# FIGURA 1 — Histograma de temperatura con curva de densidad
# =============================================================================
cat("Generando fig_cap2_01_histograma_temp...\n")

media_temp  <- mean(bio$temperatura_C, na.rm = TRUE)
mediana_temp <- median(bio$temperatura_C, na.rm = TRUE)
sd_temp     <- sd(bio$temperatura_C, na.rm = TRUE)
n_temp      <- sum(!is.na(bio$temperatura_C))

# Escalar densidad al eje de frecuencias (conteo)
binwidth <- (max(bio$temperatura_C) - min(bio$temperatura_C)) / 20

fig1 <- ggplot(bio, aes(x = temperatura_C)) +
  geom_histogram(aes(y = after_stat(count)),
                 binwidth = binwidth,
                 fill = "#4472C4", color = "white", alpha = 0.7) +
  geom_density(aes(y = after_stat(density) * n_temp * binwidth),
               color = "#8B0000", linewidth = 1.2, linetype = "solid") +
  geom_vline(aes(xintercept = media_temp,   color = "Media"),
             linewidth = 1.0, linetype = "solid") +
  geom_vline(aes(xintercept = mediana_temp, color = "Mediana"),
             linewidth = 1.0, linetype = "dashed") +
  scale_color_manual(
    name   = "Estadístico",
    values = c("Media" = "#E63946", "Mediana" = "#2D6A4F")
  ) +
  annotate("text",
           x     = max(bio$temperatura_C) * 0.93,
           y     = Inf,
           vjust = 1.5,
           hjust = 1,
           size  = 3.8,
           label = paste0("Media = ", round(media_temp, 2),
                          " °C\nDE = ",   round(sd_temp, 2),
                          " °C\nn = ",    n_temp)) +
  labs(
    title    = "Distribución de Temperatura en la Sierra Nevada de Santa Marta",
    subtitle = "Histograma con curva de densidad suavizada",
    x        = "Temperatura (°C)",
    y        = "Frecuencia"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    legend.box    = "horizontal"
  )

guardar_figura(fig1, "fig_cap2_01_histograma_temp")


# =============================================================================
# FIGURA 2 — Boxplot de toneladas_ha por variedad de palma
# =============================================================================
cat("Generando fig_cap2_02_boxplot_variedades...\n")

colores_variedades <- c("Dura"   = "#2E86AB",
                        "Pisifera" = "#A23B72",
                        "Tenera" = "#F18F01")

fig2 <- ggplot(palma, aes(x = variedad, y = toneladas_ha, fill = variedad)) +
  geom_boxplot(alpha = 0.8, outlier.shape = NA, width = 0.5) +
  geom_jitter(alpha = 0.3, width = 0.2, size = 1.5, color = "grey30") +
  stat_summary(fun  = mean, geom = "point",
               shape = 23, size = 3, fill = "white", color = "black") +
  geom_hline(aes(yintercept = 16, linetype = "Promedio nacional (16 t/ha)"),
             color = "black", linewidth = 0.8) +
  scale_fill_manual(values = colores_variedades, name = "Variedad") +
  scale_linetype_manual(name   = "Referencia",
                        values = c("Promedio nacional (16 t/ha)" = "dashed")) +
  labs(
    title    = "Productividad por Variedad de Palma de Aceite — Cesar, Colombia",
    subtitle = "Puntos blancos: media aritmética  |  Diamante: valores individuales",
    x        = "Variedad",
    y        = "Toneladas por Hectárea (RFF)"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    legend.box      = "vertical"
  )

guardar_figura(fig2, "fig_cap2_02_boxplot_variedades")


# =============================================================================
# FIGURA 3 — Dispersión altitud vs temperatura con regresión
# =============================================================================
cat("Generando fig_cap2_03_dispersion_altitud_temp...\n")

modelo_lm <- lm(temperatura_C ~ altura_msnm, data = bio)
r2_val    <- summary(modelo_lm)$r.squared
coef_b0   <- coef(modelo_lm)[1]
coef_b1   <- coef(modelo_lm)[2]

ecuacion_label <- paste0(
  "y = ", round(coef_b0, 3),
  ifelse(coef_b1 >= 0, " + ", " - "),
  round(abs(coef_b1), 5), "x",
  "\nR² = ", round(r2_val, 4)
)

fig3 <- ggplot(bio, aes(x = altura_msnm, y = temperatura_C,
                         color = zona_vida)) +
  geom_point(alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", color = "black",
              linetype = "dashed", se = TRUE,
              linewidth = 1.0, inherit.aes = FALSE,
              aes(x = altura_msnm, y = temperatura_C)) +
  scale_color_viridis_d(name = "Zona de vida", option = "D") +
  annotate("label",
           x     = max(bio$altura_msnm, na.rm = TRUE) * 0.75,
           y     = max(bio$temperatura_C, na.rm = TRUE) * 0.97,
           label = ecuacion_label,
           size  = 3.8,
           fill  = "white",
           color = "black",
           label.size = 0.3) +
  labs(
    title    = "Gradiente Altitudinal de Temperatura — Sierra Nevada de Santa Marta",
    subtitle = "Regresión lineal simple con intervalo de confianza al 95%",
    x        = "Altitud (m s.n.m.)",
    y        = "Temperatura (°C)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    legend.box      = "horizontal",
    legend.text     = element_text(size = 9)
  )

guardar_figura(fig3, "fig_cap2_03_dispersion_altitud_temp")


# =============================================================================
# FIGURA 4 — Panel de 4 distribuciones comparadas
# =============================================================================
cat("Generando fig_cap2_04_distribuciones_comparadas...\n")

# Panel 1: densidad temperatura_C por zona_vida
p1 <- ggplot(bio, aes(x = temperatura_C, fill = zona_vida)) +
  geom_density(alpha = 0.4, color = "grey40") +
  scale_fill_viridis_d(option = "D") +
  labs(title    = "Temperatura (°C) por Zona de Vida",
       x        = "Temperatura (°C)",
       y        = "Densidad",
       fill     = "Zona de vida") +
  theme_light(base_size = 10) +
  theme(legend.position = "bottom",
        legend.text     = element_text(size = 7),
        plot.title      = element_text(face = "bold", size = 10))

# Panel 2: densidad humedad_relativa por zona_vida
p2 <- ggplot(bio, aes(x = humedad_relativa, fill = zona_vida)) +
  geom_density(alpha = 0.4, color = "grey40") +
  scale_fill_viridis_d(option = "D") +
  labs(title    = "Humedad Relativa (%) por Zona de Vida",
       x        = "Humedad relativa (%)",
       y        = "Densidad",
       fill     = "Zona de vida") +
  theme_light(base_size = 10) +
  theme(legend.position = "bottom",
        legend.text     = element_text(size = 7),
        plot.title      = element_text(face = "bold", size = 10))

# Panel 3: densidad toneladas_ha por variedad
p3 <- ggplot(palma, aes(x = toneladas_ha, fill = variedad)) +
  geom_density(alpha = 0.4, color = "grey40") +
  scale_fill_manual(values = c("Dura" = "#2E86AB",
                               "Pisifera" = "#A23B72",
                               "Tenera" = "#F18F01")) +
  labs(title    = "Productividad (t/ha) por Variedad de Palma",
       x        = "Toneladas por hectárea",
       y        = "Densidad",
       fill     = "Variedad") +
  theme_light(base_size = 10) +
  theme(legend.position = "bottom",
        plot.title      = element_text(face = "bold", size = 10))

# Panel 4: densidad eficiencia_porcentaje por tipo_carga
p4 <- ggplot(logis, aes(x = eficiencia_porcentaje, fill = tipo_carga)) +
  geom_density(alpha = 0.4, color = "grey40") +
  scale_fill_manual(values = c("Contenedor"     = "#457B9D",
                               "Granel Liquido" = "#E9C46A",
                               "Granel Solido"  = "#E76F51",
                               "Carga General"  = "#2A9D8F")) +
  labs(title    = "Eficiencia (%) por Tipo de Carga — Puerto de Barranquilla",
       x        = "Eficiencia (%)",
       y        = "Densidad",
       fill     = "Tipo de carga") +
  theme_light(base_size = 10) +
  theme(legend.position = "bottom",
        legend.text     = element_text(size = 7),
        plot.title      = element_text(face = "bold", size = 10))

fig4 <- (p1 + p2) / (p3 + p4) +
  plot_annotation(
    title   = "Distribuciones de Variables Clave por Grupo",
    subtitle = "Estimación de densidad kernel (KDE) — tres conjuntos de datos",
    theme   = theme(
      plot.title    = element_text(face = "bold", size = 14, hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
    )
  )

guardar_figura(fig4, "fig_cap2_04_distribuciones_comparadas", w = 12, h = 9)


# =============================================================================
# FIGURA 5 — Medidas de tendencia central (barras horizontales)
# =============================================================================
cat("Generando fig_cap2_05_medidas_tendencia...\n")

n_palma        <- nrow(palma)
media_ton      <- mean(palma$toneladas_ha, na.rm = TRUE)
mediana_ton    <- median(palma$toneladas_ha, na.rm = TRUE)
media_rec_ton  <- mean(palma$toneladas_ha, na.rm = TRUE, trim = 0.10)

# Moda aproximada: valor con mayor densidad
dens_palma <- density(palma$toneladas_ha, na.rm = TRUE)
moda_ton   <- dens_palma$x[which.max(dens_palma$y)]

df_medidas <- data.frame(
  medida = factor(
    c("Media aritmética", "Mediana", "Moda (densidad máx.)", "Media recortada 10%"),
    levels = c("Media recortada 10%", "Moda (densidad máx.)", "Mediana", "Media aritmética")
  ),
  valor = c(media_ton, mediana_ton, moda_ton, media_rec_ton),
  descripcion = c(
    paste0("x̄ = ", round(media_ton, 3)),
    paste0("Md = ", round(mediana_ton, 3)),
    paste0("Mo ≈ ", round(moda_ton, 3)),
    paste0("x̄₁₀% = ", round(media_rec_ton, 3))
  )
)

colores_medidas <- c(
  "Media aritmética"       = "#4472C4",
  "Mediana"                = "#2E86AB",
  "Moda (densidad máx.)"   = "#A23B72",
  "Media recortada 10%"    = "#F18F01"
)

fig5 <- ggplot(df_medidas, aes(x = valor, y = medida, fill = medida)) +
  geom_col(width = 0.55, alpha = 0.85) +
  geom_text(aes(label = descripcion),
            hjust = -0.08, size = 4.2, fontface = "bold") +
  scale_fill_manual(values = colores_medidas, guide = "none") +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.20)),
    limits = c(0, max(df_medidas$valor) * 1.25)
  ) +
  labs(
    title    = "Medidas de Tendencia Central — Productividad Palmera (ton/ha)",
    subtitle = paste0("n = ", n_palma,
                      " parcelas  |  Media: promedio aritmético  |  Mediana: valor central  ",
                      "|  Moda: densidad máxima  |  Media rec.: elimina 10% extremos"),
    x        = "Toneladas por Hectárea (RFF)",
    y        = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 9, color = "grey40"),
    axis.text.y   = element_text(size = 11, face = "bold"),
    panel.grid.major.y = element_blank()
  )

guardar_figura(fig5, "fig_cap2_05_medidas_tendencia")


# =============================================================================
cat("\n=== Script completado. 5 gráficos generados. ===\n")
