// Ochre Slides Template
// A custom Touying theme for beautiful presentations with University of Sydney branding
// Built from scratch using touying-slides.with() for full customisation control

#import "@preview/touying:0.6.1": *
#import "@preview/scienceicons:0.1.0": orcid-icon, email-icon

// ═══════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════

#let ICON-WIDTH = 0.9em
#let ICON-GAP-EMAIL = 0.2em
#let ICON-GAP-ORCID = 0.15em
#let SECTION-SLIDE-OFFSET = -3em      // optical centering for section slides
#let AFFIL-SPACING-SINGLE = -0.5em    // tighter spacing for single author
#let AFFIL-SPACING-MULTI = 0.6em      // more space for multiple authors

// ═══════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════

// Build affiliation numbering map from author list.
// Returns (all-affiliations: array, affiliation-map: dict).
#let build-affiliation-map(authors) = {
  let all-affiliations = ()
  let affiliation-map = (:)
  let counter = 0
  if authors != none {
    for author in authors {
      if "affiliations" in author and author.affiliations != none {
        for aff in author.affiliations {
          let aff-key = if "name" in aff { repr(aff.name) } else { "" }
          if aff-key not in affiliation-map {
            counter += 1
            affiliation-map.insert(aff-key, counter)
            all-affiliations.push(aff)
          }
        }
      }
    }
  }
  (all-affiliations: all-affiliations, affiliation-map: affiliation-map)
}

// Render a single author with name, superscripts, and clickable icons
#let render-author(author, idx, authors-count, affiliation-map, show-email, show-orcid) = {
  if idx > 0 { h(0.4em); sym.bullet; h(0.4em) }

  let has-email = show-email and "email" in author and author.email != none
  let has-orcid = show-orcid and "orcid" in author and author.orcid != none

  // Invisible spacer on left to balance icons on right
  if has-email and has-orcid {
    h(ICON-GAP-EMAIL + ICON-WIDTH + ICON-GAP-ORCID + ICON-WIDTH)
  } else if has-email {
    h(ICON-GAP-EMAIL + ICON-WIDTH)
  } else if has-orcid {
    h(ICON-GAP-ORCID + ICON-WIDTH)
  }

  // First author is bold
  if idx == 0 {
    strong[#author.name]
  } else {
    author.name
  }

  // Affiliation superscripts (only show if multiple authors)
  if authors-count > 1 and "affiliations" in author and author.affiliations != none {
    let aff-numbers = ()
    for aff in author.affiliations {
      let aff-key = if "name" in aff { repr(aff.name) } else { "" }
      if aff-key in affiliation-map {
        aff-numbers.push(str(affiliation-map.at(aff-key)))
      }
    }
    if aff-numbers.len() > 0 {
      super[#aff-numbers.join(",")]
    }
  }

  // Email icon (clickable)
  if has-email {
    h(ICON-GAP-EMAIL)
    link("mailto:" + author.email)[#email-icon(color: gray, height: ICON-WIDTH, baseline: 15%)]
  }

  // ORCID icon (clickable)
  if has-orcid {
    h(ICON-GAP-ORCID)
    link("https://orcid.org/" + author.orcid)[#orcid-icon(color: rgb("#a6ce39"), height: ICON-WIDTH, baseline: 15%)]
  }
}

// Render affiliation list with optional numbering
#let render-affiliations(all-affiliations, affiliation-map, author-count) = {
  if all-affiliations.len() > 0 {
    let show-numbers = author-count > 1
    let size = if author-count == 1 { 0.9em } else { 0.75em }

    text(size: size, fill: black)[
      #for (idx, aff) in all-affiliations.enumerate() {
        let aff-key = if "name" in aff { repr(aff.name) } else { "" }
        let aff-num = affiliation-map.at(aff-key)

        if show-numbers {
          super[#aff-num]
          h(0.15em)
        }

        let parts = ()
        if "department" in aff and aff.department != none { parts.push(aff.department) }
        if "name" in aff and aff.name != none { parts.push(aff.name) }
        if "city" in aff and aff.city != none { parts.push(aff.city) }
        if "country" in aff and aff.country != none { parts.push(aff.country) }

        parts.join(", ")

        if idx < all-affiliations.len() - 1 { linebreak() }
      }
    ]
  }
}

// ═══════════════════════════════════════════
// SLIDE FUNCTIONS
// ═══════════════════════════════════════════

// Regular content slide with optional header/footer
#let ochre_slide(title: auto, ..args) = touying-slide-wrapper(self => {
  // Update title in store if provided
  if title != auto {
    self.store.title = title
  }

  // Build header
  let header(self) = {
    if self.store.show-header {
      set align(top)
      show: components.cell.with(fill: self.colors.primary, inset: 0.8em)
      set align(horizon)
      set text(fill: self.colors.neutral-lightest, size: 0.7em)
      utils.display-current-heading(level: 1)
      linebreak()
      set text(size: 1.3em)
      if self.store.title != none {
        utils.call-or-display(self, self.store.title)
      } else {
        utils.display-current-heading(level: 2)
      }
    }
  }

  // Build footer
  let footer(self) = {
    if self.store.show-footer {
      set align(bottom)
      show: pad.with(0.4em)
      set text(fill: self.colors.neutral-darkest, size: 0.8em)
      if self.store.footer-text != none {
        utils.call-or-display(self, self.store.footer-text)
      }
      h(1fr)
      if self.store.show-slide-number {
        context utils.slide-counter.display() + " / " + utils.last-slide-number
      }
    }
  }

  // Merge header/footer and subslide-preamble into page config
  self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
    // Add subslide-preamble to show level 2 heading (slide title)
    config-common(
      subslide-preamble: block(
        below: 1.5em,
        text(
          size: 1.2em,
          weight: "bold",
          fill: self.store.heading-color,
          font: self.store.heading-font,
          utils.display-current-heading(level: 2)
        ),
      ),
    ),
  )

  touying-slide(self: self, ..args)
})

