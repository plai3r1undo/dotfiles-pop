
-- vim commands to basic personalization
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

--lines number and relative
vim.opt.nu = true
vim.opt.relativenumber = true

--search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 10

vim.g.mapleader = " "
vim.cmd("map <leader>q :q<cr>")
vim.cmd("map <leader>w :w<cr>")
vim.keymap.set("n", "<M-j>", ":m .+1<cr>")
vim.keymap.set("n", "<M-k>", ":m .-2 <cr>")



-- Lazy paackage manager install
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
-- table of all packages installed by lazy

local plugins = {
    {"ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
    {"folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {}, },
    {'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = { 'nvim-lua/plenary.nvim' }},
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {"nvim-tree/nvim-tree.lua", version = "*", lazy = false, dependencies = { "nvim-tree/nvim-web-devicons"}}, 
    {"nvim-lualine/lualine.nvim"},

    -- Lsp below and comp
    {"williamboman/mason.nvim"},
    {'williamboman/mason-lspconfig.nvim'},
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},

    {'saadparwaiz1/cmp_luasnip'},

    {'L3MON4D3/LuaSnip', dependencies = { "rafamadriz/friendly-snippets" }},





}
local opts = {
}

-- init lazy package manager

require("lazy").setup(plugins, opts)

--init nvim-tree and config
local treeFileConfig = require("nvim-tree").setup {}
vim.cmd("map <leader>e :NvimTreeToggle<cr>")


-- init mason, lsp and completion
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
     lsp_zero.default_keymaps({buffer = bufnr})
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
    ensure_installed = {'tsserver', 'rust_analyzer'},
    handlers = {
    lsp_zero.default_setup,
    },
})
    

local cmp = require('cmp')
local luasnip = require('luasnip')

--may be ueless idk
luasnip.filetype_extend("lua", {"c"})
luasnip.filetype_extend("html", {"c"})

--vs code -like 
require("luasnip.loaders.from_vscode").lazy_load({include = { "python", "html"}})

cmp.setup {
    snippet = {
        expand = function(args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<C-space>'] = cmp.mapping.confirm({select = true}),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-y>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {select = true},
        ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        if luasnip ~= nil then return end  
        elseif luasnip ~= nil and luasnip.expandable() then
            luasnip.expand()
        elseif luasnip ~= nil and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif check_backspace() then
            fallback()
        else
            fallback()
        end
        end, {
            "i",
            "s",
        }),
    }
}


-- init telescope plugin and config keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})

--init lualine and setup

require('lualine').setup {

}



-- init and setup tree sitter
local config = require("nvim-treesitter.configs")
config.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "rust", "python", "javascript", "html" , "gdscript", },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })

-- setup groovebox colorscheme
-- Default options:
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false, -- default is false
})

vim.o.background = "dark" -- or "light" for light mode --default is dark
vim.cmd([[colorscheme gruvbox]]) --or vim.cmd[[colorscheme tokyonight]] for tokyo

