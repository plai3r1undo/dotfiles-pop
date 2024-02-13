-- vim commands to basic personalization
vim.cmd("set noexpandtab")
vim.cmd("set autoindent")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set termguicolors")



vim.opt.relativenumber = true
vim.opt.nu= true

--search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 10

vim.opt.undodir = os.getenv("XDG_CONFIG_HOME") .. "/nvim/undodir";
vim.opt.undofile = true

-- enable cursorline
vim.o.cursorline = true
vim.o.cuc = true

vim.opt.wrap = false


vim.g.mapleader = " "
vim.cmd("map <leader>q :q<cr>")
vim.cmd("map <leader>w :w<cr>")


vim.keymap.set("n", "<M-j>", ":m .+1<cr>")
vim.keymap.set("n", "<M-k>", ":m .-2 <cr>")

vim.keymap.set({ 'n', 'v' }, '<leader>i', ':Gen<CR>')


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
    {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = { }},

    {'alec-gibson/nvim-tetris'},
    {'goolord/alpha-nvim'},
    {'lewis6991/gitsigns.nvim'},
    {"hrsh7th/cmp-buffer"},
	{ "David-Kunz/gen.nvim" },
	{'norcalli/nvim-colorizer.lua'},




    -- Lsp below and comp
    {"williamboman/mason.nvim"},
    {'williamboman/mason-lspconfig.nvim'},
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},

    {'saadparwaiz1/cmp_luasnip'},
    {"L3MON4D3/LuaSnip", build = "make install_jsregexp"},

    {'nvim-telescope/telescope-ui-select.nvim' },


}
local opts = {
}

    

-- init lazy package manager
--
require("lazy").setup(plugins, opts)

--init nvim-tree and config
local treeFileConfig = require("nvim-tree").setup {}
vim.cmd("map <leader>e :NvimTreeToggle<cr>")


-- int which key
---@diagnostic disable-next-line: unused-local
local wk = require("which-key")
--wk.register(mappings, opts)


-- init mason, lsp and completion
local lsp_zero = require('lsp-zero')
lsp_zero.preset('recommended')
lsp_zero.setup()
lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
     lsp_zero.default_keymaps({buffer = bufnr})
    local opts = {buffer = bufnr}
    vim.keymap.set({'n', 'v'}, '<leader>ca', function()
        vim.lsp.buf.code_action({})
    end, opts)
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {'tsserver', 'rust_analyzer', 'lua_ls', 'bashls','html','pyright', 'asm_lsp'},
    handlers = {
        lsp_zero.default_setup,
        tsserver = function()
            require('lspconfig').tsserver.setup({
            single_file_support = false,
            on_attach = function(client, bufnr)
                print('hello tsserver')
            end
        })
        end,
    }
})

local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({})
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.html.setup({
    capabilities = capabilities,
    cmd = { "vscode-html-language-server", "--stdio" },
})
lspconfig.bashls.setup({})
lspconfig.pyright.setup({})



local luasnip = require('luasnip')
--may be ueless idk


--gdscript lsp setup
require('lspconfig').gdscript.setup{
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    vim.cmd([[
  setlocal foldmethod=expr
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal indentexpr=
  ]])
  }

--[[ Alternative way of dooing GodotLsp 
local port = os.getenv('GDScript_Port') or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', port)
local pipe = '/path/to/godot.pipe' -- I use /tmp/godot.pipe

    print("Activating GodotLsp")
    vim.lsp.start({
    name = 'Godot',
    cmd = cmd,
    root_dir = vim.fs.dirname(vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]),
    on_attach = function(client, bufnr)
        vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
    end
    })
]]--

--vs code -like 
require("luasnip.loaders.from_vscode").lazy_load({include = { "python", "html"}})

local cmp = require('cmp')

cmp.setup {
    sources = {
        {name = 'nvim_lsp'},
        {name = 'luasnip'},
        {name =  'buffer'},
        {name = 'Godot'},
    },
    snippet = {
        expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ['<S-space>'] = cmp.mapping.confirm({select = true}),
        ['<S-j>'] = cmp.mapping.select_next_item(),
        ['<S-k>'] = cmp.mapping.select_prev_item(),
        ['<S-y>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {select = true},
        ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        if luasnip ~= nil then return end  
        elseif luasnip ~= nil and luasnip.expandable() then
            luasnip.expand()
        elseif luasnip ~= nil and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif check_backspace ~= nil and check_backspace() then
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


-- Ollama ap 
local gen = require('gen')
gen.setup({
	model = "codellama", -- The default model to use.
})


--gitsigns
require('gitsigns').setup{}


---@diagnostic disable-next-line: unused-local
local colorize = require'colorizer'.setup()


-- init telescope plugin and config keybindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})

require("telescope").setup{
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
        }
    }
}
require("telescope").load_extension("ui-select")


--init lualine and setup

require('lualine').setup {

}


-- config dashboard
local alpha = require('alpha')
local dashboard = require("alpha.themes.dashboard")
--require'alpha'.setup(require'alpha.themes.dashboard'.config)
dashboard.section.header.val = {
[[███╗   ██╗███████╗ ██████╗     ███████╗██╗   ██╗ ██████╗██╗  ██╗██╗███╗   ██╗ ██████╗     ██╗   ██╗██╗███╗   ███╗]],
[[████╗  ██║██╔════╝██╔═══██╗    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██║████╗  ██║██╔════╝     ██║   ██║██║████╗ ████║]],
[[██╔██╗ ██║█████╗  ██║   ██║    █████╗  ██║   ██║██║     █████╔╝ ██║██╔██╗ ██║██║  ███╗    ██║   ██║██║██╔████╔██║]],
[[██║╚██╗██║██╔══╝  ██║   ██║    ██╔══╝  ██║   ██║██║     ██╔═██╗ ██║██║╚██╗██║██║   ██║    ╚██╗ ██╔╝██║██║╚██╔╝██║]],
[[██║ ╚████║███████╗╚██████╔╝    ██║     ╚██████╔╝╚██████╗██║  ██╗██║██║ ╚████║╚██████╔╝     ╚████╔╝ ██║██║ ╚═╝ ██║]],
[[╚═╝  ╚═══╝╚══════╝ ╚═════╝     ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝       ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}
alpha.setup(dashboard.opts)


-- init and setup tree sitter
local config = require("nvim-treesitter.configs")
config.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "rust", "python", "javascript", "html" , "gdscript","nasm"},
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
