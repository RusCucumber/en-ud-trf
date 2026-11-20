#!/bin/bash
set -euo pipefail

f="notebooks/R/$(date +%Y%m%d-%H%M%S).qmd"
cp notebooks/R/template/template.qmd "$f"
echo "Created: $f"
