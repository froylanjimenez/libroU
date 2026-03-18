#!/usr/bin/env bash
# =============================================================================
# compile.sh — Sistema de compilación: Estadística con R
# =============================================================================
# USO:
#   ./scripts/compile.sh            # Compilación completa
#   ./scripts/compile.sh --fast     # Una sola pasada pdflatex (sin TOC/refs)
#   ./scripts/compile.sh --clean    # Solo limpiar auxiliares
#   ./scripts/compile.sh --convert  # Solo convertir MD → TeX (sin compilar)
#
# DEPENDENCIAS: pandoc >= 2.0, pdflatex (TeX Live/MiKTeX), R (opcional)
# EJECUTAR desde la raíz del proyecto.
# =============================================================================

set -euo pipefail   # Salir en error; variables no declaradas son error

# --- Colores para terminal ---------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_step()    { echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}"; }

# --- Directorios del proyecto ------------------------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPITULOS_MD="${ROOT_DIR}/capitulos"
CAPITULOS_TEX="${ROOT_DIR}/latex/capitulos"
LATEX_DIR="${ROOT_DIR}/latex"
OUTPUT_DIR="${ROOT_DIR}/output"
SCRIPTS_DIR="${ROOT_DIR}/scripts"

PDF_FINAL="${OUTPUT_DIR}/libro_estadistica_r.pdf"
MAIN_TEX="${LATEX_DIR}/main.tex"

# --- Verificar dependencias --------------------------------------------------
check_deps() {
  log_step "Verificando dependencias"

  for cmd in pandoc lualatex; do
    if command -v "$cmd" &>/dev/null; then
      version=$("$cmd" --version 2>&1 | head -1)
      log_ok "$cmd encontrado: $version"
    else
      log_error "$cmd no encontrado. Instalar y volver a ejecutar."
    fi
  done
}

# --- Convertir Markdown a LaTeX con Pandoc -----------------------------------
convert_md_to_tex() {
  log_step "Convirtiendo Markdown → LaTeX (Pandoc)"

  mkdir -p "${CAPITULOS_TEX}"

  # Mapa: archivo MD → archivo TEX de salida
  declare -A CAPITULOS=(
    ["cap01_introduccion_r.md"]="cap01"
    ["cap02_estadistica_descriptiva.md"]="cap02"
    ["cap03_inferencia_estadistica.md"]="cap03"
    ["cap04_regresion_modelos.md"]="cap04"
  )

  for md_file in "${!CAPITULOS[@]}"; do
    tex_name="${CAPITULOS[$md_file]}"
    src="${CAPITULOS_MD}/${md_file}"
    dst="${CAPITULOS_TEX}/${tex_name}.tex"

    if [[ ! -f "$src" ]]; then
      log_warn "No encontrado: $src — saltando"
      continue
    fi

    log_info "Convirtiendo: $(basename $src) → $(basename $dst)"

    pandoc "$src" \
      --from=markdown+tex_math_dollars+raw_tex \
      --to=latex \
      --template="${LATEX_DIR}/pandoc_template.tex" \
      --listings \
      --highlight-style=tango \
      --top-level-division=chapter \
      --wrap=preserve \
      --output="$dst"

    # Post-procesamiento: ajustes de compatibilidad
    # 1. Reemplazar \begin{verbatim}/lstlisting para compatibilidad
    # 2. Quitar encabezado redundante que Pandoc pueda añadir
    sed -i \
      -e 's/\\begin{Shaded}/\\begin{lstlisting}/g' \
      -e 's/\\end{Shaded}/\\end{lstlisting}/g' \
      -e 's/\\begin{Highlighting}\[\]//' \
      -e 's/\\end{Highlighting}//' \
      "$dst"

    log_ok "  → ${dst}"
  done
}

