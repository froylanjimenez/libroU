# =============================================================================
# generar_figuras.R
# Genera todas las figuras del libro "Estadística Aplicada con R"
# Ejecutar desde la raíz del proyecto: Rscript scripts/generar_figuras.R
# =============================================================================

# Create figures directory if it doesn't exist
dir.create("figures", showWarnings = FALSE)
cat("Generating figures...\n")

suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(dplyr))

# =============================================================================
# Cargar datos
# =============================================================================
cat("Cargando datos...\n")
biodiversidad <- read_csv("data/biodiversidad_sierra.csv", show_col_types = FALSE)
palma         <- read.csv("data/palma_cesar.csv", stringsAsFactors = FALSE)
logistica     <- read.csv("data/logistica_puerto_baq.csv", stringsAsFactors = FALSE)
cat("  biodiversidad:", nrow(biodiversidad), "filas\n")
cat("  palma        :", nrow(palma), "filas\n")
cat("  logistica    :", nrow(logistica), "filas\n\n")

# =============================================================================
# CAP01 — Figura 1: Jerarquía de estructuras de datos en R
# =============================================================================
cat("fig01_01_jerarquia_r.png\n")

png("figures/fig01_01_jerarquia_r.png", width = 8, height = 5,
    units = "in", res = 150)

par(mar = c(1, 1, 2, 1), bg = "white")
plot(0, 0, type = "n", xlim = c(0, 10), ylim = c(0, 8),
     axes = FALSE, xlab = "", ylab = "",
     main = "Jerarquía de estructuras de datos en R")

# Nivel 1 — Vector (base)
rect(3.5, 0.4, 6.5, 1.6, col = "#AED6F1", border = "#2980B9", lwd = 2)
text(5, 1.0, "Vector atómico\n(1D, tipo único)", cex = 1.0, font = 2, col = "#1A5276")

# Nivel 2 — Matriz y Lista
rect(0.5, 3.0, 3.5, 4.6, col = "#A9DFBF", border = "#27AE60", lwd = 2)
text(2.0, 3.8, "Matriz\n(2D, tipo único)", cex = 0.95, font = 2, col = "#145A32")

rect(4.0, 3.0, 7.0, 4.6, col = "#FAD7A0", border = "#E67E22", lwd = 2)
text(5.5, 3.8, "Lista\n(anidada, tipos mixtos)", cex = 0.95, font = 2, col = "#784212")

# Nivel 3 — Data Frame
rect(2.0, 5.8, 8.0, 7.4, col = "#D7BDE2", border = "#8E44AD", lwd = 2)
text(5.0, 6.6, "Data Frame\n(2D, columnas de tipos distintos)", cex = 1.0, font = 2, col = "#4A235A")

# Flechas
arrows(5.0, 1.65, 2.0, 2.95, length = 0.12, lwd = 2, col = "#555555")
arrows(5.0, 1.65, 5.5, 2.95, length = 0.12, lwd = 2, col = "#555555")
arrows(5.5, 4.65, 5.0, 5.75, length = 0.12, lwd = 2, col = "#555555")
arrows(2.0, 4.65, 4.5, 5.75, length = 0.12, lwd = 2, col = "#555555")

# Etiquetas de complejidad
mtext("Menor complejidad", side = 1, line = -1.5, at = 1.5, cex = 0.8, col = "gray40")
mtext("Mayor complejidad", side = 1, line = -1.5, at = 8.5, cex = 0.8, col = "gray40")

dev.off()
cat("  OK\n")

# =============================================================================
# CAP01 — Figura 2: Gradiente altitudinal de temperatura
# =============================================================================
cat("fig01_02_gradiente_termico.png\n")

p <- ggplot(biodiversidad, aes(x = altura_msnm, y = temperatura_C, color = zona_vida)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE, color = "black", linetype = "dashed") +
  scale_color_viridis_d(option = "D", name = "Zona de vida") +
  labs(title = "Gradiente altitudinal de temperatura",
       subtitle = "Sierra Nevada de Santa Marta — 200 parcelas",
       x = "Altura (msnm)", y = "Temperatura (°C)",
       caption = "Fuente: Dataset sintético reproducible (set.seed = 42)") +
  theme_minimal(base_size = 12) + theme(legend.position = "bottom")