// Dedicated quote slide function
#let ochre_quote_slide(title: none, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.store.quote-bg-color,
      margin: 2em,
      header: none,
      footer: none,
    )
  )

  let content = align(center + horizon, {
      // Display title (the quote) in large text
      if title != none {
         set text(fill: self.colors.primary, size: 2em, weight: "regular")
         title
      }
      // Display body below in smaller text
      if body != none and body != [] {
          v(0.8em)
          set text(fill: self.colors.primary, size: 1em, weight: "regular")
          body
      }
  })

  touying-slide(self: self, content)
})

// Split layout slide: left image (40%), right content (60%)
#let ochre_split_slide(
  image-path: none,
  bg-color: none,
  body,
) = touying-slide-wrapper(self => {
  let resolved-bg = if bg-color != none { bg-color } else { self.store.split-bg-color }
  self = utils.merge-dicts(
    self,
    config-page(
      fill: resolved-bg,
      margin: 0em,
      header: none,
      footer: none,
    )
  )

  let slide-content = block(width: 100%, height: 100%, {
    // Left side: image (40% width)
    if image-path != none {
      place(
        left + top,
        block(
          width: 40%,
          height: 100%,
          clip: true,
          image(image-path, width: 100%, height: 100%, fit: "cover")
        )
      )
    }

    // Right side: content (60% width, with padding)
    place(
      right + horizon,
      block(
        width: 60%,
        height: 100%,
        inset: 2em,
        {
          set align(left + horizon)
          body
        }
      )
    )
  })

  touying-slide(self: self, slide-content)
})

// Title slide — orchestrates helpers for author metadata rendering
#let ochre_title_slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let authors = self.store.authors
  let aff-data = build-affiliation-map(authors)

  let body = {
    set align(center + horizon)
    set text(size: self.store.fontsize, fill: self.colors.primary)

    // Logo (if provided)
    if self.store.title-slide-logo != none {
      image(self.store.title-slide-logo, height: self.store.title-slide-logo-height)
      v(0.8em)
    }

    // Title
    if info.title != none {
      text(size: 1.8em, weight: "bold")[#info.title]
      v(-1.2em)
    }

    // Subtitle
    if info.subtitle != none {
      text(size: 1.2em, weight: "regular")[#info.subtitle]
      v(0.8em)
    }

    // Authors and affiliations
    if authors != none and authors.len() > 0 {
      text(size: 1.05em)[
        #for (idx, author) in authors.enumerate() {
          render-author(
            author, idx, authors.len(),
            aff-data.affiliation-map,
            self.store.show-author-email,
            self.store.show-author-orcid,
          )
        }
      ]

      if authors.len() == 1 {
        v(AFFIL-SPACING-SINGLE)
      } else {
        v(AFFIL-SPACING-MULTI)
      }

      render-affiliations(aff-data.all-affiliations, aff-data.affiliation-map, authors.len())
    }

    // Date
    if info.date != none {
      v(0.8em)
      text(size: 0.9em, fill: black)[#info.date]
    }
  }

  touying-slide(self: self, body)
})

// Section slide — displays section heading with optional body content
#let ochre_section_slide(config: (:), body) = touying-slide-wrapper(self => {
  // Clean slide: symmetric margins, no header/footer
  self = utils.merge-dicts(self, config-page(
    margin: (x: 2em, y: 2em),
    header: none,
    footer: none,
  ))

  let has-body = body != none and body != []

  let slide-content = block(width: 100%, height: 100%, {
    set align(center + horizon)
    v(SECTION-SLIDE-OFFSET)

    // Section heading
    text(
      size: self.store.section-slide-size,
      fill: self.colors.primary,
      weight: "bold",
    )[#utils.display-current-heading(level: 1)]

    // Optional body content
    if has-body {
      v(0.3em)
      set text(size: 1em, weight: "regular", fill: black)
      body
    }
  })

  touying-slide(self: self, config: config, slide-content)
})

