# =============================================================================
# SCRIPT: graficos_cap3.R
# CAPÍTULO 3 — INFERENCIA ESTADÍSTICA
# Libro: Estadística Aplicada con R — Colombia
# =============================================================================

rm(list = ls())
setwd("/home/froylan/Documents/Libro stat")
library(ggplot2)
library(dplyr)
library(tidyr)

# Instalar y cargar paquetes adicionales
if (!require(patchwork)) install.packages("patchwork", repos = "https://cran.r-project.org")
if (!require(scales))    install.packages("scales",    repos = "https://cran.r-project.org")

library(patchwork)
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
bio   <- read.csv(file.path(ruta_datos, "biodiversidad_sierra.csv"),
                  stringsAsFactors = FALSE)
palma <- read.csv(file.path(ruta_datos, "palma_cesar.csv"),
                  stringsAsFactors = FALSE)
logis <- read.csv(file.path(ruta_datos, "logistica_puerto_baq.csv"),
                  stringsAsFactors = FALSE)

cat("Datos cargados:\n")
cat("  biodiversidad_sierra :", nrow(bio),   "obs\n")
cat("  palma_cesar          :", nrow(palma), "obs\n")
cat("  logistica_puerto_baq :", nrow(logis), "obs\n\n")


# =============================================================================
# FIGURA 1 — Distribución normal estándar con regiones de rechazo
# =============================================================================
cat("Generando fig_cap3_01_normal_areas...\n")

z_critico <- 1.96
x_seq     <- seq(-4, 4, length.out = 1000)

df_normal <- data.frame(x = x_seq, y = dnorm(x_seq))

# Data frames para las áreas sombreadas
df_rechazo_izq <- data.frame(
  x = seq(-4, -z_critico, length.out = 300),
  y = dnorm(seq(-4, -z_critico, length.out = 300))
)
df_rechazo_der <- data.frame(
  x = seq(z_critico, 4, length.out = 300),
  y = dnorm(seq(z_critico, 4, length.out = 300))
)
df_norechazo <- data.frame(
  x = seq(-z_critico, z_critico, length.out = 600),
  y = dnorm(seq(-z_critico, z_critico, length.out = 600))
)

fig1 <- ggplot(df_normal, aes(x = x, y = y)) +
  # Área de no rechazo (azul claro)
  geom_ribbon(data = df_norechazo,
              aes(x = x, ymin = 0, ymax = y),
              fill = "#AEC6CF", alpha = 0.35, inherit.aes = FALSE) +
  # Áreas de rechazo (rojo)
  geom_ribbon(data = df_rechazo_izq,
              aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.45, inherit.aes = FALSE) +
  geom_ribbon(data = df_rechazo_der,
              aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.45, inherit.aes = FALSE) +
  # Curva normal
  geom_line(linewidth = 1.1, color = "black") +
  # Líneas verticales críticas
  geom_vline(xintercept = c(-z_critico, z_critico),
             linetype = "dashed", color = "#E63946", linewidth = 0.9) +
  # Etiquetas de los valores críticos
  annotate("text", x = -z_critico, y = -0.008, label = "-1.96",
           size = 3.8, color = "#E63946", fontface = "bold") +
  annotate("text", x =  z_critico, y = -0.008, label = "+1.96",
           size = 3.8, color = "#E63946", fontface = "bold") +
  # Etiquetas de áreas
  annotate("text", x = -3.0, y = 0.025,
           label = "α/2 = 0.025\nRechazo H₀",
           size = 3.5, color = "#C0392B", fontface = "bold",
           hjust = 0.5) +
  annotate("text", x =  3.0, y = 0.025,
           label = "α/2 = 0.025\nRechazo H₀",
           size = 3.5, color = "#C0392B", fontface = "bold",
           hjust = 0.5) +
  annotate("text", x = 0, y = 0.17,
           label = "1 − α = 0.95\nNo se rechaza H₀",
           size = 4.0, color = "#1A5276", fontface = "bold",
           hjust = 0.5) +
  scale_x_continuous(breaks = c(-4, -3, -2, -1.96, -1, 0, 1, 1.96, 2, 3, 4),
                     labels = c("-4", "-3", "-2", "-1.96", "-1", "0",
                                "1", "1.96", "2", "3", "4")) +
  labs(
    title    = "Distribución Normal Estándar — Regiones de Rechazo (α = 0.05)",
    subtitle = "Prueba bilateral: se rechaza H₀ si |z| > 1.96",
    x        = "z",
    y        = "Densidad  f(z)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title  = element_text(face = "bold", size = 13),
    axis.text.x = element_text(size = 9)
  )

guardar_figura(fig1, "fig_cap3_01_normal_areas")


# =============================================================================
# FIGURA 2 — Distribución t de Student vs Normal estándar
# =============================================================================
cat("Generando fig_cap3_02_t_vs_normal...\n")

