# =============================================================================
# GENERACIÓN DE DATOS SINTÉTICOS: Cultivos de Palma de Aceite - Cesar
# =============================================================================
# Autor: Proyecto Libro de Estadística con R
# Descripción: 150 fincas palmeras del departamento del Cesar (Colombia)
#              El Cesar es el 2do productor nacional de palma de aceite
# Productividad referencia: 14-22 ton/ha (Fedepalma, 2022)
# =============================================================================

rm(list = ls())
set.seed(123)

n <- 150

# --- Municipios palmeros del Cesar (Zona Norte y Central) --------------------
municipios <- c(
  "Agustin Codazzi", "Becerril", "Chimichagua", "Chiriguana",
  "El Copey", "El Paso", "La Jagua de Ibirico", "Pailitas",
  "Pueblo Bello", "San Alberto", "San Martin", "Valledupar"
)
# Pesos proporcionales a producción palmera real por municipio
pesos_mpio <- c(0.15, 0.05, 0.06, 0.07, 0.10, 0.08, 0.04,
                0.06, 0.03, 0.14, 0.17, 0.05)

municipio <- sample(municipios, n, replace = TRUE, prob = pesos_mpio)

# --- Variedades de palma africana (Elaeis guineensis) ------------------------
variedades <- c("Tenera", "Dura", "Hibrido OxG")
# Tenera domina el mercado comercial (~75%), Dura legacy (~15%), Híbrido creciente (~10%)
variedad <- sample(variedades, n, replace = TRUE, prob = c(0.75, 0.15, 0.10))

# --- Productividad: toneladas de RFF por hectárea ----------------------------
# Tenera: media 18 t/ha | Dura: 13 t/ha | Híbrido OxG: 22 t/ha
toneladas_base <- ifelse(variedad == "Tenera",     18.0,
                  ifelse(variedad == "Dura",        13.0,
                                                    22.0))
toneladas_ha <- round(pmax(8, pmin(30,
                 toneladas_base + rnorm(n, 0, 2.8))), 2)

# --- Fertilizante aplicado (kg/ha/año) ---------------------------------------
# Correlación positiva con productividad (r ≈ 0.65)
# Rango típico: 200-600 kg/ha según Cenipalma
fertilizante_kg <- round(pmax(150, pmin(650,
                   300 + (toneladas_ha - 15) * 12 + rnorm(n, 0, 45))), 0)

# --- Precipitación anual (mm) ------------------------------------------------
# Cesar: 1000-2200 mm/año según zona; bimodal (abr-jun y sep-nov)
# Municipios más secos al norte, más húmedos al sur
precip_media <- ifelse(municipio %in% c("Valledupar", "El Copey", "Pueblo Bello"), 1150,
                ifelse(municipio %in% c("Agustin Codazzi", "Becerril", "El Paso"),   1400,
                ifelse(municipio %in% c("San Alberto", "San Martin", "Pailitas"),    1750,
                                                                                     1550)))
precipitacion_mm <- round(pmax(800, pmin(2400,
                      precip_media + rnorm(n, 0, 180))), 0)

# --- Ensamblar dataset -------------------------------------------------------
palma_cesar <- data.frame(
  municipio        = municipio,
  variedad         = factor(variedad, levels = variedades),
  toneladas_ha     = toneladas_ha,
  fertilizante_kg  = as.integer(fertilizante_kg),
  precipitacion_mm = as.integer(precipitacion_mm),
  stringsAsFactors = FALSE
)

# Reordenar columnas para legibilidad
palma_cesar <- palma_cesar[, c("municipio", "variedad", "toneladas_ha",
                                "fertilizante_kg", "precipitacion_mm")]

# --- Guardar CSV -------------------------------------------------------------
ruta_salida <- file.path("data", "palma_cesar.csv")
write.csv(palma_cesar, ruta_salida, row.names = FALSE, fileEncoding = "UTF-8")

cat("✓ Dataset generado:", ruta_salida, "\n")
cat("  Observaciones (fincas):", nrow(palma_cesar), "\n")
cat("  Variables:", ncol(palma_cesar), "\n")
cat("  Distribución por variedad:\n")
print(table(palma_cesar$variedad))
cat("  Productividad media por variedad (ton/ha):\n")
print(round(tapply(palma_cesar$toneladas_ha, palma_cesar$variedad, mean), 2))
cat("  Rango precipitación:", range(palma_cesar$precipitacion_mm), "mm\n")