# --- Compilar con pdflatex ---------------------------------------------------
compile_pdf() {
  local pasadas=${1:-2}
  log_step "Compilando PDF con pdflatex ($pasadas pasada(s))"

  mkdir -p "${OUTPUT_DIR}"

  # pdflatex debe ejecutarse desde latex/ para que los \input{capitulos/...}
  # resuelvan correctamente. Los auxiliares quedan en latex/ y el PDF en output/.
  cd "${LATEX_DIR}"

  for i in $(seq 1 "$pasadas"); do
    log_info "Pasada $i de $pasadas..."
    lualatex \
      -interaction=nonstopmode \
      -halt-on-error \
      main.tex \
      2>&1 | tail -5
  done

  # pdflatex escribe main.pdf en el directorio de trabajo (latex/)
  local pdf_generado="${LATEX_DIR}/main.pdf"
  if [[ -f "$pdf_generado" ]]; then
    cp "$pdf_generado" "${PDF_FINAL}"
    # Copiar también el log a output/
    [[ -f "${LATEX_DIR}/main.log" ]] && cp "${LATEX_DIR}/main.log" "${OUTPUT_DIR}/main.log"
    log_ok "PDF generado: ${PDF_FINAL}"
    size=$(du -h "${PDF_FINAL}" | cut -f1)
    pages=$(pdfinfo "${PDF_FINAL}" 2>/dev/null | grep Pages | awk '{print $2}' || echo "?")
    log_info "Tamaño: ${size} | Páginas: ${pages}"
  else
    log_error "No se generó el PDF. Revisar ${LATEX_DIR}/main.log"
  fi

  cd "${ROOT_DIR}"
}

# --- Limpiar archivos auxiliares de LaTeX ------------------------------------
clean_aux() {
  log_step "Limpiando archivos auxiliares"
  local ext_list=(aux log toc lof lot out bbl blg idx ind ilg fls fdb_latexmk synctex.gz)

  local count=0
  for ext in "${ext_list[@]}"; do
    # Limpiar en output/ y latex/
    for dir in "${OUTPUT_DIR}" "${LATEX_DIR}"; do
      while IFS= read -r -d '' f; do
        rm -f "$f"
        ((count++))
      done < <(find "$dir" -maxdepth 1 -name "*.${ext}" -print0 2>/dev/null)
    done
  done

  log_ok "Eliminados ${count} archivo(s) auxiliar(es)"
}

# --- Mostrar resumen final ---------------------------------------------------
show_summary() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║     Estadística con R — Compilación completada      ║${NC}"
  echo -e "${BOLD}╠══════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}║${NC}  PDF: output/libro_estadistica_r.pdf                ${BOLD}║${NC}"

  if [[ -f "${PDF_FINAL}" ]]; then
    size=$(du -h "${PDF_FINAL}" | cut -f1)
    echo -e "${BOLD}║${NC}  Tamaño: ${size}                                      ${BOLD}║${NC}"
  fi

  echo -e "${BOLD}║${NC}  Capítulos convertidos: 4                           ${BOLD}║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
}

# --- Función para generar datasets R (opcional) ------------------------------
generate_datasets() {
  if command -v Rscript &>/dev/null; then
    log_step "Generando datasets R (reproducibles)"
    Rscript "${SCRIPTS_DIR}/generar_todos_datasets.R"
  else
    log_warn "Rscript no encontrado. Datasets no regenerados."
  fi
}

# =============================================================================
# PUNTO DE ENTRADA PRINCIPAL
# =============================================================================
main() {
  echo -e "${BOLD}${CYAN}"
  echo "  ╔═══════════════════════════════════════════╗"
  echo "  ║   Estadística con R: Fundamentos y App.  ║"
  echo "  ║   Sistema de Compilación LaTeX            ║"
  echo "  ╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  local mode="${1:-full}"

  case "$mode" in
    --clean)
      clean_aux
      ;;
    --convert)
      check_deps
      convert_md_to_tex
      ;;
    --fast)
      check_deps
      convert_md_to_tex
      compile_pdf 1
      show_summary
      ;;
    --datasets)
      generate_datasets
      ;;
    full|--full|"")
      check_deps
      generate_datasets
      convert_md_to_tex
      compile_pdf 2       # 2 pasadas para TOC, referencias cruzadas, índices
      clean_aux
      show_summary
      ;;
    --help|-h)
      echo "Uso: $0 [opcion]"
      echo ""
      echo "Opciones:"
      echo "  (ninguna)   Compilación completa: datasets + conversión + PDF (2 pasadas)"
      echo "  --fast      Conversión + PDF (1 pasada, sin TOC/refs actualizados)"
      echo "  --convert   Solo convertir MD → TeX"
      echo "  --datasets  Solo regenerar datasets R"
      echo "  --clean     Eliminar archivos auxiliares de LaTeX"
      echo "  --help      Mostrar esta ayuda"
      ;;
    *)
      log_error "Opción desconocida: $mode. Usar --help para ver opciones."
      ;;
  esac
}

main "${1:-}"
