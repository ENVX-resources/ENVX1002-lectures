# This script automatically detects whether the user is on a Windows or Mac OS
# and if so, it will search for an html file in the current directory and 
# convert it to a pdf file with the same name. Requires the chromote and
# renderthis packages to be installed, which are most likely already installed
# if you are using the renv package and you have run either `renv::restore()` or
# `renv::snapshot()`.

# Yuu can run this script postrender in Quarto by uncommenting the postrender
# line in the _quarto.yml file, but it will add about 10 seconds to the render
# time.

get_os <- function() {
  if (.Platform$OS.type == "windows") { 
    "win"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "mac" 
  } else if (.Platform$OS.type == "unix") { 
    "unix"
  } else {
    stop("Unknown OS")
  }
}

# if os is not mac or windows, do not run code

if (get_os() == "mac" | get_os() == "win") {
  cat("✔", get_os(), "OS detected...\n")
  library(chromote)
  library(renderthis)
  # find html file from current directory and save its name as a variable
  html_file <- list.files(pattern = ".html")
  # create new variable with the name of the html file but with the .pdf extension
  pdf_file <- sub(".html", ".pdf", html_file)
  # convert the html file to a pdf file
  to_pdf(html_file, pdf_file)
  cat("ℹ Remember to stage and commit the pdf file to GitHub!\n")
} else {
  print("❌ Auto render is restricted to Windows or Mac OS")
}

