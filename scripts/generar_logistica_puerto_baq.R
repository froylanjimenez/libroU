# =============================================================================
# GENERACIÓN DE DATOS SINTÉTICOS: Operaciones Logísticas Puerto de Barranquilla
# =============================================================================
# Autor: Proyecto Libro de Estadística con R
# Descripción: 100 operaciones de carga en la Sociedad Portuaria de Barranquilla
#              (Puerto fluvial-marítimo sobre el río Magdalena)
# Referencia: SPRBAQ maneja ~5M ton/año; operaciones diversas 24/7
# =============================================================================

rm(list = ls())
set.seed(2024)

n <- 100

# --- Fechas: año 2023 (operaciones completas) --------------------------------
fecha_inicio <- as.Date("2023-01-01")
fecha_fin    <- as.Date("2023-12-31")
fecha <- sort(sample(seq(fecha_inicio, fecha_fin, by = "day"), n, replace = TRUE))

# --- Tipo de carga -----------------------------------------------------------
tipos_carga <- c("Contenedor", "Granel Solido", "Granel Liquido",
                  "Carga General", "Carga Refrigerada")
# Distribución real aproximada SPRBAQ
tipo_carga <- sample(tipos_carga, n, replace = TRUE,
                     prob = c(0.40, 0.25, 0.15, 0.12, 0.08))

# --- Número de contenedores (TEU o equivalente por operación) ----------------
# Varía por tipo de carga
num_contenedores <- mapply(function(tipo) {
  switch(tipo,
    "Contenedor"        = as.integer(round(rnorm(1, 85,  25))),
    "Granel Solido"     = as.integer(round(rnorm(1, 20,   8))),
    "Granel Liquido"    = as.integer(round(rnorm(1, 15,   5))),
    "Carga General"     = as.integer(round(rnorm(1, 35,  12))),
    "Carga Refrigerada" = as.integer(round(rnorm(1, 45,  15)))
  )
}, tipo_carga)
num_contenedores <- pmax(5L, num_contenedores)

# --- Tiempo de carga (horas) -------------------------------------------------
# Correlación positiva con número de contenedores
# Granel liquido más rápido (bombeo), contenedor más lento (movimiento unitario)
tiempo_base <- ifelse(tipo_carga == "Contenedor",        0.45,
               ifelse(tipo_carga == "Granel Solido",     0.30,
               ifelse(tipo_carga == "Granel Liquido",    0.18,
               ifelse(tipo_carga == "Carga General",     0.38,
                                                         0.50))))  # Refrigerada
tiempo_carga_horas <- round(pmax(1.5, pmin(72,
                       num_contenedores * tiempo_base + rnorm(n, 0, 3.5))), 1)

# --- Eficiencia operacional (%) ----------------------------------------------
# Basada en movimientos por hora vs estándar portuario
# Correlación negativa con tiempo_carga para tamaños similares
# Factores: turno (día vs noche), condiciones río, disponibilidad grúas
eficiencia_base <- ifelse(tipo_carga == "Granel Liquido",    88,  # Automatizado
                   ifelse(tipo_carga == "Contenedor",        78,  # Grúas pórtico
                   ifelse(tipo_carga == "Carga Refrigerada", 72,  # Cuidado especial
                   ifelse(tipo_carga == "Granel Solido",     75,
                                                             70)))) # Carga General
eficiencia_porcentaje <- round(pmax(45, pmin(99,
                          eficiencia_base + rnorm(n, 0, 8))), 1)

# --- Ajuste estacional (menos eficiencia en temporada de lluvias) ------------
mes <- as.integer(format(fecha, "%m"))
temporada_lluvias <- mes %in% c(4, 5, 6, 9, 10, 11)  # Bimodal Caribe
eficiencia_porcentaje <- ifelse(temporada_lluvias,
                          round(pmax(40, eficiencia_porcentaje - runif(n, 0, 6)), 1),
                          eficiencia_porcentaje)

# --- Ensamblar dataset -------------------------------------------------------
logistica_puerto_baq <- data.frame(
  fecha                 = fecha,
  tipo_carga            = factor(tipo_carga, levels = tipos_carga),
  num_contenedores      = num_contenedores,
  tiempo_carga_horas    = tiempo_carga_horas,
  eficiencia_porcentaje = eficiencia_porcentaje,
  stringsAsFactors      = FALSE
)

# --- Guardar CSV -------------------------------------------------------------
ruta_salida <- file.path("data", "logistica_puerto_baq.csv")
write.csv(logistica_puerto_baq, ruta_salida, row.names = FALSE, fileEncoding = "UTF-8")

cat("✓ Dataset generado:", ruta_salida, "\n")
cat("  Operaciones registradas:", nrow(logistica_puerto_baq), "\n")
cat("  Variables:", ncol(logistica_puerto_baq), "\n")
cat("  Distribución por tipo de carga:\n")
print(table(logistica_puerto_baq$tipo_carga))
cat("  Eficiencia media por tipo de carga (%):\n")
print(round(tapply(logistica_puerto_baq$eficiencia_porcentaje,
                   logistica_puerto_baq$tipo_carga, mean), 1))
cat("  Tiempo medio de carga:", round(mean(logistica_puerto_baq$tiempo_carga_horas), 1),
    "horas\n")
