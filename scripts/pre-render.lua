-- Clean _site and stale render artifacts before rendering
os.execute('rm -rf _site 2>/dev/null || rmdir /s /q _site 2>nul')

local function find_and_delete(dir, pattern, exclude)
  local cmd
  if package.config:sub(1, 1) == '\\' then
    -- Windows
    cmd = 'dir /s /b "' .. dir .. '\\' .. pattern .. '" 2>nul'
  else
    -- Unix
    cmd = 'find "' .. dir .. '" -name "' .. pattern .. '" 2>/dev/null'
  end
  local handle = io.popen(cmd)
  if not handle then return end
  for path in handle:lines() do
    local name = path:match('[/\\]([^/\\]+)$') or path
    if not (exclude and name == exclude) then
      os.remove(path)
    end
  end
  handle:close()
end

local function remove_dirs(dir, pattern)
  local cmd
  if package.config:sub(1, 1) == '\\' then
    cmd = 'for /d /r "' .. dir .. '" %D in (' .. pattern .. ') do rmdir /s /q "%D" 2>nul'
  else
    cmd = 'find "' .. dir .. '" -name "' .. pattern .. '" -type d -exec rm -rf {} + 2>/dev/null'
  end
  os.execute(cmd)
end

find_and_delete('lectures', '*.html', 'index.html')
remove_dirs('lectures', '*_files')
print('Cleaned _site/ and stale render artifacts')
