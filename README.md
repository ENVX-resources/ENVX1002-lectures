# ENVX1002 Lectures

Lecture slides for ENVX1002 (Statistics in Life and Environmental Sciences) at the University of Sydney. Built with [Quarto](https://quarto.org/).

## What's in here

The course runs through three modules across 12 weeks:

1. Describing data (L01--L04): R programming, data visualisation, the central limit theorem
2. Inference (L05--L08): hypothesis testing, two-sample tests, non-parametric tests, bootstrapping
3. Modelling (L09--L12): correlation, simple and multiple linear regression, non-linear regression

Each lecture lives in `lectures/L{01..12}/` with its QMD source and a PDF export.

## Setup

You need R, Quarto, and a code editor (RStudio or VS Code). RStudio ships with Quarto, so if you use that you're already set.

```bash
git clone <this-repo>
```

Then restore the R environment and render:

```r
renv::restore()
```

```bash
quarto render
```

To preview while editing:

```bash
quarto preview
```

## Contributing

Fork the repo, create a branch, make your changes, and open a pull request. If something looks wrong in the lectures, open an issue.

## Licence

[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](LICENSE)

[![CC BY-NC-SA 4.0](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](LICENSE)

## Contact

Open an issue, or check Canvas for the coordinator's email.
