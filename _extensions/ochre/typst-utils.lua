-- Typst Utilities Filter
-- Pipeline position: THIRD (Typst only). Converts CSS style attributes to Typst #text()/#highlight() calls.
-- Upstream: Requires brand-colors.lua to have injected style attributes first.

-- Helper to check for typst format
local function is_typst()
    return quarto.doc.is_format("typst")
end

-- =============================================================================
-- Feature: CSS-like Styles for Spans
-- =============================================================================
function Span(el)
    if not is_typst() then
        return nil
    end

    local style = el.attributes['style']
    if not style then
        return nil
    end

    local props = {}
    local bg_color = nil

    -- Helper to add property
    local function add_prop(p) props[#props + 1] = p end

    for key, value in style:gmatch("([%w%-]+)%s*:%s*(.-);") do
        value = value:match("^%s*(.-)%s*$") -- Trim whitespace

        if key == "font-size" then
            add_prop('size: ' .. value)
        elseif key == "font-weight" then
            local num = tonumber(value)
            if num then
                add_prop('weight: ' .. math.floor(num))
            elseif value == "bold" then
                add_prop('weight: "bold"')
            else
                add_prop('weight: "' .. value .. '"')
            end
        elseif key == "font-style" then
            add_prop('style: "' .. value .. '"')
        elseif key == "font-family" then
            -- Remove quotes if they exist, Typst expects string but we want to ensure clean value
            value = value:gsub("^['\"]", ""):gsub("['\"]$", "")
            add_prop('font: "' .. value .. '"')
        elseif key == "color" then
            if value:match("^#") then
                add_prop('fill: rgb("' .. value .. '")')
            else
                add_prop('fill: ' .. value)
            end
        elseif key == "background-color" then
            if value:match("^#") then
                bg_color = 'rgb("' .. value .. '")'
            else
                bg_color = value
            end
        end
    end

    if #props > 0 or bg_color then
        -- Use pandoc.write to preserve inner formatting (e.g. italics, bold)
        local doc = pandoc.Pandoc(el.content)
        local content = pandoc.write(doc, 'typst'):gsub("^%s+", ""):gsub("%s+$", "")

        local typst_code = content

        if #props > 0 then
            typst_code = '#text(' .. table.concat(props, ", ") .. ')[' .. typst_code .. ']'
        end

        if bg_color then
            typst_code = '#highlight(fill: ' .. bg_color .. ', extent: 2pt)[' .. typst_code .. ']'
        end

        return pandoc.RawInline('typst', typst_code)
    end

    return nil
end

-- =============================================================================
-- Feature: Multi-column Layouts
-- =============================================================================
function Div(el)
    if not is_typst() then
        return nil
    end

    -- Check if this is a columns div
    if not el.classes:includes("columns") then
        return nil
    end

    local start_grid = '#grid(\n  columns: ('
    local end_grid = '),\n  gutter: 1em,\n'

    local widths = {}
    local columns_content = {}

    -- Iterate through children to find 'column' divs
    for _, child in ipairs(el.content) do
        if child.t == "Div" and child.classes:includes("column") then
            -- Extract width
            local width = child.attributes['width']
            if width then
                table.insert(widths, width)
            else
                table.insert(widths, "1fr")
            end

            -- We need to wrap the content in [ ] so it's treated as content block in Typst
            -- We insert a raw '[' before and '],' after the content blocks
            local content_blocks = {}
            table.insert(content_blocks, pandoc.RawBlock('typst', '['))
            for _, block in ipairs(child.content) do
                table.insert(content_blocks, block)
            end
            table.insert(content_blocks, pandoc.RawBlock('typst', '],'))

            table.insert(columns_content, content_blocks)
        end
    end

    -- Construct the final block list
    local result = {}

    -- header: #grid(columns: (w1, w2, ...), gutter: 1em,
    local header_str = start_grid .. table.concat(widths, ", ") .. end_grid
    table.insert(result, pandoc.RawBlock('typst', header_str))

    -- Flatten the content columns
    for _, col_blocks in ipairs(columns_content) do
        for _, block in ipairs(col_blocks) do
            table.insert(result, block)
        end
    end

    -- footer: )
    table.insert(result, pandoc.RawBlock('typst', ')'))

    return result
end