x_t <- seq(-5, 5, length.out = 1000)

grados <- c(1, 5, 10, 30)
etiquetas <- c("t (ν = 1)", "t (ν = 5)", "t (ν = 10)", "t (ν = 30)")

df_t <- do.call(rbind, lapply(seq_along(grados), function(i) {
  data.frame(
    x         = x_t,
    y         = dt(x_t, df = grados[i]),
    distribucion = etiquetas[i]
  )
}))

df_normal2 <- data.frame(
  x            = x_t,
  y            = dnorm(x_t),
  distribucion = "Normal N(0,1)"
)

df_todas <- rbind(df_t, df_normal2)

colores_t <- c(
  "t (ν = 1)"    = "#E63946",
  "t (ν = 5)"    = "#F4A261",
  "t (ν = 10)"   = "#2A9D8F",
  "t (ν = 30)"   = "#457B9D",
  "Normal N(0,1)" = "#1D3557"
)

tipos_linea <- c(
  "t (ν = 1)"    = "dotted",
  "t (ν = 5)"    = "dotdash",
  "t (ν = 10)"   = "dashed",
  "t (ν = 30)"   = "longdash",
  "Normal N(0,1)" = "solid"
)

df_todas$distribucion <- factor(df_todas$distribucion,
                                 levels = c("t (ν = 1)", "t (ν = 5)",
                                            "t (ν = 10)", "t (ν = 30)",
                                            "Normal N(0,1)"))

fig2 <- ggplot(df_todas, aes(x = x, y = y,
                              color    = distribucion,
                              linetype = distribucion)) +
  geom_line(linewidth = 0.95) +
  scale_color_manual(values = colores_t,    name = "Distribución") +
  scale_linetype_manual(values = tipos_linea, name = "Distribución") +
  annotate("text", x = 3.5, y = 0.08,
           label = "Colas más\npesadas (ν pequeño)",
           size = 3.5, color = "#E63946", fontface = "italic",
           hjust = 0) +
  annotate("segment", x = 3.3, xend = 2.8, y = 0.07, yend = 0.04,
           arrow = arrow(length = unit(0.2, "cm")),
           color = "#E63946") +
  labs(
    title    = "Distribución t de Student vs Normal Estándar",
    subtitle = "Las colas de t son más pesadas para muestras pequeñas",
    x        = "t",
    y        = "Densidad  f(t)"
  ) +
  coord_cartesian(xlim = c(-5, 5), ylim = c(0, 0.42)) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "right"
  )

guardar_figura(fig2, "fig_cap3_02_t_vs_normal")


# =============================================================================
# FIGURA 3 — Simulación de 30 intervalos de confianza al 95%
# =============================================================================
cat("Generando fig_cap3_03_intervalos_confianza...\n")

set.seed(303)
mu_real <- mean(bio$temperatura_C, na.rm = TRUE)  # media poblacional verdadera
n_muestra  <- 25
n_sims     <- 30

resultados_ic <- do.call(rbind, lapply(1:n_sims, function(i) {
  muestra  <- sample(bio$temperatura_C[!is.na(bio$temperatura_C)],
                     size = n_muestra, replace = TRUE)
  test_res <- t.test(muestra, conf.level = 0.95)
  data.frame(
    muestra_id = i,
    media_m    = mean(muestra),
    lci        = test_res$conf.int[1],
    lcs        = test_res$conf.int[2]
  )
}))

resultados_ic$contiene_mu <- (resultados_ic$lci <= mu_real) &
                              (resultados_ic$lcs >= mu_real)
resultados_ic$color_ic    <- ifelse(resultados_ic$contiene_mu, "Contiene μ", "No contiene μ")

no_contiene <- sum(!resultados_ic$contiene_mu)

