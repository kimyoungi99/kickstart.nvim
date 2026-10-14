-- jdtls via nvim-jdtls (runs for every java buffer; start_or_attach reuses the client).
local jdtls = require 'jdtls'
local mason = vim.fn.stdpath 'data' .. '/mason/packages'

local root = vim.fs.root(0, { { 'gradlew', 'mvnw', 'settings.gradle', 'settings.gradle.kts' }, '.git', 'pom.xml', 'build.gradle', 'build.gradle.kts' })
if not root or vim.fn.executable 'jdtls' == 0 then
  return
end

-- Debug + test bundles. The runner/jacoco jars must not be loaded as bundles.
local bundles = vim.fn.glob(mason .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
for _, jar in ipairs(vim.fn.glob(mason .. '/java-test/extension/server/*.jar', true, true)) do
  if not jar:find 'runner%-jar%-with%-dependencies' and not jar:find 'jacocoagent' then
    table.insert(bundles, jar)
  end
end

-- Runtimes from mise installs (JavaSE-<major>), highest major as default.
local runtimes, seen = {}, {}
local mise_java = vim.env.HOME .. '/.local/share/mise/installs/java'
for name, type in vim.fs.dir(mise_java) do
  local major = type == 'directory' and tonumber(name:match '^%a*%-?(%d+)')
  if major and not name:find 'jre' and not seen[major] then
    seen[major] = true
    table.insert(runtimes, { name = major == 8 and 'JavaSE-1.8' or ('JavaSE-' .. major), path = mise_java .. '/' .. name, major = major })
  end
end
table.sort(runtimes, function(a, b)
  return a.major > b.major
end)
if runtimes[1] then
  runtimes[1].default = true
end

jdtls.start_or_attach {
  cmd = {
    'jdtls',
    '--jvm-arg=-Xmx2g',
    '--jvm-arg=-javaagent:' .. mason .. '/jdtls/lombok.jar',
    '-data',
    vim.fn.stdpath 'cache' .. '/jdtls/workspace/' .. vim.fs.basename(root),
  },
  root_dir = root,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.mockito.Mockito.*',
        },
        filteredTypes = { 'com.sun.*', 'io.micrometer.shaded.*', 'java.awt.*', 'jdk.*', 'sun.*' },
      },
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
      codeGeneration = {
        toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
        useBlocks = true,
      },
      configuration = { runtimes = runtimes },
    },
  },
  init_options = { bundles = bundles },
  on_attach = function(_, bufnr)
    jdtls.setup_dap { hotcodereplace = 'auto' }
    local function map(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
    end
    map('n', '<leader>jo', jdtls.organize_imports, 'Organize Imports')
    map('n', '<leader>jv', jdtls.extract_variable, 'Extract Variable')
    map('n', '<leader>jc', jdtls.extract_constant, 'Extract Constant')
    map('n', '<leader>jt', jdtls.test_nearest_method, 'Test Nearest Method')
    map('n', '<leader>jT', jdtls.test_class, 'Test Class')
    map('v', '<leader>jm', function()
      jdtls.extract_method(true)
    end, 'Extract Method')
  end,
}
