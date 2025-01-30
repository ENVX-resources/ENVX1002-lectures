# This script automatically detects whether the user is on a Windows or Mac OS
# and if so, it will search for an html file in the current directory and
# convert it to a pdf file with the same name. Requires the chromote and
# renderthis packages to be installed, which are most likely already installed
# if you are using the renv package and you have run either `renv::restore()` or
# `renv::snapshot()`.

# Yuu can run this script postrender in Quarto by uncommenting the postrender
# line in the _quarto.yml file, but it will add about 10 seconds to the render
# time.

convert_html_to_pdf <- function(html_dir, pdf_dir) {
  library(chromote)
  library(renderthis)

  # Find all HTML files in the specified directory
  html_files <- grep("lecture-.*\\.html$",
    list.files(html_dir,
      recursive = TRUE,
      pattern = ".html"
    ),
    value = TRUE
  )

  # Present list of files to user and get selection
  cat("\nAvailable files:\n")
  for (i in seq_along(html_files)) {
    cat(i, ": ", html_files[i], "\n")
  }
  cat("\nSelect files (comma-sep) or Enter for all:\n")
  selection <- readline()

  # Process user selection
  if (nchar(selection) > 0) {
    # Check if input contains non-numeric characters (excluding commas)
    if (grepl("[^0-9,]", selection)) {
      stop("Invalid input. Please enter only numbers separated by commas.")
    }
    selected_indices <- as.numeric(strsplit(selection, ",")[[1]])
    if (any(selected_indices > length(html_files)) || any(selected_indices < 1)) {
      stop("Invalid selection. Please enter numbers between 1 and ", length(html_files))
    }
    html_files <- html_files[selected_indices]
  }

  pdf_files <- sub(".html", ".pdf", html_files)
  # Initialize vectors to store conversion results
  failed_conversions <- character(0)
  successful_conversions <- character(0)

  # Try converting selected files
  for (i in seq_along(html_files)) {
    html_file <- file.path(html_dir, html_files[i])
    pdf_file <- file.path(pdf_dir, pdf_files[i])

    # Create directory if it doesn't exist
    dir.create(dirname(pdf_file), showWarnings = FALSE, recursive = TRUE)

    tryCatch(
      {
        to_pdf(html_file, pdf_file)
        Sys.sleep(1) # Add 1 second pause
        successful_conversions <<- c(successful_conversions, html_files[i])
      },
      error = function(e) {
        failed_conversions <<- c(failed_conversions, html_files[i])
      }
    )
  }

  # Report failed conversions if any
  if (length(failed_conversions) > 0) {
    cat(
      "\nFailed to convert some HTML files to PDF.",
      "\nTo fix, enable `embed-resources: true` in YAML and re-render.",
      "\nThen, run this script again to convert the PDFs.\n"
    )
  }
}

# Example usage:
convert_html_to_pdf("_site/lectures", "lectures")