ggsave("figures/fig01_02_gradiente_termico.png", p, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Figura: Tendencia central
# =============================================================================
cat("fig02_tendencia_central.png\n")

medidas_df <- data.frame(
  tipo  = c("Aritmética", "Ponderada", "Geométrica", "Armónica"),
  valor = c(15.987, 15.963, 15.687, 15.389)
)
medidas_df$tipo <- factor(medidas_df$tipo,
                          levels = c("Aritmética", "Ponderada", "Geométrica", "Armónica"))

p02a <- ggplot(medidas_df, aes(x = tipo, y = valor, fill = tipo)) +
  geom_col(alpha = 0.85, width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = round(valor, 3)), vjust = -0.4, fontface = "bold", size = 4) +
  scale_fill_brewer(palette = "Set2") +
  coord_cartesian(ylim = c(15, 16.2)) +
  labs(title = "Comparación de medidas de tendencia central",
       subtitle = "Productividad palmera — Cesar (ton/ha)",
       x = "Tipo de media", y = "ton/ha",
       caption = "Media aritmética: 15.987 | Ponderada: 15.963 | Geométrica: 15.687 | Armónica: 15.389") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_tendencia_central.png", p02a, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Figura: Dispersión de temperatura (histograma + densidad)
# =============================================================================
cat("fig02_dispersion_temperatura.png\n")

media_temp  <- mean(biodiversidad$temperatura_C, na.rm = TRUE)
median_temp <- median(biodiversidad$temperatura_C, na.rm = TRUE)

p02b <- ggplot(biodiversidad, aes(x = temperatura_C)) +
  geom_histogram(aes(y = after_stat(density)), bins = 15,
                 fill = "#2E86AB", color = "white", alpha = 0.8) +
  geom_density(color = "#E84855", linewidth = 1.2, adjust = 1.3) +
  geom_vline(xintercept = media_temp, color = "#F4D35E",
             linewidth = 1.1, linetype = "dashed") +
  geom_vline(xintercept = median_temp, color = "#1B998B",
             linewidth = 1.1, linetype = "dotdash") +
  annotate("text", x = media_temp + 0.8, y = 0.048,
           label = paste0("Media\n", round(media_temp, 1), "°C"),
           color = "#B8860B", size = 3.5, fontface = "bold") +
  annotate("text", x = median_temp - 0.8, y = 0.048,
           label = paste0("Mediana\n", round(median_temp, 1), "°C"),
           color = "#007060", size = 3.5, fontface = "bold", hjust = 1) +
  labs(title = "Distribución de temperatura — Sierra Nevada de Santa Marta",
       subtitle = "200 parcelas | Línea amarilla: media | Línea verde: mediana",
       x = "Temperatura (°C)", y = "Densidad",
       caption = "Fuente: biodiversidad_sierra.csv") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_dispersion_temperatura.png", p02b, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Figura: Densidad por grupos (zona_vida)
# =============================================================================
cat("fig02_densidad_grupos.png\n")

p02c <- ggplot(biodiversidad, aes(x = temperatura_C,
                                   fill = zona_vida, color = zona_vida)) +
  geom_density(alpha = 0.35, linewidth = 1.0) +
  scale_fill_brewer(palette  = "Set2", name = "Zona de vida") +
  scale_color_brewer(palette = "Set2", name = "Zona de vida") +
  labs(title = "Distribución de temperatura por zona de vida",
       subtitle = "Sierra Nevada de Santa Marta — Caribe Colombiano",
       x = "Temperatura (°C)", y = "Densidad de probabilidad",
       caption = "Fuente: biodiversidad_sierra.csv") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_densidad_grupos.png", p02c, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Figura: Boxplot palma por variedad
# =============================================================================
cat("fig02_boxplot_palma.png\n")