fig3 <- ggplot(resultados_ic, aes(y = muestra_id, color = color_ic)) +
  geom_segment(aes(x = lci, xend = lcs,
                   y = muestra_id, yend = muestra_id),
               linewidth = 1.0) +
  geom_point(aes(x = media_m), size = 2.5, shape = 16) +
  geom_vline(xintercept = mu_real,
             linetype = "dashed", color = "black", linewidth = 1.0) +
  annotate("text",
           x     = mu_real + 0.05,
           y     = n_sims + 0.7,
           label = paste0("μ real = ", round(mu_real, 2), " °C"),
           size  = 3.8, hjust = 0, fontface = "bold") +
  scale_color_manual(
    values = c("Contiene μ" = "#457B9D", "No contiene μ" = "#E63946"),
    name   = "Intervalo"
  ) +
  scale_y_continuous(breaks = 1:n_sims) +
  labs(
    title    = "Simulación de 30 Intervalos de Confianza al 95%",
    subtitle = paste0("En promedio, 1-2 de cada 30 no contienen el parámetro verdadero",
                      "  |  En esta simulación: ", no_contiene,
                      " IC no contienen μ"),
    x        = "Temperatura (°C)",
    y        = "Muestra #"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

guardar_figura(fig3, "fig_cap3_03_intervalos_confianza", w = 10, h = 8)


# =============================================================================
# FIGURA 4 — Valor p en la distribución t
# =============================================================================
cat("Generando fig_cap3_04_pvalor...\n")

# Prueba t real: H0: mu_temp = 15
mu_h0    <- 15
test_h0  <- t.test(bio$temperatura_C, mu = mu_h0, alternative = "two.sided")
t_obs    <- as.numeric(test_h0$statistic)
df_test  <- as.numeric(test_h0$parameter)
p_val    <- test_h0$p.value

# Construir curva t
x_t2 <- seq(-max(abs(t_obs) * 1.5, 4), max(abs(t_obs) * 1.5, 4),
             length.out = 1200)
df_t2 <- data.frame(x = x_t2, y = dt(x_t2, df = df_test))

# Áreas del p-valor (cola bilateral)
t_abs <- abs(t_obs)
df_pval_der <- data.frame(
  x = seq( t_abs, max(x_t2), length.out = 400),
  y = dt(seq( t_abs, max(x_t2), length.out = 400), df = df_test)
)
df_pval_izq <- data.frame(
  x = seq(min(x_t2), -t_abs, length.out = 400),
  y = dt(seq(min(x_t2), -t_abs, length.out = 400), df = df_test)
)

subtitulo_dinamico <- paste0(
  "H₀: μ = 15°C  vs  H₁: μ ≠ 15°C  |  ",
  "t_obs = ", round(t_obs, 3),
  "  |  p-valor = ", formatC(p_val, format = "e", digits = 3),
  if (p_val < 0.05) "  →  Se rechaza H₀ (α = 0.05)"
  else "  →  No se rechaza H₀ (α = 0.05)"
)

fig4 <- ggplot(df_t2, aes(x = x, y = y)) +
  geom_ribbon(data = df_pval_izq,
              aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_ribbon(data = df_pval_der,
              aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_line(linewidth = 1.1, color = "black") +
  geom_vline(xintercept =  t_obs, linetype = "dashed",
             color = "#E63946", linewidth = 1.0) +
  geom_vline(xintercept = -t_obs, linetype = "dashed",
             color = "#E63946", linewidth = 1.0) +
  annotate("text",
           x     = t_obs,
           y     = dt(0, df = df_test) * 0.55,
           label = paste0("t_obs = ", round(t_obs, 2)),
           size  = 3.8, hjust = -0.08, color = "#C0392B", fontface = "bold") +
  annotate("text",
           x     = sign(t_obs) * (t_abs + (max(x_t2) - t_abs) / 2),
           y     = dt(t_abs, df = df_test) / 2,
           label = paste0("p/2 =\n", formatC(p_val / 2, format = "e", digits = 2)),
           size  = 3.2, color = "#C0392B", fontface = "bold", hjust = 0.5) +
  labs(
    title    = "Valor p — Prueba t:  H₀: μ_temperatura = 15°C",
    subtitle = subtitulo_dinamico,
    x        = "Estadístico t",
    y        = "Densidad"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 9, color = "grey30")
  )

guardar_figura(fig4, "fig_cap3_04_pvalor")


# =============================================================================
# FIGURA 5 — Panel Q-Q plots (2x2)
# =============================================================================
cat("Generando fig_cap3_05_qqplot_comparado...\n")

# Función para construir un Q-Q plot con ggplot2 y resultado Shapiro-Wilk
make_qqplot <- function(datos, titulo, transformar_log = FALSE) {
  y <- datos[!is.na(datos)]
  if (transformar_log) {
    y <- log(y[y > 0])
    titulo <- paste0(titulo, " [log-transformado]")
  }

  sw_test   <- shapiro.test(y)
  sw_label  <- paste0("Shapiro-Wilk: W = ", round(sw_test$statistic, 4),
                      "\np-valor = ", formatC(sw_test$p.value, format = "e", digits = 3),
                      if (sw_test$p.value > 0.05) "\n→ No se rechaza normalidad (α=0.05)"
                      else "\n→ Se rechaza normalidad (α=0.05)")

  df_qq <- data.frame(y = y)

  ggplot(df_qq, aes(sample = y)) +
    stat_qq(color = "#1B4F72", alpha = 0.7, size = 1.8) +
    stat_qq_line(color = "#E63946", linewidth = 0.9, linetype = "solid") +
    annotate("label",
             x     = -Inf, y = Inf,
             hjust = -0.05, vjust = 1.3,
             label = sw_label,
             size  = 2.8, fill = "white",
             color = ifelse(sw_test$p.value > 0.05, "#1A5276", "#C0392B"),
             label.size = 0.2) +
    labs(title    = titulo,
         x        = "Cuantiles teóricos N(0,1)",
         y        = "Cuantiles de la muestra") +
    theme_light(base_size = 10) +
    theme(plot.title = element_text(face = "bold", size = 9.5))
}

qq1 <- make_qqplot(bio$temperatura_C,        "temperatura_C (Sierra Nevada)")
qq2 <- make_qqplot(palma$toneladas_ha,        "toneladas_ha (Palma de Aceite)")
qq3 <- make_qqplot(logis$eficiencia_porcentaje, "eficiencia_porcentaje (Puerto Baq.)")
qq4 <- make_qqplot(palma$toneladas_ha,        "toneladas_ha", transformar_log = TRUE)

fig5 <- (qq1 + qq2) / (qq3 + qq4) +
  plot_annotation(
    title   = "Gráficos Q-Q: Verificación de Normalidad",
    subtitle = "Puntos sobre la línea roja indican distribución aproximadamente normal",
    theme   = theme(
      plot.title    = element_text(face = "bold", size = 14, hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
    )
  )

guardar_figura(fig5, "fig_cap3_05_qqplot_comparado", w = 11, h = 9)


# =============================================================================
# FIGURA 6 — Curva de potencia estadística
# =============================================================================
cat("Generando fig_cap3_06_potencia...\n")

n_vec    <- 5:150
efectos  <- c(0.2, 0.5, 0.8)
etiq_ef  <- c("d = 0.2 (pequeño)", "d = 0.5 (mediano)", "d = 0.8 (grande)")
colores_pot <- c("d = 0.2 (pequeño)" = "#E63946",
                 "d = 0.5 (mediano)" = "#457B9D",
                 "d = 0.8 (grande)"  = "#2D6A4F")

df_pot <- do.call(rbind, lapply(seq_along(efectos), function(j) {
  potencias <- sapply(n_vec, function(n) {
    res <- tryCatch(
      power.t.test(n = n, delta = efectos[j], sd = 1,
                   sig.level = 0.05, type = "two.sample",
                   alternative = "two.sided"),
      error = function(e) list(power = NA)
    )
    res$power
  })
  data.frame(
    n         = n_vec,
    potencia  = potencias,
    efecto    = etiq_ef[j]
  )
}))

# n necesario para alcanzar potencia >= 0.80
n_80 <- sapply(seq_along(efectos), function(j) {
  sub <- df_pot[df_pot$efecto == etiq_ef[j] & !is.na(df_pot$potencia), ]
  n_val <- sub$n[which(sub$potencia >= 0.80)[1]]
  if (length(n_val) == 0 || is.na(n_val)) NA else n_val
})

df_pot$efecto <- factor(df_pot$efecto, levels = etiq_ef)

fig6 <- ggplot(df_pot, aes(x = n, y = potencia,
                            color = efecto, group = efecto)) +
  geom_line(linewidth = 1.1) +
  geom_hline(yintercept = 0.80, linetype = "dashed",
             color = "black", linewidth = 0.8) +
  annotate("text", x = max(n_vec) * 0.97, y = 0.82,
           label = "Potencia = 0.80\n(estándar convencional)",
           size = 3.4, hjust = 1, color = "black", fontface = "italic") +
  {
    # Marcar n necesario para cada efecto
    lapply(seq_along(efectos), function(j) {
      if (!is.na(n_80[j])) {
        list(
          geom_vline(xintercept = n_80[j],
                     linetype = "dotted",
                     color = unname(colores_pot[etiq_ef[j]]),
                     linewidth = 0.7),
          annotate("text",
                   x     = n_80[j],
                   y     = 0.05 + (j - 1) * 0.07,
                   label = paste0("n=", n_80[j]),
                   size  = 3.2,
                   color = unname(colores_pot[etiq_ef[j]]),
                   fontface = "bold",
                   hjust = -0.1)
        )
      }
    })
  } +
  scale_color_manual(values = colores_pot, name = "Tamaño de efecto (d de Cohen)") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1),
                     breaks = seq(0, 1, 0.1)) +
  scale_x_continuous(breaks = c(5, seq(25, 150, 25))) +
  labs(
    title    = "Curva de Potencia — Prueba t de Dos Colas (α = 0.05)",
    subtitle = "Línea punteada vertical: n mínimo para alcanzar 80% de potencia",
    x        = "Tamaño de muestra (n)",
    y        = "Potencia  (1 − β)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    legend.box      = "horizontal"
  )

guardar_figura(fig6, "fig_cap3_06_potencia")


# =============================================================================
cat("\n=== Script completado. 6 gráficos generados. ===\n")
