
// Typst show file for ochre slides template
// Maps Pandoc/Quarto metadata to ochre-slides() function parameters

#let brand-base-font = $if(brand.typography.base.family)$ $brand.typography.base.family$ $else$ "Lato" $endif$
#let brand-heading-font = $if(brand.typography.headings.family)$ $brand.typography.headings.family$ $else$ "Crimson Pro" $endif$

#show: doc => ochre_slides(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
    (
      name: [$it.name.literal$],
$if(it.email)$
      email: "$it.email$",
$endif$
$if(it.orcid)$
      orcid: "$it.orcid$",
$endif$
$if(it.url)$
      url: "$it.url$",
$endif$
$if(it.affiliations)$
      affiliations: (
$for(it.affiliations)$
        (
$if(it.name)$
          name: [$it.name$],
$endif$
$if(it.department)$
          department: [$it.department$],
$endif$
$if(it.city)$
          city: "$it.city$",
$endif$
$if(it.country)$
          country: "$it.country$",
$endif$
$if(it.url)$
          url: "$it.url$",
$endif$
        ),
$endfor$
      ),
$endif$
$if(it.attributes.corresponding)$
      corresponding: $it.attributes.corresponding$,
$endif$
    ),
$endfor$
  ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(primary-color)$
  primary-color: rgb("#$primary-color$"),
$elseif(brand.color.primary)$
  primary-color: $brand.color.primary$,
$endif$
$if(secondary-color)$
  secondary-color: rgb("#$secondary-color$"),
$elseif(brand.color.secondary)$
  secondary-color: $brand.color.secondary$,
$endif$
$if(logo)$
  logo: "$logo$",
$elseif(brand.logo.large.path)$
  logo: "$brand.logo.large.path$",
$endif$
$if(logo-height)$
  logo-height: $logo-height$,
$endif$
$if(aspect-ratio)$
  aspect-ratio: "$aspect-ratio$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$elseif(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$elseif(brand.typography.base.size)$
  fontsize: $brand.typography.base.size$,
$endif$
$if(heading-font)$
  heading-font: ("$heading-font$",),
$elseif(brand.typography.headings.family)$
  heading-font: $brand.typography.headings.family$,
$endif$
$if(heading-color)$
  heading-color: rgb("#$heading-color$"),
$elseif(brand.typography.headings.color)$
  heading-color: $brand.typography.headings.color$,
$endif$
$if(show-header)$
  show-header: $show-header$,
$endif$
$if(show-footer)$
  show-footer: $show-footer$,
$endif$
$if(footer-text)$
  footer-text: [$footer-text$],
$endif$
$if(show-slide-number)$
  show-slide-number: $show-slide-number$,
$endif$
$if(show-title-slide)$
  show-title-slide: $show-title-slide$,
$endif$
$if(title-slide-logo)$
  title-slide-logo: "$title-slide-logo$",
$endif$
$if(title-slide-logo-height)$
  title-slide-logo-height: $title-slide-logo-height$,
$endif$
$if(show-author-email)$
  show-author-email: $show-author-email$,
$endif$
$if(show-author-orcid)$
  show-author-orcid: $show-author-orcid$,
$endif$
  doc,
)
