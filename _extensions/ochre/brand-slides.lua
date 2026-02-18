-- Brand Slides Filter
-- Pipeline position: SECOND. Transforms branded slide headers into raw Typst/RevealJS blocks.
-- Handles .brand-slide-quote and background-image split layout slides.

-- We need to process at the Blocks level to capture content after headers

-- Collect body blocks after a header until the next H1/H2 or end of document
local function collect_body_blocks(blocks, start_index)
    local body_blocks = {}
    local j = start_index
    while j <= #blocks do
        local next_block = blocks[j]
        if next_block.t == "Header" and next_block.level <= 2 then
            break
        end
        table.insert(body_blocks, next_block)
        j = j + 1
    end
    return body_blocks, j
end

-- Convert a list of Pandoc blocks to a Typst string (trailing newline stripped)
local function blocks_to_typst(block_list)
    if #block_list == 0 then
        return ""
    end
    local doc = pandoc.Pandoc(block_list)
    return pandoc.write(doc, "typst"):gsub("\n$", "")
end

local function download_image(url)
    if not (url:match("^http://") or url:match("^https://")) then
        return url
    end

    local mime, content = pandoc.mediabag.fetch(url)
    if not content then
        print("Warning: Could not fetch image: " .. url)
        return url
    end

    -- Create cache dir
    os.execute("mkdir -p .ochre-cache")

    -- Determine extension
    local ext = "jpg"
    if mime then
        local found = mime:match("/(%w+)")
        if found then ext = found end
    end

    -- Simple filename generation
    local name = url:gsub("https?://", ""):gsub("[^%w]", "-")
    if #name > 50 then name = name:sub(-50) end
    local filename = ".ochre-cache/" .. name .. "." .. ext

    -- Check if exists
    local f = io.open(filename, "r")
    if f then
        f:close()
        return filename
    end

    -- Write to file
    f = io.open(filename, "wb")
    if f then
        f:write(content)
        f:close()
        return filename
    else
        print("Warning: Could not save image to " .. filename)
        return url
    end
end

function Blocks(blocks)
    if not quarto.doc.is_format("typst") then
        return blocks
    end

    local new_blocks = {}
    local i = 1
    while i <= #blocks do
        local block = blocks[i]

        -- Check for level 2 header with .brand-slide-quote
        if block.t == "Header" and block.level == 2 and block.classes:includes('brand-slide-quote') then
            local body_blocks, j = collect_body_blocks(blocks, i + 1)

            local title_typst = blocks_to_typst({ pandoc.Para(block.content) })
            local body_typst = blocks_to_typst(body_blocks)

            -- Insert raw Typst call
            table.insert(new_blocks, pandoc.RawBlock("typst",
                "#ochre_quote_slide(title: [" .. title_typst .. "])[" .. body_typst .. "]"
            ))

            -- Skip past the body blocks we consumed
            i = j

            -- Check for level 2 header with background-image attribute (split layout)
        elseif block.t == "Header" and block.level == 2 and block.attributes["background-image"] then
            local image_url = block.attributes["background-image"]
            local local_image_path = download_image(image_url)
            local bg_color = block.attributes["data-background-color"] or "rgb(\"#8f9ec9\").lighten(70%)"

            local body_blocks, j = collect_body_blocks(blocks, i + 1)
            local body_typst = blocks_to_typst(body_blocks)

            -- Format background color for Typst
            local bg_color_typst
            if bg_color:match("^rgba") then
                -- Convert rgba(r, g, b, a) to Typst rgb().transparentize()
                local r, g, b, a = bg_color:match("rgba%((%d+),%s*(%d+),%s*(%d+),%s*([%d%.]+)%)")
                if r and g and b and a then
                    local transparency = 1 - tonumber(a)
                    bg_color_typst = string.format("rgb(%s, %s, %s).transparentize(%d%%)", r, g, b,
                        math.floor(transparency * 100))
                else
                    bg_color_typst = "rgb(\"#8f9ec9\").lighten(70%)"
                end
            else
                bg_color_typst = "rgb(\"" .. bg_color .. "\")"
            end

            -- Insert raw Typst call
            table.insert(new_blocks, pandoc.RawBlock("typst",
                "#ochre_split_slide(image-path: \"" ..
                local_image_path .. "\", bg-color: " .. bg_color_typst .. ")[" .. body_typst .. "]"
            ))

            -- Skip past the body blocks we consumed
            i = j
        else
            table.insert(new_blocks, block)
            i = i + 1
        end
    end

    return new_blocks
end

-- For RevealJS, we still use the Header filter
function Header(el)
    if el.level ~= 2 then
        return el
    end

    if el.classes:includes('brand-slide-quote') then
        if quarto.doc.is_format("revealjs") then
            el.attributes['data-background-color'] = "#fcede2"
        end
    end

    return el
end
