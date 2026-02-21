#!/bin/bash
# Copy typst PDFs from _site to source directories for committing
for dir in _site/lectures/L*/; do
  [ -d "$dir" ] || continue
  lecture=$(basename "$dir")
  for pdf in "$dir"*.pdf; do
    [ -f "$pdf" ] || continue
    cp "$pdf" "lectures/$lecture/"
    echo "Copied: $(basename "$pdf") → lectures/$lecture/"
  done
done