// Focus slide — full-screen emphasis
#let ochre_focus_slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.primary,
      margin: 2em,
    ),
  )
  set text(fill: self.colors.neutral-lightest, size: 2em)
  touying-slide(self: self, align(horizon + center, body))
})

// ═══════════════════════════════════════════
// MAIN THEME
// ═══════════════════════════════════════════

#let ochre_slides(
  // Metadata parameters
  title: none,
  subtitle: none,
  authors: none,
  date: none,

  // Branding parameters
  primary-color: rgb("#e64626"),      // Ochre orange
  secondary-color: rgb("#9370DB"),    // Light purple
  logo: none,
  logo-height: 2em,

  // Layout parameters
  aspect-ratio: "16-9",

  // Typography parameters
  font: "Lato",
  fontsize: 16pt,
  heading-font: "Crimson Pro",
  heading-color: none,

  // Section slide customization
  section-slide-size: 2em,

  // Header/Footer customization
  show-header: false,
  show-footer: true,
  footer-text: none,
  show-slide-number: true,

  // Title slide customization
  show-title-slide: true,
  title-slide-logo: none,
  title-slide-logo-height: 3em,
  show-author-email: true,
  show-author-orcid: true,

  // Theme colour overrides
  quote-bg-color: rgb("#fcede2"),        // Sandstone — quote slide background
  split-bg-color: rgb("#8f9ec9").lighten(70%),  // Light Jacaranda — split slide background
  code-color: rgb("#1a355e"),            // Navy — inline code text colour

  // Document content
  doc,
) = {

  // Set default heading color to primary color if not specified
  let heading-color = if heading-color == none { primary-color } else { heading-color }

  // Apply base text settings
  set text(
    font: font,
    size: fontsize,
  )

  // Apply Touying slides framework
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: ochre_slide,
      new-section-slide-fn: ochre_section_slide,
      receive-body-for-new-section-slide-fn: true,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: primary-color,
      secondary: secondary-color,
      neutral-lightest: white,
      neutral-darkest: black,
    ),
    config-info(
      title: title,
      subtitle: subtitle,
      date: date,
      logo: logo,
    ),
    config-store(
      // Header/Footer settings
      title: none,
      show-header: show-header,
      show-footer: show-footer,
      footer-text: footer-text,
      show-slide-number: show-slide-number,
      // Title slide settings
      authors: authors,
      fontsize: fontsize,
      title-slide-logo: title-slide-logo,
      title-slide-logo-height: title-slide-logo-height,
      show-author-email: show-author-email,
      show-author-orcid: show-author-orcid,
      // Section slide settings
      section-slide-size: section-slide-size,
      // Typography
      heading-font: heading-font,
      heading-color: heading-color,
      // Theme colours
      quote-bg-color: quote-bg-color,
      split-bg-color: split-bg-color,
      code-color: code-color,
    ),
  )

  // Customize headings with brand colors
  show heading.where(level: 1): set text(
    font: heading-font,
    fill: heading-color,
    size: 2em,
  )

  show heading.where(level: 2): set text(
    font: heading-font,
    fill: heading-color,
    size: 1.4em,
  )

  // Level 3: Bold, slightly smaller than slide title
  show heading.where(level: 3): set text(
    font: heading-font,
    fill: heading-color,
    size: 1.2em,
    weight: "bold",
  )

  // Level 4: Semibold, smaller
  show heading.where(level: 4): set text(
    font: heading-font,
    fill: heading-color,
    size: 1em,
    weight: "semibold",
  )

  // Level 5: Italic for visual distinction
  show heading.where(level: 5): set text(
    font: heading-font,
    fill: heading-color,
    size: 1em,
    style: "italic",
  )

  // Level 6: Smallest, using underline for distinction
  show heading.where(level: 6): it => text(
    font: heading-font,
    fill: heading-color,
    size: 0.9em,
    weight: "regular",
  )[#underline(it.body)]

  // Override touying's styling of bold text with primary color
  show strong: set text(fill: black)

  // Custom blockquote styling
  show quote: it => {
    set text(weight: 200)
    pad(left: 1em, block(
      stroke: (left: 4pt + primary-color),
      inset: (left: 0.8em, top: 0.2em, bottom: 0.2em),
      it.body
    ))
  }

  // Custom inline code styling
  show raw.where(block: false): it => {
    box(
      fill: secondary-color.lighten(85%),
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
      [#text(fill: code-color, it)]
    )
  }

  // Center tables by default
  show figure.where(kind: table): set align(center)
  show table: set align(center)

  // Render title slide if enabled
  if show-title-slide and (title != none or authors != none) {
    ochre_title_slide()
  }

  // Render document content
  doc
}
