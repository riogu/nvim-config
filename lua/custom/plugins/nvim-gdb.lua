return {
  'sakhnik/nvim-gdb',
  build = './install.sh',
  config = function()
    -- Parse DejaGNU directives from test file
    local function parse_dejagnu_options(test_file)
      local file = io.open(test_file, 'r')
      if not file then
        return ''
      end

      local options = {}
      local in_comment_block = false

      for line in file:lines() do
        -- Handle C++ style comments
        local comment = line:match '^%s*//(.*)$'
        if comment then
          -- Look for dg-options
          local dg_options = comment:match '{ dg%-options "([^"]*)" }' or comment:match "{ dg%-options '([^']*)' }"
          if dg_options then
            table.insert(options, dg_options)
          end

          -- Look for dg-additional-options
          local dg_additional = comment:match '{ dg%-additional%-options "([^"]*)" }' or comment:match "{ dg%-additional%-options '([^']*)' }"
          if dg_additional then
            table.insert(options, dg_additional)
          end

          -- Look for std= requirements
          local std_req = comment:match '{ dg%-require%-effective%-target c%+%+(%d+)' or comment:match 'c%+%+(%d+)'
          if std_req and not line:match 'dg%-options' then
            -- Only add if not already in dg-options
            local has_std = false
            for _, opt in ipairs(options) do
              if opt:match '-std=' then
                has_std = true
                break
              end
            end
            if not has_std then
              table.insert(options, '-std=c++' .. std_req)
            end
          end
        end

        -- Handle C style comment blocks
        if line:match '/%*' then
          in_comment_block = true
        end
        if in_comment_block then
          local dg_options = line:match '{ dg%-options "([^"]*)" }'
          if dg_options then
            table.insert(options, dg_options)
          end
        end
        if line:match '%*/' then
          in_comment_block = false
        end

        -- Stop after first 50 lines (directives are usually at the top)
        if #options > 0 and file:seek() > 2000 then
          break
        end
      end

      file:close()
      return table.concat(options, ' ')
    end

    -- Helper function to extract cc1plus command from xg++ -v output
    local function get_cc1plus_command(test_file, extra_args)
      extra_args = extra_args or ''

      -- Parse DejaGNU options from the test file
      local dejagnu_opts = parse_dejagnu_options(test_file)
      if dejagnu_opts ~= '' then
        vim.notify('Found DejaGNU options: ' .. dejagnu_opts, vim.log.levels.INFO)
        extra_args = dejagnu_opts .. ' ' .. extra_args
      end

      -- Expand home directory
      local home = os.getenv 'HOME'
      local libstdcxx_base = home .. '/gcc-source/build/x86_64-pc-linux-gnu/libstdc++-v3'
      local gcc_source = home .. '/gcc-source/gcc'

      local xgpp_cmd = string.format(
        './xg++ -B. -nostdinc++ '
          .. '-isystem %s/include '
          .. '-isystem %s/include/x86_64-pc-linux-gnu '
          .. '-isystem %s/libstdc++-v3/libsupc++ '
          .. '%s -v %s 2>&1',
        libstdcxx_base,
        libstdcxx_base,
        gcc_source,
        extra_args,
        test_file
      )

      local handle = io.popen(xgpp_cmd)
      local output = handle:read '*a'
      handle:close()

      -- Extract the cc1plus invocation from -v output
      -- Look for lines containing cc1plus
      for line in output:gmatch '[^\r\n]+' do
        if line:match 'cc1plus' or line:match 'cc1' then
          -- Clean up the line to get just the command
          local cc1plus_cmd = line:match '^%s*(.-)%s*$' -- trim whitespace
          return cc1plus_cmd
        end
      end

      return nil
    end

    -- Create command for debugging cc1plus directly
    vim.api.nvim_create_user_command('GdbCC1plus', function(opts)
      local args = vim.split(opts.args, '%s+')
      local test_file = args[1]

      -- Allow optional extra flags: :GdbCC1plus test.C -O2 -g
      local extra_args = ''
      if #args > 1 then
        extra_args = table.concat(vim.list_slice(args, 2), ' ')
      end

      -- Get the actual cc1plus command
      vim.notify('Extracting cc1plus command from xg++ -v...', vim.log.levels.INFO)
      local cc1plus_cmd = get_cc1plus_command(test_file, extra_args)

      if cc1plus_cmd then
        vim.notify('Starting GDB with cc1plus', vim.log.levels.INFO)
        -- Close current buffer if it's a scratch buffer to make room for GDB
        local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
        if buftype == 'nofile' or buftype == 'terminal' then
          vim.cmd 'enew'
        end
        vim.cmd(string.format('GdbStart gdb --args %s', cc1plus_cmd))
      else
        vim.notify('Failed to extract cc1plus command', vim.log.levels.ERROR)
      end
    end, { nargs = '+', complete = 'file' })

    -- Quick command with custom std and base flags
    vim.api.nvim_create_user_command('GdbCC1plusQuick', function(opts)
      local args = vim.split(opts.args, '%s+')
      if #args < 2 then
        vim.notify('Usage: GdbCC1plusQuick <test_file> <std_version> [extra_flags]', vim.log.levels.ERROR)
        return
      end

      local test_file = args[1]
      local std_version = args[2]
      local extra_flags = ''
      if #args > 2 then
        extra_flags = table.concat(vim.list_slice(args, 3), ' ')
      end

      -- Expand home directory
      local home = os.getenv 'HOME'
      local libstdcxx_base = home .. '/gcc-source/build/x86_64-pc-linux-gnu/libstdc++-v3'
      local gcc_source = home .. '/gcc-source/gcc'

      local cmd = string.format(
        'GdbStart gdb --args ./cc1plus -quiet -std=c++%s '
          .. '-nostdinc++ '
          .. '-isystem %s/include '
          .. '-isystem %s/include/x86_64-pc-linux-gnu '
          .. '-isystem %s/libstdc++-v3/libsupc++ '
          .. '%s %s',
        std_version,
        libstdcxx_base,
        libstdcxx_base,
        gcc_source,
        extra_flags,
        test_file
      )
      vim.cmd(cmd)
    end, { nargs = '+', complete = 'file' })

    -- Show DejaGNU directives from test file
    vim.api.nvim_create_user_command('ShowTestOptions', function(opts)
      local test_file = opts.args
      local dejagnu_opts = parse_dejagnu_options(test_file)

      if dejagnu_opts ~= '' then
        vim.notify('DejaGNU options: ' .. dejagnu_opts, vim.log.levels.INFO)
      else
        vim.notify('No DejaGNU options found in ' .. test_file, vim.log.levels.WARN)
      end
    end, { nargs = 1, complete = 'file' })

    -- Run test via GCC testsuite (make check-g++)
    vim.api.nvim_create_user_command('RunTestsuite', function(opts)
      local test_file = opts.args

      -- Extract just the filename from the full path
      local filename = test_file:match '([^/]+)$'

      if not filename then
        vim.notify('Invalid test file path', vim.log.levels.ERROR)
        return
      end

      local home = os.getenv 'HOME'
      local build_root = home .. '/gcc-source/build/gcc'

      local cmd = string.format('cd %s && make check-g++ RUNTESTFLAGS="dg.exp=%s"', build_root, filename)

      vim.notify('Running testsuite for: ' .. filename, vim.log.levels.INFO)

      -- Run in terminal in current window
      vim.cmd('terminal ' .. cmd)
    end, { nargs = 1, complete = 'file' })

    -- Show log file for a test
    vim.api.nvim_create_user_command('ShowTestLog', function(opts)
      local test_file = opts.args

      -- Extract just the filename
      local filename = test_file:match '([^/]+)$'

      if not filename then
        vim.notify('Invalid test file path', vim.log.levels.ERROR)
        return
      end

      -- Look for log files in common locations
      local log_patterns = {
        'gcc/testsuite/g++/g++.log',
        'gcc/testsuite/g++.log',
        '../gcc/testsuite/g++/g++.log',
        '../gcc/testsuite/g++.log',
      }

      local log_file = nil
      for _, pattern in ipairs(log_patterns) do
        local f = io.open(pattern, 'r')
        if f then
          f:close()
          log_file = pattern
          break
        end
      end

      if not log_file then
        vim.notify('Could not find g++.log file. Run the testsuite first.', vim.log.levels.WARN)
        return
      end

      -- Search for the test in the log file
      local cmd = string.format("grep -A 50 '%s' %s", filename, log_file)
      local handle = io.popen(cmd)
      local output = handle:read '*a'
      handle:close()

      if output == '' then
        vim.notify('Test not found in ' .. log_file .. '. Run testsuite first?', vim.log.levels.WARN)
        return
      end

      -- Show in current buffer
      local buf = vim.api.nvim_create_buf(false, true)
      local lines = {}
      for line in output:gmatch '[^\r\n]+' do
        table.insert(lines, line)
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      vim.api.nvim_buf_set_option(buf, 'filetype', 'log')
      vim.api.nvim_buf_set_name(buf, 'Test Log: ' .. filename)

      vim.api.nvim_win_set_buf(0, buf)

      vim.notify('Showing log for: ' .. filename, vim.log.levels.INFO)
    end, { nargs = 1, complete = 'file' })

    -- Run DejaGNU test and show results
    vim.api.nvim_create_user_command('RunTest', function(opts)
      local test_file = opts.args

      -- Parse DejaGNU options
      local dejagnu_opts = parse_dejagnu_options(test_file)

      local cmd = string.format(
        './xg++ -B. -nostdinc++ '
          .. '-isystem ../x86_64-pc-linux-gnu/libstdc++-v3/include '
          .. '-isystem ../x86_64-pc-linux-gnu/libstdc++-v3/include/x86_64-pc-linux-gnu '
          .. '-isystem ../../gcc/libstdc++-v3/libsupc++ '
          .. '%s %s',
        dejagnu_opts,
        test_file
      )

      vim.notify('Running test: ' .. test_file, vim.log.levels.INFO)

      -- Run in terminal in current window
      vim.cmd('terminal ' .. cmd)
    end, { nargs = 1, complete = 'file' })

    -- Search for test files by pattern
    vim.api.nvim_create_user_command('FindTest', function(opts)
      local pattern = opts.args
      local home = os.getenv 'HOME'
      local testsuite_path = home .. '/gcc-source/gcc/testsuite/g++.dg'

      local find_cmd = string.format("find %s -name '*%s*.C' -o -name '*%s*.cc'", testsuite_path, pattern, pattern)

      local handle = io.popen(find_cmd)
      local results = handle:read '*a'
      handle:close()

      local lines = {}
      for line in results:gmatch '[^\r\n]+' do
        table.insert(lines, line)
      end

      if #lines == 0 then
        vim.notify('No tests found matching: ' .. pattern, vim.log.levels.WARN)
      elseif #lines == 1 then
        vim.notify('Found: ' .. lines[1], vim.log.levels.INFO)
        vim.cmd('edit ' .. lines[1])
      else
        -- Create a scratch buffer with just file paths
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_name(buf, 'Test Results: ' .. pattern)

        -- Open in split
        vim.cmd 'split'
        vim.api.nvim_win_set_buf(0, buf)

        -- Add keymaps for easy usage
        local function get_current_path()
          local line = vim.api.nvim_get_current_line()
          return vim.fn.fnameescape(line)
        end

        vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
          noremap = true,
          silent = true,
          desc = 'Open test file',
          callback = function()
            local path = get_current_path()
            vim.cmd 'wincmd p'
            vim.cmd('edit ' .. path)
          end,
        })
        vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
          noremap = true,
          silent = true,
          desc = 'Debug this test',
          callback = function()
            local path = get_current_path()
            local results_buf = vim.api.nvim_get_current_buf()
            vim.cmd 'wincmd p'
            local prev_buf = vim.api.nvim_get_current_buf()
            -- Close both buffers
            vim.api.nvim_buf_delete(results_buf, { force = true })
            if vim.api.nvim_buf_get_option(prev_buf, 'buftype') ~= '' then
              vim.api.nvim_buf_delete(prev_buf, { force = true })
            end
            vim.cmd('GdbCC1plus ' .. path)
          end,
        })
        vim.api.nvim_buf_set_keymap(buf, 'n', 'r', '', {
          noremap = true,
          silent = true,
          desc = 'Run test',
          callback = function()
            local path = get_current_path()
            vim.cmd 'wincmd p'
            vim.cmd('RunTest ' .. path)
          end,
        })
        vim.api.nvim_buf_set_keymap(buf, 'n', 't', '', {
          noremap = true,
          silent = true,
          desc = 'Run via testsuite',
          callback = function()
            local path = get_current_path()
            vim.cmd 'wincmd p'
            vim.cmd('RunTestsuite ' .. path)
          end,
        })
        vim.api.nvim_buf_set_keymap(buf, 'n', 'l', '', {
          noremap = true,
          silent = true,
          desc = 'Show log file',
          callback = function()
            local path = get_current_path()
            vim.cmd 'wincmd p'
            vim.cmd('ShowTestLog ' .. path)
          end,
        })

        vim.notify(string.format('Found %d tests. <CR>=open, d=debug, r=run, t=testsuite, l=log', #lines), vim.log.levels.INFO)
      end
    end, { nargs = 1 })
  end,
}
