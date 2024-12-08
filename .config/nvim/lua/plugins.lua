-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            "rebelot/kanagawa.nvim",
            config = function()
                vim.cmd.colorscheme("kanagawa-wave")
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {"c", "lua", "vim", "vimdoc", "query", "java", "rust", "erlang", "elixir", "json", "yaml", "toml"},

                    auto_install = true,

                    highlight = {
                        enable = true,
                    },

                    incremental_selection = {
                        enable = true,
                        keymaps = {
                            init_selection = "<Leader>ss",
                            node_incremental = "<Leader>si",
                            scope_incremental = "<Leader>sc",
                            node_decremental = "<Leader>sd",
                        },
                    },

                    textobjects = {
                        select = {
                            enable = true,

                            -- Automatically jump forward to textobj, similar to targets.vim
                            lookahead = true,

                            keymaps = {
                                -- You can use the capture groups defined in textobjects.scm
                                ["af"] = "@function.outer",
                                ["if"] = "@function.inner",
                                ["ac"] = "@class.outer",
                                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                                -- nvim_buf_set_keymap) which plugins like which-key display
                                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                                -- You can also use captures from other query groups like `locals.scm`
                                ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                            },
                            selection_modes = {
                                ['@parameter.outer'] = 'v', -- charwise
                                ['@function.outer'] = 'v', -- linewise
                                ['@class.outer'] = '<c-v>', -- blockwise
                            },
                            include_surrounding_whitespace = true,
                        },
                    },

                })
            end,
        },
      {
          "nvim-treesitter/nvim-treesitter-textobjects",
      },
 },
})