p02d <- ggplot(palma, aes(x = variedad, y = toneladas_ha, fill = variedad)) +
  geom_boxplot(outlier.color = "red", outlier.shape = 21,
               outlier.size = 2, alpha = 0.7) +
  geom_jitter(width = 0.15, alpha = 0.3, size = 1.2) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Productividad de palma por variedad — Cesar",
       subtitle = "Distribución de toneladas por hectárea | Puntos rojos: outliers Tukey",
       x = "Variedad de palma", y = "Producción (toneladas/ha)",
       caption = "Fuente: palma_cesar.csv",
       fill = "Variedad") +
  theme_bw(base_size = 12) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 30, hjust = 1),
        plot.title  = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_boxplot_palma.png", p02d, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p1: Histograma altura
# =============================================================================
cat("fig02_hist_altura.png\n")

p1 <- ggplot(biodiversidad, aes(x = altura_msnm)) +
  geom_histogram(bins = 9, fill = "#2E86AB", color = "white", alpha = 0.85) +
  geom_density(aes(y = after_stat(count)), color = "#E84855",
               linewidth = 1.2, adjust = 1.5) +
  geom_vline(xintercept = mean(biodiversidad$altura_msnm, na.rm = TRUE),
             color = "#F4D35E", linewidth = 1, linetype = "dashed") +
  geom_vline(xintercept = median(biodiversidad$altura_msnm, na.rm = TRUE),
             color = "#1B998B", linewidth = 1, linetype = "dotdash") +
  labs(title    = "Distribución de Altitud — Sierra Nevada de Santa Marta",
       subtitle = "n = 200 registros de biodiversidad | Líneas: Media (amarillo), Mediana (verde)",
       x        = "Altura sobre el nivel del mar (msnm)",
       y        = "Frecuencia absoluta",
       caption  = "Fuente: Dataset biodiversidad_sierra.csv") +
  theme_minimal(base_size = 13) +
  theme(plot.title    = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, color = "gray40"),
        panel.grid.minor = element_blank())

ggsave("figures/fig02_hist_altura.png", p1, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p2: Densidad temperatura por zona
# =============================================================================
cat("fig02_densidad_temp_zona.png\n")

p2 <- ggplot(biodiversidad, aes(x = temperatura_C,
                                 fill = zona_vida, color = zona_vida)) +
  geom_density(alpha = 0.3, linewidth = 1) +
  scale_fill_brewer(palette  = "Set2", name = "Zona de vida") +
  scale_color_brewer(palette = "Set2", name = "Zona de vida") +
  labs(title    = "Distribución de Temperatura por Zona de Vida",
       subtitle = "Sierra Nevada de Santa Marta — Caribe Colombiano",
       x        = "Temperatura (°C)",
       y        = "Densidad de probabilidad",
       caption  = "Fuente: biodiversidad_sierra.csv") +
  theme_classic(base_size = 12) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold"))

ggsave("figures/fig02_densidad_temp_zona.png", p2, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p3: Boxplot palma variedad
# =============================================================================
cat("fig02_boxplot_palma_variedad.png\n")

p3 <- ggplot(palma, aes(x = variedad, y = toneladas_ha, fill = variedad)) +
  geom_boxplot(outlier.color = "red", outlier.shape = 21,
               outlier.size  = 2, alpha = 0.7) +
  geom_jitter(width = 0.15, alpha = 0.4, size = 1.5) +
  scale_fill_manual(values = c("#A8DADC", "#457B9D", "#1D3557", "#E63946", "#F1FAEE")) +
  labs(title    = "Productividad de Palma de Aceite por Variedad — Cesar",
       subtitle = "Distribución de toneladas por hectárea | Puntos rojos: outliers Tukey",
       x        = "Variedad de palma",
       y        = "Producción (toneladas/ha)",
       caption  = "Fuente: palma_cesar.csv",
       fill     = "Variedad") +
  theme_bw(base_size = 12) +
  theme(legend.position  = "none",
        axis.text.x      = element_text(angle = 30, hjust = 1),
        plot.title       = element_text(face = "bold"))

ggsave("figures/fig02_boxplot_palma_variedad.png", p3, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p4: Barras tipo_carga
# =============================================================================
cat("fig02_barras_tipo_carga.png\n")

freq_carga <- logistica %>%
  count(tipo_carga) %>%
  mutate(porcentaje = n / sum(n) * 100,
         tipo_carga = reorder(tipo_carga, -n))

p4 <- ggplot(freq_carga, aes(x = tipo_carga, y = n, fill = tipo_carga)) +
  geom_col(show.legend = FALSE, alpha = 0.85) +
  geom_text(aes(label = paste0(round(porcentaje, 1), "%")),
            vjust = -0.5, size = 4, fontface = "bold") +
  scale_fill_brewer(palette = "Set3") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title    = "Distribución de Operaciones por Tipo de Carga",
       subtitle = "Puerto de Barranquilla — 100 operaciones registradas",
       x        = "Tipo de carga",
       y        = "Número de operaciones",
       caption  = "Fuente: logistica_puerto_baq.csv") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1),
        plot.title  = element_text(face = "bold", hjust = 0.5),
        panel.grid.major.x = element_blank())

