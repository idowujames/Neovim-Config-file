-- ============================================================================
-- NEOVIM IDE CONFIGURATION FOR BEGINNERS (v2 - Neovim 0.11 Native LSP)
-- Compatible with Neovim 0.11.5
-- ============================================================================
-- This configuration uses the NEW vim.lsp.config() and vim.lsp.enable() APIs
-- introduced in Neovim 0.11, which means we can configure LSP servers without
-- requiring the nvim-lspconfig plugin (though we still use Mason for installing
-- the actual language server binaries).
-- ============================================================================

-- ============================================================================
-- BASIC SETTINGS
-- ============================================================================
-- Set leader key to spacebar (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI Settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = 'a'           -- Enable mouse support
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"    -- Always show sign column (prevents UI jumping)
vim.opt.cursorline = true     -- Highlight current line
vim.opt.wrap = false          -- Don't wrap lines

-- Tab and Indentation
vim.opt.tabstop = 4        -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4     -- Number of spaces for auto-indent
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.autoindent = true  -- Copy indent from current line when starting new line
vim.opt.smartindent = true -- Smart autoindenting when starting a new line

-- Search Settings
vim.opt.ignorecase = true -- Ignore case when searching
vim.opt.smartcase = true  -- Override ignorecase if search contains uppercase
vim.opt.hlsearch = true   -- Highlight search results
vim.opt.incsearch = true  -- Show matches as you type

-- Split Windows
vim.opt.splitright = true -- Vertical splits go to the right
vim.opt.splitbelow = true -- Horizontal splits go below

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- File Settings
vim.opt.swapfile = false -- Don't create swap files
vim.opt.backup = false   -- Don't create backup files
vim.opt.undofile = true  -- Enable persistent undo
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Scrolling
vim.opt.scrolloff = 8 -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8

-- Command line
vim.opt.cmdheight = 1    -- Height of command line
vim.opt.showmode = false -- Don't show mode (shown in statusline)

-- ============================================================================
-- PLUGIN MANAGER SETUP (lazy.nvim)
-- ============================================================================
-- Bootstrap lazy.nvim (auto-installs if not present)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGINS
-- ============================================================================
require("lazy").setup({
    -- =========================================================================
    -- COLORSCHEME
    -- =========================================================================
    {
        "folke/tokyonight.nvim",
        lazy = false,    -- Make sure it loads immediately
        priority = 1000, -- Load this before everything else
        config = function()
            require("tokyonight").setup({
                style = "night", -- Options: storm, moon, night, day
                transparent = false,
                terminal_colors = true,
            })
            vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- =========================================================================
    -- BREADCRUMBS (Winbar)
    -- =========================================================================
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- configurations go here
        },
    },

    -- =========================================================================
    -- FILE EXPLORER (nvim-tree)
    -- =========================================================================
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- File icons
        },
        config = function()
            -- Disable netrw (Vim's default file explorer)
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false, -- Show hidden files
                },
            })
        end,
    },

    -- =========================================================================
    -- STATUSLINE (lualine)
    -- =========================================================================
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight", -- updated from gruvbox to tokyonight
                    component_separators = "|",
                    section_separators = "",
                },
            })
        end,
    },

    -- =========================================================================
    -- fuzzy finder (telescope)
    -- =========================================================================
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
            })
            telescope.load_extension("fzf")
        end,
    },

    -- =========================================================================
    -- SYNTAX HIGHLIGHTING (Treesitter)
    -- =========================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false, -- Load immediately to prevent timing issues
        build = ":TSUpdate",
        config = function()
            -- Use protected call to prevent errors if module isn't ready
            local status_ok, configs = pcall(require, "nvim-treesitter")
            if not status_ok then
                vim.notify("Failed to load nvim-treesitter.configs", vim.log.levels.ERROR)
                return
            end

            configs.setup({
                -- Install parsers for your languages
                ensure_installed = {
                    "lua",
                    "vim",
                    "vimdoc",
                    "python",
                    "javascript",
                    "typescript",
                    "html",
                    "css",
                    "bash",
                    "json",
                    "markdown",
                    "markdown_inline",
                },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
            })

            -- Enable code folding with treesitter
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldlevel = 99 -- Start with all folds open
        end,
    },

    -- =========================================================================
    -- MASON: LSP SERVER INSTALLER
    -- =========================================================================
    -- Mason is still useful for INSTALLING language servers, but we don't
    -- need mason-lspconfig anymore since we're using native vim.lsp.config
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- =========================================================================
    -- AUTOCOMPLETION (blink.cmp)
    -- =========================================================================
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets", -- Collection of snippets
        },
        opts = {
            keymap = {
                preset = "default",
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },
            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
    },

    -- =========================================================================
    -- FORMATTING (conform.nvim)
    -- =========================================================================
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "ruff_organize_imports", "ruff_format" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    json = { "prettier" },
                    markdown = { "prettier" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 500,
                },
            })
        end,
    },

    -- =========================================================================
    -- GIT INTEGRATION (gitsigns)
    -- =========================================================================
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
                current_line_blame = false, -- Toggle with :Gitsigns toggle_current_line_blame
            })
        end,
    },

    -- =========================================================================
    -- COMMENTING (Comment.nvim)
    -- =========================================================================
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    },

    -- =========================================================================
    -- AUTO PAIRS (nvim-autopairs)
    -- =========================================================================
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    -- =========================================================================
    -- TERMINAL (toggleterm)
    -- =========================================================================
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 20,
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                shade_terminals = true,
                start_in_insert = true,
                insert_mappings = true,
                persist_size = true,
                direction = "float",
                close_on_exit = true,
                shell = vim.o.shell,
                float_opts = {
                    border = "curved",
                },
            })
        end,
    },

    -- =========================================================================
    -- INDENTATION GUIDES (indent-blankline)
    -- =========================================================================
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup()
        end,
    },

    -- =========================================================================
    -- WHICH-KEY (shows keybinding hints)
    -- =========================================================================
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },
})

