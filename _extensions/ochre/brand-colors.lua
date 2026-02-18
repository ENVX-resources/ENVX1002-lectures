-- Brand Colors and Typography Filter
-- Pipeline position: FIRST. Injects CSS-style attributes into brand-coloured spans.
-- Downstream: typst-utils.lua parses these attributes into Typst code.
-- Maps .brand-{color} classes to inline style attributes (Typst) or CSS (RevealJS).
-- Maps .brand-base-font and .brand-heading-font to dynamic font display.

-- Placeholder for brand configuration
local brand_config = {
  colors = {
    ochre = "#e64626",
    lightgrey = "#f1f1f1",
    charcoal = "#424242",
    white = "#ffffff",
    black = "#000000",
    sandstone = "#fcede2",
    heritagerose = "#daa8a2",
    jacaranda = "#8f9ec9",
    navy = "#1a355e",
    eucalypt = "#71a499"
  },
  fonts = {
    base = "Lato",
    headings = "Crimson Pro"
  }
}

-- Capture metadata to override defaults
function Meta(m)
  if m.brand and m.brand.typography then
    if m.brand.typography.base and m.brand.typography.base.family then
      brand_config.fonts.base = pandoc.utils.stringify(m.brand.typography.base.family)
    end
    if m.brand.typography.headings and m.brand.typography.headings.family then
      brand_config.fonts.headings = pandoc.utils.stringify(m.brand.typography.headings.family)
    end
  end
  if m.brand and m.brand.color and m.brand.color.palette then
    for name, value in pairs(m.brand.color.palette) do
      local key = pandoc.utils.stringify(name)
      local hex = pandoc.utils.stringify(value)
      if hex:match("^#") then
        brand_config.colors[key] = hex
      end
    end
  end
  return m
end

-- Process Span elements
function Span(el)
  local is_typst = quarto.doc.is_format("typst")
  local is_html_output = quarto.doc.is_format("revealjs") or quarto.doc.is_format("html")

  -- Only process for Typst or RevealJS/HTML output
  if not (is_typst or is_html_output) then
    return el
  end

  for _, class in ipairs(el.classes) do
    -- Handle Typography Display
    if class == "brand-base-font" or class == "brand-heading-font" then
      local font = (class == "brand-base-font") and brand_config.fonts.base or brand_config.fonts.headings
      local fallback = (class == "brand-base-font") and "sans-serif" or "serif"

      if is_typst then
        -- Inject into style attribute so typst-utils.lua can pick it up
        local current_style = el.attributes['style'] or ""
        el.attributes['style'] = current_style .. "; font-family: " .. font .. ";"
      elseif is_html_output then
        local current_style = el.attributes['style'] or ""
        el.attributes['style'] = current_style .. string.format("; font-family: '%s', %s;", font, fallback)
      end
    end

    -- Handle Brand Colors
    if class:match("^brand%-") then
      local is_highlight = false
      local color_name = class:gsub("^brand%-", "")

      -- Check for -highlight suffix
      if color_name:match("%-highlight$") then
        is_highlight = true
        color_name = color_name:gsub("%-highlight$", "")
      end

      local color_value = brand_config.colors[color_name]

      if color_value then
        if is_typst then
          -- Inject into style attribute so typst-utils.lua can pick it up
          local current_style = el.attributes['style'] or ""
          local style_to_add = ""

          if is_highlight then
            -- For highlight, we set background-color and text color to black (per original design)
            style_to_add = string.format("background-color: %s; color: black;", color_value)
          else
            style_to_add = string.format("color: %s;", color_value)
          end

          el.attributes['style'] = current_style .. "; " .. style_to_add
        elseif is_html_output then
          local style_to_add = is_highlight
              and
              string.format(
                "background-color: %s !important; color: black !important; padding: 0.1em 0.3em; border-radius: 0.25em;",
                color_value)
              or string.format("color: %s !important;", color_value)

          local current_style = el.attributes['style'] or ""
          el.attributes['style'] = current_style .. "; " .. style_to_add
        end
      end
    end
  end
  return el
end
