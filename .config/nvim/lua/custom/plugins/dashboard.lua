return {
  "glepnir/dashboard-nvim",
  event = "VimEnter",
  config = function()
    local version = vim.version()
    local header = {
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⠀⠀⢀⣀⡤⠖⠒⠋⠉⠉⠀⠀⠀⠀⠉⠉⠉⠉⠉⠓⠒⠤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⠶⠋⠁⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠈⠓⠦⣀⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⡿⢿⣧⣀⡠⠴⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠉⠉⠓⠲⠤⣀⠀⠀⠀⣴⣿⡷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⡴⠋⠀⣧⣾⡟⠁⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣾⣿⣿⡇⠙⢧⡀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⣠⠎⠀⠀⣠⣾⡿⠁⢀⣠⠤⠒⠊⠉⠉⠀⠀⠀⠀⠀⠈⠉⠉⠓⠒⠤⣤⡀⠀⠀⢹⣿⣸⠁⠀⠀⠱⡀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⡴⠁⠀⠀⡴⠿⢈⠀⡰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⡄⠈⣿⢹⢆⠀⠀⠀⠹⡄⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⡼⠁⠀⢀⠎⣠⠖⢹⡾⠁⠀⠀⠀⠀⠀⠀⡐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄⠈⣜⠈⢦⠀⠀⠀⠹⡄⠀⠀⠀⠀",
      "⠀⠀⠀⣼⢀⠀⢀⡾⠋⠀⠀⢀⠀⠀⡀⣸⠀⠀⠀⠀⡇⡄⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣞⠈⠳⣈⣇⠀⢠⡀⢣⠀⠀⠀⠀",
      "⠀⠀⢰⠃⡼⠀⠀⠀⡀⠀⠀⡎⠀⢠⠃⡟⠀⠀⠀⢰⢡⠀⡆⠀⠀⠀⠀⠀⡆⠀⡆⠀⠀⠀⠀⠀⠀⢿⠀⠀⠘⢾⠀⠘⡇⢸⠀⠀⠀⠀",
      "⠀⠀⡏⢠⠃⠀⠀⢠⠃⠀⢸⠁⠀⣸⢀⠇⠀⠀⠀⣸⢸⢰⡇⠀⠀⠀⢸⢸⠃⠀⠃⠀⠀⠀⠠⠀⠀⢸⠀⠀⠀⢸⠁⠀⡇⠀⠃⠀⠀⠀",
      "⠀⠀⠀⠸⠀⠀⠀⡜⠀⢀⡇⠀⢀⡇⢸⠀⠀⠀⠀⡇⡇⢸⡇⠀⠀⠀⣸⡸⠀⢸⠀⠀⠀⠀⢸⢰⠀⢸⠀⠀⠀⡇⠀⠀⢧⠀⡂⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⡗⠀⣼⠀⢀⣾⡇⢸⠀⠀⠀⢰⣷⡇⣾⡇⠀⠀⠀⡇⡇⠀⣼⢰⠀⠀⠀⣸⢸⠀⢸⠀⠀⠀⠇⠀⠀⢸⠀⡇⠀⠀⠀",
      "⠀⠇⠀⠀⠀⠀⢸⠇⢰⡏⠀⡸⡟⡅⣬⣀⣀⣀⣿⣻⣇⡟⡇⠀⠀⢀⣿⠃⢀⣿⢸⠀⠀⠀⣿⡎⠀⢸⡄⡄⢰⠀⠀⠀⢸⠀⡇⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⣾⢀⢿⠃⠀⣷⠃⡀⡏⠀⠀⠀⣹⡇⣿⠁⡇⠀⠀⢸⣹⠚⢻⢻⡻⠛⠓⠒⣿⣿⡀⢸⡇⡇⣿⠀⠀⠀⢸⠀⡇⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⣿⡾⢸⠀⢸⢹⠘⠁⡇⠀⣀⠀⣿⣿⢸⠀⡇⠀⠀⣼⡇⢀⡏⢸⡇⠀⠀⢰⣻⣿⠀⣸⣇⢿⡇⠀⠀⠀⡌⠀⡇⠀⠀⠀",
      "⢸⠀⠀⠀⠀⠀⣯⠃⡎⠀⡎⡎⠀⡆⢇⠀⠀⠁⣿⣿⡆⠀⡇⠀⢠⣷⠁⡼⠁⢸⡇⠀⠀⢸⣿⢻⠀⣿⢻⢺⠁⠀⠀⠀⡇⠀⢰⠀⠀⠀",
      "⢸⠀⠀⠀⠀⠀⣿⠀⡇⢀⣇⡇⠀⠧⠼⣤⣴⣄⠟⠹⠃⠀⠉⠀⠈⠟⠠⢷⣶⣚⠧⠄⠀⣿⣹⢸⠀⡇⢸⣾⠀⠀⠀⢀⡇⠀⢸⡆⠀⠀",
      "⢸⠀⢠⠀⠀⠀⣿⠀⠟⠛⠛⠻⠿⠿⠛⠛⠋⠁⠀⠀⠀⠰⠀⠀⠀⠀⠀⠀⠈⠛⠿⠷⠶⣿⠾⣿⡿⠀⠀⡏⠀⠀⠀⢸⡇⠀⠈⢇⠀⠀",
      "⢸⠀⠸⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣀⠀⢠⠇⠀⠀⠀⣾⡇⠀⠀⠸⡀⠀",
      "⠘⡄⠀⡇⠀⠀⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⣸⠀⠀⠀⢀⣯⡇⡆⠀⠀⢧⠀",
      "⠀⡇⠀⢧⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⢸⡼⠀⣇⠀⡄⠈⣆",
      "⠀⡇⠀⢸⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠁⢀⠞⠀⡟⡇⠀⣿⠀⠘⡄⠘",
      "⠀⡇⠀⠸⡄⠀⠀⢹⣇⠀⠀⠀⠀⠀⠀⠀⠀⣴⠾⠛⠋⠉⠉⠉⠙⠓⠲⡄⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⡜⠀⢰⠃⡇⠀⢿⡀⠀⢯⢆",
      "⠀⠁⠀⠀⣇⠀⠀⢸⡞⣆⠀⠀⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⢀⡾⠀⢰⠃⢀⡞⠀⣇⠀⢸⡇⠀⢸⡀",
      "⠀⠀⠀⠀⢹⠀⠀⠘⡇⠸⣧⡀⠀⠀⠀⠀⠀⠈⢧⡀⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀⠀⠀⠀⢀⣠⣿⡇⢀⠇⢀⡾⡇⠀⢿⠀⠈⣿⡄⠀⣇",
      "⠀⢀⠀⠀⠸⡆⠀⠀⢳⠀⣿⢸⡷⣄⡀⠀⠀⠀⠀⠉⠀⠀⠀⠤⠖⠁⠀⠀⠀⠀⠀⣀⣴⡏⢸⡿⢀⡞⠀⡼⠀⣿⡀⠀⠀⠀⢹⣇⠀⠸",
      "⠀⢸⠀⠀⠀⣧⠀⠀⠸⡄⢹⡄⣿⠀⢿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠴⠊⣿⣿⠀⢰⠃⡞⠀⢠⡇⠀⢸⢧⠀⠀⠀⠈⣿⡀⠀",
      "⠀⢸⠀⠀⠀⣿⡇⠀⠀⢷⢸⡇⣿⠀⠘⣇⣿⣷⣦⣄⠀⠀⠀⠀⢀⣠⠖⠋⠁⠀⣰⠿⣿⠀⡏⡜⠀⢀⡿⡇⠀⠈⣏⢦⠀⠀⠀⠸⡇⠀",
      "⠀⢸⠀⠀⢀⠇⢻⠀⠀⠘⣆⡇⣿⠀⠀⣿⣿⣿⣿⣿⣿⡶⢒⠖⠉⣀⣠⡤⠖⠋⠀⠀⢻⡾⡼⠁⠀⡞⠀⣷⠀⠀⠸⣌⢣⣀⣠⠤⡣⢤",
      "N E O V I M - v " .. version.major .. "." .. version.minor,
      "",
    }

    local center = {
      {
        desc = "Find File                     ",
        keymap = "",
        key = "f",
        icon = "  ",
        action = "Telescope find_files",
      },
      {
        desc = "Recents",
        keymap = "",
        key = "r",
        icon = "  ",
        action = "Telescope oldfiles",
      },

      {
        desc = "Browse Files",
        keymap = "",
        key = ".",
        icon = "  ",
        action = "NvimTreeToggle",
      },

      {
        desc = "New File",
        keymap = "",
        key = "n",
        icon = "  ",
        action = "enew",
      },

      {
        desc = "Load Last Session",
        keymap = "",
        key = "L",
        icon = "  ",
        action = "SessionRestore",
      },

      {
        desc = "Update Plugins",
        keymap = "",
        key = "u",
        icon = "  ",
        action = "Lazy update",
      },

      {
        desc = "Manage Extensions",
        keymap = "",
        key = "e",
        icon = "  ",
        action = "Mason",
      },

      {
        desc = "Config",
        keymap = "",
        key = "s",
        icon = "  ",
        action = "Telescope find_files cwd=~/.config/nvim",
      },
      {
        desc = "Exit",
        keymap = "",
        key = "q",
        icon = "  ",
        action = "exit",
      },
    }

    vim.api.nvim_create_autocmd("Filetype", {
      pattern = "dashboard",
      group = vim.api.nvim_create_augroup("Dashboard_au", { clear = true }),
      callback = function()
        vim.cmd([[
            setlocal buftype=nofile
            setlocal nonumber norelativenumber nocursorline noruler
            nnoremap <buffer> <F2> :h news.txt<CR>
        ]])
      end,
    })

    require("dashboard").setup({
      theme = "doom",
      config = {
        header = header,
        center = center,
        footer = function()
          return {
            "type  :help<Enter>  or  <F1>  for on-line help,  <F2>  news changelog",
            "Startup time: " .. require("lazy").stats().startuptime .. " ms",
          }
        end,
      },
    })
    vim.cmd("highlight DashboardHeader guifg=#ff6c6b")
    vim.cmd("highlight DashboardIcon guifg=#98be65")
    vim.cmd("highlight DashboardKey guifg=#98be64")
    vim.cmd("highlight DashboardDesc guifg=#ff6c6b")
    vim.cmd("highlight DashboardFooter guifg=#ff6c6b")
    vim.keymap.set("n", "<F3>", "<cmd>Dashboard<CR>", { desc = "Dashboard" })
  end,
}
