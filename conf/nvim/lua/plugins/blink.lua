return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      -- don't pop the menu up on every keystroke
      menu = { auto_show_delay_ms = 250 },
      -- don't highlight the first item automatically
      list = { selection = { preselect = false } },
    },
    sources = {
      -- trigger characters (`.`, `::`) and <C-Space> bypass this
      min_keyword_length = 3,
    },
    keymap = {
      -- Enter inserts a newline; accept with <C-y> instead
      ["<CR>"] = { "fallback" },
    },
  },
}
