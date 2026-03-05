-- Copy typst PDFs from _site to source directories for committing
local sep = package.config:sub(1, 1)
local is_windows = sep == '\\'

local function list_dirs(path)
  local dirs = {}
  local cmd
  if is_windows then
    cmd = 'dir /ad /b "' .. path .. '" 2>nul'
  else
    cmd = 'ls -d "' .. path .. '"/*/ 2>/dev/null'
  end
  local handle = io.popen(cmd)
  if not handle then return dirs end
  for line in handle:lines() do
    local name = line:match('([^/\\]+)[/\\]?$')
    if name and name:match('^L%d') then
      table.insert(dirs, name)
    end
  end
  handle:close()
  return dirs
end

local function list_pdfs(path)
  local pdfs = {}
  local cmd
  if is_windows then
    cmd = 'dir /b "' .. path .. sep .. '*.pdf" 2>nul'
  else
    cmd = 'ls "' .. path .. '"/*.pdf 2>/dev/null'
  end
  local handle = io.popen(cmd)
  if not handle then return pdfs end
  for line in handle:lines() do
    local name = line:match('([^/\\]+)$')
    if name then
      table.insert(pdfs, name)
    end
  end
  handle:close()
  return pdfs
end

local function copy_file(src, dst)
  if is_windows then
    os.execute('copy "' .. src .. '" "' .. dst .. '" >nul 2>nul')
  else
    os.execute('cp "' .. src .. '" "' .. dst .. '"')
  end
end

for _, lecture in ipairs(list_dirs('_site/lectures')) do
  local site_dir = '_site/lectures/' .. lecture
  local src_dir = 'lectures/' .. lecture
  for _, pdf in ipairs(list_pdfs(site_dir)) do
    copy_file(site_dir .. '/' .. pdf, src_dir .. '/' .. pdf)
    print('Copied: ' .. pdf .. ' → ' .. src_dir .. '/')
  end
end
