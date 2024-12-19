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
            -- "rebelot/kanagawa.nvim",
            "navarasu/onedark.nvim",
            -- "catppuccin/nvim",
            -- "fxn/vim-monochrome",
            config = function()
                -- vim.cmd.colorscheme("kanagawa-wave")
                vim.cmd.colorscheme("onedark")
                -- vim.cmd.colorscheme("catppuccin")
                -- vim.cmd.colorscheme("monochrome")
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "c", "lua", "vim", "vimdoc", "query",
                        "java", "rust",
                        "erlang", "elixir", "eex", "heex",
                        "json", "yaml", "toml"
                    },

                    auto_install = true,

                    highlight = {
                        enable = true,
                    },

                    indent = {
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
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                require("lualine").setup()                
            end,
        },
        {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                -- calling `setup` is optional for customization
                require("fzf-lua").setup({
                    defaults = {
                        git_icons = false,
                        file_icons = false,
                        color_icons = false,
                    }
                })
            end
        },
        {
            'stevearc/oil.nvim',
            ---@module 'oil'
            ---@type oil.SetupOpts
            opts = {},
            -- Optional dependencies
            dependencies = { { "echasnovski/mini.icons", opts = {} } },
            -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
            config = function()
                require("oil").setup({
                    keymaps = {
                        ["<C-h>"] = { "actions.parent", mode = "n" },
                        ["<BS>"] = { "actions.parent", mode = "n" },
                        ["<C-l>"] = { "actions.select", mode = "n" },
                    }
                })
            end
        },
        {
            "neovim/nvim-lspconfig",
        },
        {
            "williamboman/mason.nvim",
            config = function()
                require("mason").setup()
            end
        },
        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = { "mason.nvim" },
            config = function()
                require("mason-lspconfig").setup()
                require("mason-lspconfig").setup_handlers({
                    function (server_name)
                        require("lspconfig")[server_name].setup({})
                    end,
                })
            end
        },
        -- {
        --     "mfussenegger/nvim-dap",
        -- },
        -- {
        --     "nvim-neotest/nvim-nio",
        -- },
        -- { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} }
    },
})

