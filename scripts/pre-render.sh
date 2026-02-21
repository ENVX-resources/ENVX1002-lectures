#!/bin/bash
# Clean _site and stale HTML from source dirs before rendering
rm -rf _site
find lectures -name "*.html" -not -name "index.html" -delete 2>/dev/null
find lectures -name "*_files" -type d -exec rm -rf {} + 2>/dev/null
echo "Cleaned _site/ and stale render artifacts"