ggsave("figures/fig02_barras_tipo_carga.png", p4, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p5: Dispersión fertilizante vs toneladas
# =============================================================================
cat("fig02_dispersion_fertilizante.png\n")

p5 <- ggplot(palma, aes(x = fertilizante_kg, y = toneladas_ha, color = variedad)) +
  geom_point(alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, alpha = 0.15, linewidth = 1) +
  scale_color_brewer(palette = "Dark2", name = "Variedad") +
  labs(title    = "Relación entre Fertilización y Productividad de Palma",
       subtitle = "Departamento del Cesar — Por variedad cultivada",
       x        = "Fertilizante aplicado (kg/ha)",
       y        = "Productividad (toneladas/ha)",
       caption  = "Fuente: palma_cesar.csv | Línea: regresión lineal + IC 95%") +
  theme_light(base_size = 12) +
  theme(legend.position = "right",
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_dispersion_fertilizante.png", p5, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP02 — Sección ggplot2 — p6: Dispersión eficiencia facetado
# =============================================================================
cat("fig02_dispersion_eficiencia.png\n")

p6 <- ggplot(logistica, aes(x = tiempo_carga_horas, y = eficiencia_porcentaje)) +
  geom_point(aes(size = num_contenedores, color = eficiencia_porcentaje), alpha = 0.7) +
  facet_wrap(~ tipo_carga, scales = "free_x", ncol = 3) +
  scale_color_gradient(low = "#E63946", high = "#2DC653", name = "Eficiencia (%)") +
  scale_size_continuous(name = "Contenedores", range = c(1, 5)) +
  labs(title   = "Eficiencia vs Tiempo de Carga por Tipo de Mercancía",
       subtitle = "Puerto de Barranquilla | Tamaño del punto: número de contenedores",
       x       = "Tiempo de carga (horas)",
       y       = "Eficiencia (%)",
       caption = "Fuente: logistica_puerto_baq.csv") +
  theme_bw(base_size = 11) +
  theme(strip.background = element_rect(fill = "#457B9D"),
        strip.text       = element_text(color = "white", face = "bold"),
        plot.title       = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig02_dispersion_eficiencia.png", p6, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: t de Student vs Normal
# =============================================================================
cat("fig03_t_student.png\n")

x_t <- seq(-5, 5, length.out = 1000)
dfs <- c(3, 10, 30, 60)
labels_t <- c("t (df=3)", "t (df=10)", "t (df=30)", "t (df=60)")

df_t_all <- do.call(rbind, lapply(seq_along(dfs), function(i) {
  data.frame(x = x_t, y = dt(x_t, df = dfs[i]),
             distribucion = labels_t[i])
}))
df_norm_t <- data.frame(x = x_t, y = dnorm(x_t), distribucion = "N(0,1)")
df_t_plot <- rbind(df_t_all, df_norm_t)
df_t_plot$distribucion <- factor(df_t_plot$distribucion,
                                  levels = c("t (df=3)", "t (df=10)",
                                             "t (df=30)", "t (df=60)", "N(0,1)"))

colores_t <- c("t (df=3)"  = "#E63946", "t (df=10)" = "#F4A261",
               "t (df=30)" = "#2A9D8F", "t (df=60)" = "#457B9D",
               "N(0,1)"    = "#1D3557")

p_t <- ggplot(df_t_plot, aes(x = x, y = y, color = distribucion)) +
  geom_line(linewidth = 1.0) +
  scale_color_manual(values = colores_t, name = "Distribución") +
  coord_cartesian(xlim = c(-5, 5), ylim = c(0, 0.42)) +
  labs(title    = "Distribución t de Student vs Normal Estándar",
       subtitle = "Las colas son más pesadas para pocos grados de libertad",
       x = "t", y = "Densidad f(t)",
       caption = "Convergencia a N(0,1) conforme df → ∞") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "right")

ggsave("figures/fig03_t_student.png", p_t, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: Simulación de 30 ICs al 95%
# =============================================================================
cat("fig03_ic_simulacion.png\n")

set.seed(42)
mu_true <- 12
sigma   <- 3
n_sim   <- 25
n_ics   <- 30

ics <- do.call(rbind, lapply(1:n_ics, function(i) {
  muestra <- rnorm(n_sim, mean = mu_true, sd = sigma)
  tt <- t.test(muestra, conf.level = 0.95)
  data.frame(sim = i,
             media = mean(muestra),
             lci   = tt$conf.int[1],
             lcs   = tt$conf.int[2])
}))
ics$contiene <- (ics$lci <= mu_true) & (ics$lcs >= mu_true)
ics$color_ic <- ifelse(ics$contiene, "Contiene μ", "No contiene μ")

p_ic <- ggplot(ics, aes(y = sim, color = color_ic)) +
  geom_segment(aes(x = lci, xend = lcs, y = sim, yend = sim), linewidth = 1.0) +
  geom_point(aes(x = media), size = 2.5, shape = 16) +
  geom_vline(xintercept = mu_true, linetype = "dashed",
             color = "black", linewidth = 1.0) +
  annotate("text", x = mu_true + 0.15, y = n_ics + 0.8,
           label = paste0("μ = ", mu_true), size = 3.8,
           hjust = 0, fontface = "bold") +
  scale_color_manual(values = c("Contiene μ" = "#457B9D",
                                "No contiene μ" = "#E63946"),
                     name = "Intervalo") +
  scale_y_continuous(breaks = seq(1, n_ics, 5)) +
  labs(title    = "Simulación de 30 Intervalos de Confianza al 95%",
       subtitle = paste0("ICs que no contienen μ=", mu_true, ": ",
                         sum(!ics$contiene), " de ", n_ics),
       x        = "Valor", y = "Simulación #",
       caption  = "set.seed(42) | n=25 | μ=12 | σ=3") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "bottom",
        panel.grid.minor = element_blank())

ggsave("figures/fig03_ic_simulacion.png", p_ic, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: Regiones de rechazo
# =============================================================================
cat("fig03_regiones_rechazo.png\n")

z_crit <- 1.96
x_norm <- seq(-4, 4, length.out = 1000)
df_norm_rej <- data.frame(x = x_norm, y = dnorm(x_norm))

df_rej_izq <- data.frame(x = seq(-4, -z_crit, length.out = 300),
                          y = dnorm(seq(-4, -z_crit, length.out = 300)))
df_rej_der <- data.frame(x = seq(z_crit, 4, length.out = 300),
                          y = dnorm(seq(z_crit, 4, length.out = 300)))
df_centro  <- data.frame(x = seq(-z_crit, z_crit, length.out = 600),
                          y = dnorm(seq(-z_crit, z_crit, length.out = 600)))

p_rej <- ggplot(df_norm_rej, aes(x = x, y = y)) +
  geom_ribbon(data = df_centro, aes(x = x, ymin = 0, ymax = y),
              fill = "#AEC6CF", alpha = 0.4, inherit.aes = FALSE) +
  geom_ribbon(data = df_rej_izq, aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_ribbon(data = df_rej_der, aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_line(linewidth = 1.1, color = "black") +
  geom_vline(xintercept = c(-z_crit, z_crit),
             linetype = "dashed", color = "#E63946", linewidth = 0.9) +
  annotate("text", x = -z_crit, y = -0.008, label = "-1.96",
           size = 3.8, color = "#C0392B", fontface = "bold") +
  annotate("text", x =  z_crit, y = -0.008, label = "+1.96",
           size = 3.8, color = "#C0392B", fontface = "bold") +
  annotate("text", x = -3.0, y = 0.025,
           label = "α/2 = 0.025\nRechazo H₀",
           size = 3.5, color = "#C0392B", fontface = "bold", hjust = 0.5) +
  annotate("text", x =  3.0, y = 0.025,
           label = "α/2 = 0.025\nRechazo H₀",
           size = 3.5, color = "#C0392B", fontface = "bold", hjust = 0.5) +
  annotate("text", x = 0, y = 0.17,
           label = "1 − α = 0.95\nNo se rechaza H₀",
           size = 4.0, color = "#1A5276", fontface = "bold", hjust = 0.5) +
  labs(title    = "Distribución Normal Estándar — Regiones de Rechazo (α = 0.05)",
       subtitle = "Prueba bilateral: se rechaza H₀ si |z| > 1.96",
       x = "z", y = "Densidad f(z)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig03_regiones_rechazo.png", p_rej, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: Valor p
# =============================================================================
cat("fig03_valor_p.png\n")

# Prueba t real contra mu_h0 = 15
mu_h0   <- 15
test_h0 <- t.test(biodiversidad$temperatura_C, mu = mu_h0, alternative = "two.sided")
t_obs   <- as.numeric(test_h0$statistic)
df_test <- as.numeric(test_h0$parameter)
p_val   <- test_h0$p.value

x_t2 <- seq(-max(abs(t_obs) * 1.5, 4), max(abs(t_obs) * 1.5, 4), length.out = 1200)
df_t2_plot <- data.frame(x = x_t2, y = dt(x_t2, df = df_test))
t_abs <- abs(t_obs)
df_pval_der <- data.frame(x = seq(t_abs, max(x_t2), length.out = 400),
                           y = dt(seq(t_abs, max(x_t2), length.out = 400), df = df_test))
df_pval_izq <- data.frame(x = seq(min(x_t2), -t_abs, length.out = 400),
                           y = dt(seq(min(x_t2), -t_abs, length.out = 400), df = df_test))

p_pval <- ggplot(df_t2_plot, aes(x = x, y = y)) +
  geom_ribbon(data = df_pval_izq, aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_ribbon(data = df_pval_der, aes(x = x, ymin = 0, ymax = y),
              fill = "#E63946", alpha = 0.5, inherit.aes = FALSE) +
  geom_line(linewidth = 1.1, color = "black") +
  geom_vline(xintercept =  t_obs, linetype = "dashed",
             color = "#E63946", linewidth = 1.0) +
  geom_vline(xintercept = -t_obs, linetype = "dashed",
             color = "#E63946", linewidth = 1.0) +
  annotate("text", x = t_obs, y = dt(0, df = df_test) * 0.55,
           label = paste0("t_obs = ", round(t_obs, 2)),
           size = 3.8, hjust = -0.08, color = "#C0392B", fontface = "bold") +
  labs(title    = paste0("Valor p — H₀: μ_temperatura = ", mu_h0, "°C"),
       subtitle = paste0("t_obs = ", round(t_obs, 3),
                         "  |  p-valor = ", formatC(p_val, format = "e", digits = 3),
                         if (p_val < 0.05) "  →  Se rechaza H₀" else "  →  No se rechaza H₀"),
       x = "Estadístico t", y = "Densidad") +
  theme_minimal(base_size = 12) +
  theme(plot.title    = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 9, color = "grey30"))

ggsave("figures/fig03_valor_p.png", p_pval, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: Q-Q plots
# =============================================================================
cat("fig03_qq_plots.png\n")

make_qq <- function(datos, titulo) {
  y <- datos[!is.na(datos)]
  sw <- shapiro.test(y)
  lbl <- paste0("W = ", round(sw$statistic, 4),
                "\np = ", formatC(sw$p.value, format = "e", digits = 2))
  df_qq <- data.frame(y = y)
  ggplot(df_qq, aes(sample = y)) +
    stat_qq(color = "#1B4F72", alpha = 0.7, size = 1.5) +
    stat_qq_line(color = "#E63946", linewidth = 0.9) +
    annotate("label", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.3,
             label = lbl, size = 2.8, fill = "white",
             color = ifelse(sw$p.value > 0.05, "#1A5276", "#C0392B"),
             label.size = 0.2) +
    labs(title = titulo, x = "Cuantiles teóricos", y = "Cuantiles muestra") +
    theme_light(base_size = 10) +
    theme(plot.title = element_text(face = "bold", size = 9.5))
}

suppressPackageStartupMessages(library(patchwork))
qq1 <- make_qq(biodiversidad$temperatura_C, "temperatura_C (Sierra Nevada)")
qq2 <- make_qq(palma$toneladas_ha,          "toneladas_ha (Palma Cesar)")

fig_qq <- (qq1 + qq2) +
  plot_annotation(
    title    = "Gráficos Q-Q: Verificación de Normalidad",
    subtitle = "Puntos sobre la línea roja indican distribución normal",
    theme    = theme(plot.title    = element_text(face = "bold", size = 13, hjust = 0.5),
                     plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"))
  )

ggsave("figures/fig03_qq_plots.png", fig_qq, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP03 — Figura: Curvas de potencia
# =============================================================================
cat("fig03_curvas_potencia.png\n")

n_vec    <- 5:200
efectos  <- c(0.2, 0.5, 0.8)
etiq_ef  <- c("d = 0.2 (pequeño)", "d = 0.5 (mediano)", "d = 0.8 (grande)")

df_pot <- do.call(rbind, lapply(seq_along(efectos), function(j) {
  pots <- sapply(n_vec, function(n) {
    res <- tryCatch(
      power.t.test(n = n, delta = efectos[j], sd = 1,
                   sig.level = 0.05, type = "two.sample",
                   alternative = "two.sided"),
      error = function(e) list(power = NA)
    )
    res$power
  })
  data.frame(n = n_vec, potencia = pots, efecto = etiq_ef[j])
}))
df_pot$efecto <- factor(df_pot$efecto, levels = etiq_ef)

colores_pot <- c("d = 0.2 (pequeño)" = "#E63946",
                 "d = 0.5 (mediano)" = "#457B9D",
                 "d = 0.8 (grande)"  = "#2D6A4F")

p_pot <- ggplot(df_pot, aes(x = n, y = potencia, color = efecto)) +
  geom_line(linewidth = 1.1) +
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "black", linewidth = 0.8) +
  annotate("text", x = 195, y = 0.83,
           label = "Potencia = 0.80",
           size = 3.4, hjust = 1, fontface = "italic") +
  scale_color_manual(values = colores_pot, name = "Tamaño de efecto") +
  scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"),
                     limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
  labs(title    = "Curvas de Potencia — Prueba t bilateral (α = 0.05)",
       subtitle = "Línea punteada: umbral convencional de 80% de potencia",
       x        = "Tamaño de muestra (n)",
       y        = "Potencia (1 − β)",
       caption  = "d de Cohen: 0.2 = pequeño, 0.5 = mediano, 0.8 = grande") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "bottom")

ggsave("figures/fig03_curvas_potencia.png", p_pot, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP04 — Figura: Matrices de correlación
# =============================================================================
cat("fig04_correlacion_matrices.png\n")

# Seleccionar variables numéricas
bio_num   <- biodiversidad %>% select(where(is.numeric))
palma_num <- palma %>% select(where(is.numeric))

cor_bio   <- cor(bio_num,   use = "complete.obs")
cor_palma <- cor(palma_num, use = "complete.obs")

# Construir con ggplot2 (estilo corrplot manual)
cor_to_df <- function(mat, label) {
  df <- as.data.frame(as.table(mat))
  names(df) <- c("Var1", "Var2", "value")
  df$dataset <- label
  df
}

df_cor_bio   <- cor_to_df(cor_bio,   "Biodiversidad Sierra Nevada")
df_cor_palma <- cor_to_df(cor_palma, "Palma de Aceite Cesar")
df_cor_all   <- rbind(df_cor_bio, df_cor_palma)

p_cor <- ggplot(df_cor_all, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(value, 2)), size = 2.8, fontface = "bold") +
  facet_wrap(~ dataset, scales = "free") +
  scale_fill_gradient2(low = "#E63946", mid = "white", high = "#2196F3",
                       midpoint = 0, limits = c(-1, 1),
                       name = "Correlación") +
  labs(title    = "Matrices de Correlación — Datasets del proyecto",
       subtitle = "Biodiversidad Sierra Nevada y Palma de Aceite Cesar",
       x = NULL, y = NULL,
       caption  = "Correlación de Pearson | Variables numéricas") +
  theme_minimal(base_size = 10) +
  theme(axis.text.x  = element_text(angle = 30, hjust = 1),
        plot.title   = element_text(face = "bold", hjust = 0.5),
        strip.text   = element_text(face = "bold"))

ggsave("figures/fig04_correlacion_matrices.png", p_cor, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
# CAP04 — Figura: Regresión con bandas de confianza y predicción
# =============================================================================
cat("fig04_regresion_bandas.png\n")

modelo <- lm(temperatura_C ~ altura_msnm, data = biodiversidad)

# Crear secuencia de alturas para predicciones
x_pred <- data.frame(altura_msnm = seq(min(biodiversidad$altura_msnm),
                                        max(biodiversidad$altura_msnm),
                                        length.out = 200))
ic  <- predict(modelo, x_pred, interval = "confidence", level = 0.95)
ip  <- predict(modelo, x_pred, interval = "prediction", level = 0.95)

df_bands <- cbind(x_pred,
                  ic_lwr = ic[, "lwr"], ic_upr = ic[, "upr"],
                  ip_lwr = ip[, "lwr"], ip_upr = ip[, "upr"],
                  fit    = ic[, "fit"])

p_bands <- ggplot() +
  # Banda de predicción (más ancha, rosa)
  geom_ribbon(data = df_bands,
              aes(x = altura_msnm, ymin = ip_lwr, ymax = ip_upr),
              fill = "#FFCCCC", alpha = 0.6) +
  # Banda de confianza (estrecha, azul)
  geom_ribbon(data = df_bands,
              aes(x = altura_msnm, ymin = ic_lwr, ymax = ic_upr),
              fill = "#AED6F1", alpha = 0.7) +
  # Puntos originales
  geom_point(data = biodiversidad,
             aes(x = altura_msnm, y = temperatura_C),
             alpha = 0.4, size = 1.5, color = "gray50") +
  # Recta de regresión
  geom_line(data = df_bands, aes(x = altura_msnm, y = fit),
            color = "#C0392B", linewidth = 1.2) +
  labs(title    = "Regresión MCO con bandas de confianza y predicción",
       subtitle = "Banda azul: IC 95% para la media | Banda rosa: IP 95% individual",
       x        = "Altura (msnm)", y = "Temperatura (°C)",
       caption  = paste0("R² = ", round(summary(modelo)$r.squared, 4),
                         " | β₁ = ", round(coef(modelo)[2], 5), " °C/msnm")) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave("figures/fig04_regresion_bandas.png", p_bands, width = 8, height = 5, dpi = 150)
cat("  OK\n")

# =============================================================================
cat("\n=== Todas las figuras generadas exitosamente. ===\n")
cat("Figuras en: figures/\n")
