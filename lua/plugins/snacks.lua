return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[
            ▄ ▄                    
        ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄      
        █ ▄ █▄█ ▄▄▄ █ █▄█ █ █      
     ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █      
   ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄   
   █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄ 
 ▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █ 
 █▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █ 
     █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█     
 ]],
        -- stylua: ignore
        ------@type snacks.dashboard.Item[]
        ---keys = {
        ---  { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        ---  { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        ---  { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        ---  { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        ---  { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        ---  { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        ---  { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
        ---  { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        ---  { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        ---},
      },
    },
    terminal = {
      cmd = "pwsh -NoLogo", -- Set default shell to PowerShell
      win = {
        position = "float", -- Open terminal as a floating window
        border = "rounded", -- Optional: Adds a rounded border
        center = true, -- Centers the floating window
        title = "Terminal", -- Set the title
      },
    },

    picker = {
      sources = {
        files = {
          hidden = true, -- Include hidden files in search results
        },
        explorer = {
          hidden = true, -- Always show hidden files in the explorer
        },
      },
    },

    image = {},
  },
  keys = {
    {
      "<leader>td",
      function()
        require("snacks").scratch.open({
          path = vim.fn.expand("~/todos.md"),
          ft = "markdown",
        })
      end,
      desc = "Open Persistent Scratch Buffer",
    },
    {
      "<leader>fd",
      function()
        local function get_drives()
          local drives = {}
          -- Get available drives on Windows using multiple methods
          local success, result = pcall(vim.fn.system, "wmic logicaldisk get caption")
          if success and result then
            for drive in result:gmatch("([A-Z]:)") do
              table.insert(drives, {
                text = "💾 " .. drive .. " (Drive)",
                value = drive,
                path = drive,
                is_drive = true,
              })
            end
          end

          -- Fallback method if wmic fails
          if #drives == 0 then
            -- Try using dir command to list drives
            local dir_success, dir_result = pcall(vim.fn.system, "dir /b")
            if dir_success and dir_result then
              for drive in dir_result:gmatch("([A-Z]:)") do
                table.insert(drives, {
                  text = "💾 " .. drive .. " (Drive)",
                  value = drive,
                  path = drive,
                  is_drive = true,
                })
              end
            end
          end

          -- If still no drives found, add common Windows drives
          if #drives == 0 then
            local common_drives = {
              "C:",
              "D:",
              "E:",
              "F:",
              "G:",
              "H:",
              "I:",
              "J:",
              "K:",
              "L:",
              "M:",
              "N:",
              "O:",
              "P:",
              "Q:",
              "R:",
              "S:",
              "T:",
              "U:",
              "V:",
              "W:",
              "X:",
              "Y:",
              "Z:",
            }
            for _, drive in ipairs(common_drives) do
              -- Check if drive exists
              local test_path = drive .. "\\"
              if vim.fn.isdirectory(test_path) == 1 then
                table.insert(drives, {
                  text = "💾 " .. drive .. " (Drive)",
                  value = drive,
                  path = drive,
                  is_drive = true,
                })
              end
            end
          end

          return drives
        end

        local function browse_directories(start_path)
          -- Get list of directories from the given path
          local dirs = {}
          local cwd = start_path or vim.fn.getcwd()

          -- Check if we're at drive level (e.g., C:\ or /)
          local is_at_drive = cwd:match("^[A-Z]:\\?$") or cwd == "/"

          if not is_at_drive then
            -- Add parent directory option if not at drive level
            local parent = vim.fn.fnamemodify(cwd, ":h")
            table.insert(dirs, {
              text = "⬆️  .. (Parent Directory)",
              value = "..",
              path = parent,
              is_parent = true,
            })
          else
            -- At drive level, add a special "Go to Drives" option
            table.insert(dirs, {
              text = "💾 Switch to Different Drive",
              value = "drives",
              path = "drives",
              is_drives_menu = true,
            })
          end

          -- Add current directory option
          table.insert(dirs, {
            text = "📍 . (Current Directory)",
            value = ".",
            path = cwd,
            is_current = true,
          })

          -- Only try to read directories if we're not at drive level or if readdir succeeds
          if not is_at_drive or pcall(function()
            return vim.fn.readdir(cwd)
          end) then
            -- Use vim.fn.readdir to get directories
            local entries = vim.fn.readdir(cwd)
            for _, entry in ipairs(entries) do
              local full_path = vim.fn.expand(cwd .. "/" .. entry)
              if vim.fn.isdirectory(full_path) == 1 then
                -- Get directory info for better display
                local dir_info = ""
                local file_count = 0
                local dir_count = 0

                -- Count files and subdirectories (with error handling)
                local success, sub_entries = pcall(vim.fn.readdir, full_path)
                if success then
                  for _, sub_entry in ipairs(sub_entries) do
                    local sub_path = full_path .. "/" .. sub_entry
                    if vim.fn.isdirectory(sub_path) == 1 then
                      dir_count = dir_count + 1
                    else
                      file_count = file_count + 1
                    end
                  end

                  if dir_count > 0 or file_count > 0 then
                    dir_info = string.format(" (%d dirs, %d files)", dir_count, file_count)
                  end
                end

                table.insert(dirs, {
                  text = "📁 " .. entry .. dir_info,
                  value = entry,
                  path = full_path,
                })
              end
            end
          end

          -- Sort directories alphabetically (but keep parent, drives menu, and current at top)
          local sorted_dirs = {}
          local regular_dirs = {}

          for _, dir in ipairs(dirs) do
            if dir.is_parent or dir.is_current or dir.is_drives_menu then
              table.insert(sorted_dirs, dir)
            else
              table.insert(regular_dirs, dir)
            end
          end

          table.sort(regular_dirs, function(a, b)
            return a.value < b.value
          end)
          for _, dir in ipairs(regular_dirs) do
            table.insert(sorted_dirs, dir)
          end

          -- Create a more visually appealing prompt
          local prompt = string.format("📂 Directory Browser\nCurrent: %s", cwd)

          -- Use vim.ui.select for directory picker with enhanced formatting
          vim.ui.select(sorted_dirs, {
            prompt = prompt,
            format_item = function(item)
              -- Add visual separators and better formatting
              if item.is_parent then
                return item.text
              elseif item.is_current then
                return "📍 . (Current Directory)"
              elseif item.is_drives_menu then
                return item.text
              else
                return item.text
              end
            end,
          }, function(choice)
            if choice then
              if choice.is_parent then
                -- Navigate to parent directory
                browse_directories(choice.path)
              elseif choice.is_current then
                -- Change to current directory
                vim.cmd("cd " .. choice.path)
              elseif choice.is_drives_menu then
                -- Show drives selection menu
                local drives = get_drives()
                vim.ui.select(drives, {
                  prompt = "💾 Select Drive to Navigate",
                  format_item = function(drive)
                    return drive.text
                  end,
                }, function(drive_choice)
                  if drive_choice then
                    browse_directories(drive_choice.path)
                  end
                end)
              else
                -- Navigate into selected directory
                browse_directories(choice.path)
              end
            end
          end)
        end

        -- Start browsing from current directory
        browse_directories()
      end,
      desc = "Browse All Directories",
    },
  },
}
