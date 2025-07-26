local status, mason = pcall(require, "mason")
if not status then
  return
end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
  return
end

mason.setup({})

lspconfig.setup({
  ensure_installed = {
  'html',
  'bashls',
  'lua_ls',
  'svelte',
  'tailwindcss',
  'intelephense',
  'pyright',
  'eslint'
  },
})
