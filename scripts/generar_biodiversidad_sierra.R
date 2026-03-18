# =============================================================================
# GENERACIÓN DE DATOS SINTÉTICOS: Biodiversidad Sierra Nevada de Santa Marta
# =============================================================================
# Autor: Proyecto Libro de Estadística con R
# Descripción: 200 observaciones de especies en distintas zonas de vida
#              de la Sierra Nevada de Santa Marta (Colombia)
# Referencia altitudinal: 0 - 5.775 msnm (Pico Cristóbal Colón)
# =============================================================================

rm(list = ls())
set.seed(42)

n <- 200

# --- Zonas de vida (sistema Holdridge adaptado a Sierra Nevada) --------------
zonas <- c(
  "Bosque Seco Tropical",       # 0 - 800 msnm
  "Bosque Humedo Tropical",     # 800 - 1800 msnm
  "Bosque Muy Humedo Montano",  # 1800 - 2800 msnm
  "Bosque Nublado",             # 2800 - 3800 msnm
  "Paramo"                      # 3800 - 5500 msnm
)

# Distribución de observaciones por zona (más registros en zonas medias)
zona_vida <- sample(zonas, n, replace = TRUE,
                    prob = c(0.20, 0.30, 0.25, 0.15, 0.10))

# --- Alturas coherentes con cada zona de vida --------------------------------
altura_msnm <- mapply(function(zona) {
  switch(zona,
    "Bosque Seco Tropical"      = round(runif(1,   0,  800)),
    "Bosque Humedo Tropical"    = round(runif(1, 800, 1800)),
    "Bosque Muy Humedo Montano" = round(runif(1, 1800, 2800)),
    "Bosque Nublado"            = round(runif(1, 2800, 3800)),
    "Paramo"                    = round(runif(1, 3800, 5500))
  )
}, zona_vida)

# --- Temperatura: gradiente altitudinal (-6.5°C por 1000 m) -----------------
temperatura_C <- round(28.5 - (altura_msnm / 1000) * 6.5 + rnorm(n, 0, 1.2), 1)
temperatura_C <- pmax(temperatura_C, 2.0)   # Mínimo páramo
temperatura_C <- pmin(temperatura_C, 38.0)  # Máximo costa

# --- Humedad relativa: aumenta con altitud hasta bosque nublado --------------
humedad_base <- ifelse(zona_vida == "Bosque Seco Tropical",      65,
                ifelse(zona_vida == "Bosque Humedo Tropical",     78,
                ifelse(zona_vida == "Bosque Muy Humedo Montano",  88,
                ifelse(zona_vida == "Bosque Nublado",             95,
                                                                  80))))
humedad_relativa <- round(pmin(100, pmax(30,
                    humedad_base + rnorm(n, 0, 5))), 1)

# --- Especies representativas por zona de vida -------------------------------
especies_por_zona <- list(
  "Bosque Seco Tropical" = c(
    "Bursera simaruba", "Capparis odoratissima", "Prosopis juliflora",
    "Guaiacum officinale", "Stenocereus griseus", "Opuntia wentiana",
    "Cedrela odorata", "Handroanthus chrysanthus"
  ),
  "Bosque Humedo Tropical" = c(
    "Swietenia macrophylla", "Ceiba pentandra", "Ficus insipida",
    "Inga edulis", "Heliconia bihai", "Philodendron sp.",
    "Clusia rosea", "Miconia calvescens"
  ),
  "Bosque Muy Humedo Montano" = c(
    "Podocarpus oleifolius", "Quercus humboldtii", "Weinmannia pubescens",
    "Hedyosmum racemosum", "Brunellia comocladifolia", "Cyathea caracasana",
    "Oreopanax floribundum", "Anthurium magnificum"
  ),
  "Bosque Nublado" = c(
    "Polylepis quadrijuga", "Clusia multiflora", "Diplostephium revolutum",
    "Hypericum laricifolium", "Befaria resinosa", "Blechnum cordatum",
    "Epidendrum elongatum", "Stelis sp."
  ),
  "Paramo" = c(
    "Espeletia schultzii", "Calamagrostis effusa", "Paepalanthus karstenii",
    "Puya goudotiana", "Lycopodium clavatum", "Gentiana sedifolia",
    "Werneria pygmaea", "Draba litamo"
  )
)

especie <- mapply(function(zona) {
  sample(especies_por_zona[[zona]], 1)
}, zona_vida)

# --- Ensamblar dataset -------------------------------------------------------
biodiversidad_sierra <- data.frame(
  especie          = as.character(especie),
  altura_msnm      = as.integer(altura_msnm),
  temperatura_C    = temperatura_C,
  humedad_relativa = humedad_relativa,
  zona_vida        = factor(zona_vida, levels = zonas),
  stringsAsFactors = FALSE
)

# Ordenar por altura
biodiversidad_sierra <- biodiversidad_sierra[order(biodiversidad_sierra$altura_msnm), ]
rownames(biodiversidad_sierra) <- NULL

# --- Guardar CSV -------------------------------------------------------------
ruta_salida <- file.path("data", "biodiversidad_sierra.csv")
write.csv(biodiversidad_sierra, ruta_salida, row.names = FALSE, fileEncoding = "UTF-8")

cat("✓ Dataset generado:", ruta_salida, "\n")
cat("  Observaciones:", nrow(biodiversidad_sierra), "\n")
cat("  Variables:", ncol(biodiversidad_sierra), "\n")
cat("  Distribución por zona de vida:\n")
print(table(biodiversidad_sierra$zona_vida))
cat("  Rango de alturas:", range(biodiversidad_sierra$altura_msnm), "msnm\n")
cat("  Rango de temperatura:", range(biodiversidad_sierra$temperatura_C), "°C\n")
