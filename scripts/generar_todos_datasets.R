# =============================================================================
# SCRIPT MAESTRO: Genera todos los datasets del libro
# =============================================================================
# Ejecutar desde la raíz del proyecto:
#   source("scripts/generar_todos_datasets.R")
# =============================================================================

cat("=== Generando datasets - Libro de Estadística con R ===\n\n")

source("scripts/generar_biodiversidad_sierra.R")
cat("\n")
source("scripts/generar_palma_cesar.R")
cat("\n")
source("scripts/generar_logistica_puerto_baq.R")

cat("\n=== Todos los datasets generados en /data ===\n")
cat("Archivos creados:\n")
for (f in list.files("data", pattern = "\\.csv$", full.names = TRUE)) {
  info <- file.info(f)
  cat(sprintf("  %-40s %.1f KB\n", basename(f), info$size / 1024))
}