-- ============================================================================
-- NATIVE LSP CONFIGURATION (NEW in Neovim 0.11)
-- ============================================================================
-- Instead of using nvim-lspconfig's setup() functions, we use the new
-- vim.lsp.config() API. This is built into Neovim 0.11+!

-- First, we'll create a directory for our LSP configs
-- These configs will be loaded automatically by Neovim
local lsp_config_dir = vim.fn.stdpath("config") .. "/lsp"
vim.fn.mkdir(lsp_config_dir, "p")

-- Define shared capabilities for all LSP servers
-- This tells the server what features our client supports
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Global LSP settings (applied to all servers)
-- The '*' means these settings apply to every LSP server
vim.lsp.config('*', {
    capabilities = capabilities,
})

-- ============================================================================
-- INDIVIDUAL LSP SERVER CONFIGURATIONS
-- ============================================================================

-- LUA LANGUAGE SERVER (lua_ls)
-- For editing Neovim config and Lua scripts
vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim' }, -- Recognize 'vim' as a global variable
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})

-- PYTHON (pyright)
-- For Python development
vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
            },
        },
    },
})
-- RUFF (Linting & Code Actions)
vim.lsp.config('ruff', {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
    on_attach = function(client, bufnr)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
    end,
})

-- JAVASCRIPT/TYPESCRIPT (ts_ls, formerly tsserver)
-- For JavaScript and TypeScript development
vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

-- HTML
-- For HTML files
vim.lsp.config('html', {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html' },
    root_markers = { 'package.json', '.git' },
})

-- CSS
-- For CSS and SCSS files
vim.lsp.config('cssls', {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_markers = { 'package.json', '.git' },
})

-- BASH
-- For shell scripts
vim.lsp.config('bashls', {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh', 'bash' },
    root_markers = { '.git' },
})

-- JSON
-- For JSON files
vim.lsp.config('jsonls', {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { '.git' },
})

-- ============================================================================
-- ENABLE LSP SERVERS
-- ============================================================================
-- This is the new way to start LSP servers in Neovim 0.11+
-- Instead of calling setup() for each server, we just call vim.lsp.enable()
-- with a list of server names

vim.lsp.enable({
    'lua_ls',
    'pyright',
    'ruff',
    'ts_ls',
    'html',
    'cssls',
    'bashls',
    'jsonls',
})

-- ============================================================================
-- LSP KEYMAPS AND CONFIGURATION
-- ============================================================================
-- This function is called when an LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        -- Keybindings
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)            -- Go to definition
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)           -- Go to declaration
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)        -- Go to implementation
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)            -- Show references
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                  -- Hover documentation
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)        -- Rename symbol
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)   -- Code action
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)          -- Previous diagnostic
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)          -- Next diagnostic
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts) -- Show diagnostic
    end,
})

-- ============================================================================
-- GENERAL KEYMAPS
-- ============================================================================
local keymap = vim.keymap

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close buffer" })

-- Clear search highlighting
keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlighting" })

-- File explorer (nvim-tree)
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", ":NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Telescope (fuzzy finder)
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })

-- Git (gitsigns)
keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })
keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })

-- Format document
keymap.set("n", "<leader>fm", function()
    require("conform").format({ lsp_fallback = true })
end, { desc = "Format file" })

-- Better indenting
keymap.set("v", "<", "<gv", { desc = "Indent left" })
keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Delete without overwriting clipboard
vim.keymap.set('n', '<leader>d', '"_d', { noremap = true })
vim.keymap.set('v', '<leader>d', '"_d', { noremap = true })
vim.keymap.set('n', '<leader>D', '"_D', { noremap = true })
vim.keymap.set('n', '<leader>c', '"_c', { noremap = true })

-- Save and Close using the leader key
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all" })

-- Map Esc to 'jj' in insert 
vim.keymap.set('i', 'jj', '<esc>', { desc = "Map jj to esc" })

-- ============================================================================
-- AUTO COMMANDS
-- ============================================================================
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- ============================================================================
-- NOTES AND INSTRUCTIONS
-- ============================================================================
-- This configuration uses Neovim 0.11's native LSP support!
--
-- Key differences from the old approach:
-- 1. No more require('lspconfig').server.setup({})
-- 2. Instead: vim.lsp.config('server', {...}) and vim.lsp.enable({'server'})
-- 3. Simpler, cleaner, and uses only built-in Neovim APIs
--
-- You still need to INSTALL the language servers themselves:
-- Method 1: Use Mason UI
--   :Mason
--   Search for and install: lua-language-server, pyright, typescript-language-server, etc.
--
-- Method 2: Install manually via your system package manager
--   For example on Ubuntu:
--   npm install -g typescript-language-server
--   pip install pyright
--
-- To verify everything is working:
-- :checkhealth vim.lsp
--
-- The LSP servers will automatically start when you open files of their type!
-- ============================================================================
