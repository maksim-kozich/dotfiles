-- Stay close to Neovim defaults; only theme + fuzzy finder.

vim.g.mapleader = " "
vim.o.number = true -- absolute line numbers

-- TRYING themes: installed together; switch live with `:colorscheme <name>`.
-- Keep the winner, then remove the rest (here + `:lua vim.pack.del({...})`).
vim.pack.add({
  "https://github.com/p00f/alabaster.nvim",              -- alabaster
  "https://github.com/rktjmp/lush.nvim",                 -- (needed by zenbones)
  "https://github.com/zenbones-theme/zenbones.nvim",     -- zenwritten, zenbones, neobones
  "https://github.com/aktersnurra/no-clown-fiesta.nvim", -- no-clown-fiesta
  "https://github.com/slugbyte/lackluster.nvim",         -- lackluster, lackluster-mint
  "https://github.com/vague-theme/vague.nvim",           -- vague
  "https://github.com/folke/tokyonight.nvim",            -- tokyonight-moon (LazyVim default)
  "https://github.com/chriskempson/vim-tomorrow-theme",  -- Tomorrow-Night (= Ghostty default palette)
})
-- vim.cmd.colorscheme("Tomorrow-Night") -- TRYING; was "quiet"
vim.cmd.colorscheme("quiet") -- TRYING; was "quiet"
vim.cmd.highlight("Normal guibg=NONE ctermbg=NONE") -- use terminal (Ghostty) background
vim.cmd.highlight("link NormalFloat Normal") -- floats (diffview g?, LSP hover) too; Vim-era themes don't set it
-- terminals inside nvim (e.g. Claude Code): Ghostty's 16 colors (its default palette),
-- instead of nvim's brighter built-in ones, so programs look the same as outside
for i, color in ipairs({
  "#1d1f21", "#cc6666", "#b5bd68", "#f0c674", "#81a2be", "#b294bb", "#8abeb7", "#c5c8c6",
  "#666666", "#d54e53", "#b9ca4a", "#e7c547", "#7aa6da", "#c397d8", "#70c0b1", "#eaeaea",
}) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
vim.cmd.highlight("VertSplit guibg=NONE ctermbg=NONE") -- window separator line: no black band (WinSeparator links here)
-- quiet's selection/search are bright reversed orange/blue/magenta: PyCharm-like instead
vim.api.nvim_set_hl(0, "Visual", { bg = "#2e436e" }) -- selection: muted blue
vim.api.nvim_set_hl(0, "Search", { fg = "#1e1e1e", bg = "#a68a50" }) -- matches: muted gold, dark text
vim.api.nvim_set_hl(0, "CurSearch", { fg = "#1e1e1e", bg = "#c9a65f" }) -- match under cursor: brighter gold
vim.api.nvim_set_hl(0, "IncSearch", { link = "CurSearch" }) -- match while typing /...
-- selected line in the tree / Structure panel (and anywhere 'cursorline' is on): quiet's
-- #303030 is barely visible on the terminal background
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#43474d" })
-- diffs (tree ctrl-d, diffview): quiet's are bright blocks; PyCharm-like dark tints instead,
-- text keeps its own color. Filler lines (other side's added lines) blank, not `-----`.
vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#294436" }) -- added lines: dark green
vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#343638", fg = "#343638" }) -- removed / filler: gray
vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2b3a4a" }) -- changed lines: dark blue
vim.api.nvim_set_hl(0, "DiffText", { bg = "#3d5a7a" }) -- changed part of the line: lighter blue
vim.opt.fillchars:append({ diff = " " })
-- folded lines (unchanged parts of a diff): PyCharm's folded text (Islands Dark scheme)
-- instead of quiet's black band, and a different gray than comments
vim.api.nvim_set_hl(0, "Folded", { fg = "#868991", bg = "#393b40" })
-- mouse wheel over the side of a diff that isn't focused scrolls only that side; re-align
-- the others to it (they're scroll-bound, but that only follows the focused window)
vim.api.nvim_create_autocmd("WinScrolled", {
  callback = function()
    local cur = vim.api.nvim_get_current_win()
    for id in pairs(vim.v.event) do
      local win = tonumber(id)
      if win and win ~= cur and vim.api.nvim_win_is_valid(win) and vim.wo[win].scrollbind then
        return vim.api.nvim_win_call(win, function() vim.cmd("syncbind") end)
      end
    end
  end,
})

-- fzf-lua: files / live grep / buffers (plugins via built-in vim.pack)
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
local fzf = require("fzf-lua")
-- Quiet look: fzf follows the (grey) colorscheme; the only color is a warm accent
-- on matches (results, preview). Query, hints, paths, line numbers stay grey.
local warm = "#d7af5f"
vim.api.nvim_set_hl(0, "FzfLuaMatch", { fg = warm, bold = true })
fzf.setup({
  winopts = { height = 0.95, width = 0.95, row = 0.5, col = 0.5 }, -- default 85% x 80%
  fzf_colors = { -- derive fzf colors from the nvim colorscheme, except matches
    true,
    ["hl"] = { "fg", "FzfLuaMatch", "bold" },
    ["hl+"] = { "fg", "FzfLuaMatch", "bold" },
  },
  hls = {
    live_prompt = "FzfLuaFzfQuery", -- typed query in live grep (default: pink)
    search = "FzfLuaMatch", -- match in preview (default: orange block)
    header_bind = "Comment", -- hints, e.g. "<ctrl-g> to Fuzzy Search" (default: yellow/red)
    header_text = "Comment",
    fzf = { header = "Comment" }, -- plain hint text, e.g. "to"
  },
  grep = {
    winopts = { treesitter = { fzf_colors = false } }, -- keep matches warm after ctrl-g (default: reverse)
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 "
      .. "--colors=path:none --colors=line:none --colors=column:none --colors=match:none "
      .. "--colors=match:fg:" .. warm:gsub("#(%x%x)(%x%x)(%x%x)", "0x%1,0x%2,0x%3")
      .. " --colors=match:style:bold -e",
  },
  -- ctrl-q: send results to quickfix; ctrl-o: toggle .gitignore'd files (files + live grep)
  -- (defaults alt-q / alt-i need Option-as-Alt)
  actions = {
    files = {
      true,
      ["ctrl-q"] = { fn = fzf.actions.file_sel_to_qf, prefix = "select-all" },
      ["ctrl-o"] = { fn = fzf.actions.toggle_ignore, reuse = true },
    },
  },
})
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find file" })
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Search text" })
vim.keymap.set("n", "<leader>,", fzf.buffers, { desc = "Open buffers" }) -- LazyVim's key
vim.keymap.set("n", "<leader>bl", fzf.buffers, { desc = "Open buffers" }) -- = space , (with the space b… keys)
vim.keymap.set("n", "<leader>h", fzf.help_tags, { desc = "Search help" })

-- lualine: statusline; theme "auto" follows the colorscheme, except the wide middle part:
-- quiet makes it near-white (#dadada); a dark gray instead, in every mode and inactive windows
vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })
local lualine_theme = require("lualine.themes.auto")
for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
  lualine_theme[mode] = lualine_theme[mode] or {}
  lualine_theme[mode].c = { fg = "#a8a8a8", bg = "#3a3d41" }
end
require("lualine").setup({ options = { theme = lualine_theme } })

-- diffview: review changes with a file panel + editable side-by-side diff
-- (:DiffviewOpen, :DiffviewFileHistory, :DiffviewClose; g? lists keys)
vim.pack.add({ "https://github.com/sindrets/diffview.nvim" })
local dv_actions = require("diffview.actions")
local dv_close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } }
-- space e: toggle the file panel, like the tree elsewhere (diffview's default: focus it)
local dv_files = { "n", "<leader>e", dv_actions.toggle_files, { desc = "Toggle the file panel" } }
require("diffview").setup({
  use_icons = false, -- no nvim-web-devicons; avoids its warning
  file_panel = { listing_style = "list" }, -- flat list by default (`i` toggles tree)
  keymaps = { -- added to diffview's defaults, only inside its windows
    view = { dv_close, dv_files },
    file_panel = { dv_close, dv_files },
    file_history_panel = {
      dv_close,
      dv_files,
      -- default is <C-A-d>, but Option is reserved for Lithuanian input
      { "n", "O", dv_actions.open_in_diffview, { desc = "Open the whole commit (all files)" } },
    },
  },
})
-- diffview's commit details (L in the log / file list) float has no close key: q / Esc close it
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "diffview://*/commit_log",
  callback = function(args)
    for _, key in ipairs({ "q", "<Esc>" }) do
      vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = args.buf, nowait = true, desc = "Close" })
    end
  end,
})
-- git keys follow LazyVim where it has one (gd, gl, gf, gb, gg, gh = hunks)
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git diff (diffview)" })
vim.keymap.set("n", "<leader>gl", "<cmd>DiffviewFileHistory<cr>", { desc = "Git log: current branch" })
vim.keymap.set("n", "<leader>gL", "<cmd>DiffviewFileHistory --all<cr>", { desc = "Git log: all branches" })
-- in visual mode: commits that changed the selected lines
vim.keymap.set("x", "<leader>gl", ":DiffviewFileHistory<cr>", { desc = "Git log: selected lines" })
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git log: current file" })

-- lazygit.nvim: lazygit (installed separately) in a floating window; q quits it. Opening a
-- file there lands in this nvim (lazygit's editPreset: nvim-remote, see its config).
vim.pack.add({ "https://github.com/kdheepak/lazygit.nvim" })
vim.g.lazygit_floating_window_scaling_factor = 0.95 -- same size as the fzf pop-ups
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })

-- nvim-tree: file tree on the left, defaults for now (g? lists keys)
vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })
require("nvim-tree").setup({
  renderer = { -- PyCharm-like: git status as name color, no git icons
    highlight_git = "all", -- name + icon
    icons = {
      show = { git = false },
      -- empty folders: same icon as other folders (no outlined variant)
      glyphs = { folder = { empty = "\u{e5ff}", empty_open = "\u{e5fe}" } },
    },
  },
  filters = { git_ignored = false }, -- show .gitignore'd too (gray); `I` toggles
  git = { show_on_dirs = false }, -- git colors on changed files only, not on their parent folders
  hijack_directories = { enable = false }, -- `nvim <dir>` is handled by the VimEnter autocmd below
  -- root = nvim's working directory, changed only by :cd (no tree key changes it, see below)
  sync_root_with_cwd = true,
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    api.config.mappings.default_on_attach(bufnr) -- keep the defaults
    vim.keymap.del("n", "<C-k>", { buffer = bufnr }) -- was file info; now: panel above
    -- no key changes the root (go up / make a folder the root): only :cd does
    for _, k in ipairs({ "-", "<C-]>", "<2-RightMouse>" }) do vim.keymap.del("n", k, { buffer = bufnr }) end
    local function opts(desc) return { buffer = bufnr, nowait = true, desc = "nvim-tree: " .. desc } end
    -- open / expand, except on the top (root) line, where it would go up a folder
    local function open() if api.tree.get_node_under_cursor().parent then api.node.open.edit() end end
    for _, k in ipairs({ "<CR>", "o", "<2-LeftMouse>" }) do vim.keymap.set("n", k, open, opts("Open")) end
    -- l / Right: expand folder / open file; h / Left: collapse to parent folder
    for _, k in ipairs({ "l", "<Right>" }) do vim.keymap.set("n", k, open, opts("Open / Expand")) end
    for _, k in ipairs({ "h", "<Left>" }) do
      vim.keymap.set("n", k, api.node.navigate.parent_close, opts("Collapse to Parent"))
    end
    -- ctrl-i / ctrl-o: show/hide .gitignore'd files (same as I), instead of jumplist moves;
    -- ctrl-o matches the fzf pop-ups. ctrl-i stays separate from Tab (preview) in Ghostty.
    vim.keymap.set("n", "<C-i>", api.filter.git.ignored.toggle, opts("Toggle Filter: Git Ignored"))
    vim.keymap.set("n", "<C-o>", api.filter.git.ignored.toggle, opts("Toggle Filter: Git Ignored"))
    -- Shift+Up/Down: select a range of lines; then c / x (copy / cut), go to a folder, p (paste)
    -- (also Shift+j/k, replacing the defaults J/K: last/first sibling)
    for _, k in ipairs({ { "<S-Down>", "j" }, { "J", "j" }, { "<S-Up>", "k" }, { "K", "k" } }) do
      local desc = k[2] == "j" and "Select Down" or "Select Up"
      vim.keymap.set("n", k[1], "V" .. k[2], opts(desc))
      vim.keymap.set("x", k[1], k[2], opts(desc))
    end
    -- ctrl-d: diff side by side in the editor area, tree stays on the left; q closes it.
    --   2 files (selected with Shift+Up/Down, or marked with `m`): compare them (PyCharm
    --   "Compare Files"); 1 file (under the cursor): its git changes, last commit on the left,
    --   working copy on the right (PyCharm "Show Diff"). `C` shows only changed files.
    local end_diff -- closes the current ctrl-d diff, if any
    -- editor window: the last one used, else any non-tree window, else a new one. Returns
    -- the buffer it showed before (nil for a new window), to go back to when the diff closes.
    local function to_editor_win()
      if end_diff then end_diff() end
      local tree_win = vim.api.nvim_get_current_win()
      local function is_editor(w)
        return w ~= tree_win and vim.api.nvim_win_is_valid(w)
          and vim.api.nvim_win_get_config(w).relative == ""
      end
      local win = vim.fn.win_getid(vim.fn.winnr("#"))
      if not is_editor(win) then
        win = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(is_editor)
      end
      if not win then return vim.cmd("botright vsplit") end
      vim.api.nvim_set_current_win(win)
      vim.cmd("diffoff!") -- end any other diff in this tab
      return vim.api.nvim_win_get_buf(win)
    end
    -- q in either side: close the diff, the editor window shows `prev` again. :q on one
    -- side: the other one stays, out of diff mode. q is unmapped again either way.
    local function diff_session(editor, other, prev)
      local bufs = { vim.api.nvim_win_get_buf(editor), vim.api.nvim_win_get_buf(other) }
      local group = vim.api.nvim_create_augroup("tree_diff", { clear = true })
      local function cleanup()
        vim.api.nvim_clear_autocmds({ group = group })
        end_diff = nil
        for _, b in ipairs(bufs) do
          if vim.api.nvim_buf_is_valid(b) then pcall(vim.keymap.del, "n", "q", { buffer = b }) end
        end
        for _, w in ipairs({ editor, other }) do
          if vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_call(w, function() vim.cmd("diffoff") end) end
        end
      end
      local function close()
        cleanup()
        if vim.api.nvim_win_is_valid(other) then vim.api.nvim_win_close(other, true) end
        if not vim.api.nvim_win_is_valid(editor) then return end
        if prev and vim.api.nvim_buf_is_valid(prev) then vim.api.nvim_win_set_buf(editor, prev)
        else pcall(vim.api.nvim_win_close, editor, false) end
      end
      vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = { tostring(editor), tostring(other) },
        callback = function() vim.schedule(cleanup) end,
      })
      for _, b in ipairs(bufs) do
        vim.keymap.set("n", "q", close, { buffer = b, nowait = true, desc = "Close the diff" })
      end
      end_diff = cleanup
    end
    local function compare(a, b)
      local prev = to_editor_win()
      vim.cmd.edit(vim.fn.fnameescape(a))
      local editor = vim.api.nvim_get_current_win()
      vim.cmd("rightbelow vertical diffsplit " .. vim.fn.fnameescape(b))
      diff_session(editor, vim.api.nvim_get_current_win(), prev)
    end
    local function git_diff(path)
      local root = vim.fs.root(path, ".git")
      if not root then return vim.notify("Git diff: not in a git repo", vim.log.levels.WARN) end
      local head = vim.system({ "git", "-C", root, "show", "HEAD:" .. vim.fs.relpath(root, path) },
        { text = true }):wait()
      local lines = head.code == 0 and vim.split(head.stdout, "\n", { plain = true }) or {} -- new file: empty
      if lines[#lines] == "" then table.remove(lines) end
      local prev = to_editor_win()
      vim.cmd.edit(vim.fn.fnameescape(path))
      local editor, filetype = vim.api.nvim_get_current_win(), vim.bo.filetype
      vim.cmd("leftabove vnew") -- read-only scratch buffer with the HEAD version
      local head_win = vim.api.nvim_get_current_win()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.bo.buftype, vim.bo.bufhidden, vim.bo.modifiable = "nofile", "wipe", false
      vim.bo.filetype = filetype
      pcall(vim.api.nvim_buf_set_name, 0, vim.fs.basename(path) .. " (HEAD)")
      vim.cmd.diffthis()
      vim.api.nvim_set_current_win(editor)
      vim.cmd.diffthis()
      diff_session(editor, head_win, prev)
    end
    local function diff_nodes(nodes)
      local files = vim.tbl_filter(function(n) return n and n.type ~= "directory" end, nodes)
      api.marks.clear()
      if #files == 1 then git_diff(files[1].absolute_path)
      elseif #files == 2 then compare(files[1].absolute_path, files[2].absolute_path)
      else vim.notify("Diff: 1 file (git changes) or 2 files (compare)", vim.log.levels.WARN) end
    end
    local function marked_or_current() -- the marked nodes, else the one under the cursor
      local marks = api.marks.list()
      return #marks > 0 and marks or { api.tree.get_node_under_cursor() }
    end
    local function selected() -- nodes on the visually selected lines (leaves visual mode)
      local first, last = vim.fn.line("v"), vim.fn.line(".")
      if first > last then first, last = last, first end
      vim.cmd("normal! \27")
      local nodes = {}
      for lnum = first, last do
        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
        table.insert(nodes, api.tree.get_node_under_cursor())
      end
      return nodes
    end
    local diff_desc = "Diff (1 file: git changes, 2: compare)"
    vim.keymap.set("n", "<C-d>", function() diff_nodes(marked_or_current()) end, opts(diff_desc))
    vim.keymap.set("x", "<C-d>", function() diff_nodes(selected()) end, opts(diff_desc))
    -- ga / gA / gu / gR: git add (stage; gA: even if ignored) / unstage / revert to the last
    -- commit, for the file or folder under the cursor, or the selected / marked ones. The
    -- tree's root line is skipped, so they never act on the whole repo by accident.
    local function git_run(args, nodes, confirm)
      nodes = vim.tbl_filter(function(n) return n and n.parent end, nodes)
      api.marks.clear()
      if #nodes == 0 then return end
      if confirm then
        local names = table.concat(vim.tbl_map(function(n) return n.name end, nodes), ", ")
        if vim.fn.confirm(confirm .. " " .. names .. "?", "&Yes\n&No", 2) ~= 1 then return end
      end
      local root = vim.fs.root(nodes[1].absolute_path, ".git")
      if not root then return vim.notify("git: not in a git repo", vim.log.levels.WARN) end
      local cmd = vim.list_extend({ "git", "-C", root }, args)
      table.insert(cmd, "--")
      for _, n in ipairs(nodes) do table.insert(cmd, n.absolute_path) end
      local result = vim.system(cmd, { text = true }):wait()
      if result.code ~= 0 then
        return vim.notify("git " .. args[1] .. " failed\n" .. result.stderr, vim.log.levels.WARN)
      end
      vim.cmd.checktime() -- reload open buffers of reverted files
      api.tree.reload() -- update the git colors now
    end
    local git_keys = {
      ga = { { "add" }, nil, "Git Add" },
      gA = { { "add", "-f" }, nil, "Git Add -f (ignored too)" },
      gu = { { "restore", "--staged" }, nil, "Git Unstage" },
      -- staged and unstaged changes both go; untracked files aren't touched (git refuses).
      -- Capital R: harder to hit by accident, and gr… are nvim's LSP keys (grn, gra, ...)
      gR = { { "restore", "--source=HEAD", "--staged", "--worktree" }, "Discard all changes in",
        "Git Revert (asks first)" },
    }
    for key, k in pairs(git_keys) do
      vim.keymap.set("n", key, function() git_run(k[1], marked_or_current(), k[2]) end, opts(k[3]))
      vim.keymap.set("x", key, function() git_run(k[1], selected(), k[2]) end, opts(k[3]))
    end
    -- gd: diffview (like space gd) limited to the file / folder under the cursor, or the
    -- selected / marked ones; the root line: all changes. Limited, it hides untracked
    -- files: diffview would list all of the repo's anyway. An untracked file on its own:
    -- the ctrl-d view instead (all lines new).
    local function diffview_for(nodes)
      api.marks.clear()
      nodes = vim.tbl_filter(function(n) return n and n.parent end, nodes)
      if #nodes == 0 then return vim.cmd("DiffviewOpen") end
      local n = nodes[1]
      if #nodes == 1 and n.type ~= "directory" and n.git_status and n.git_status.file == "??" then
        return git_diff(n.absolute_path)
      end
      local paths = vim.tbl_map(function(node) return vim.fn.fnameescape(node.absolute_path) end, nodes)
      vim.cmd("DiffviewOpen --untracked-files=no -- " .. table.concat(paths, " "))
    end
    vim.keymap.set("n", "gd", function() diffview_for(marked_or_current()) end, opts("Git Diff (diffview)"))
    vim.keymap.set("x", "gd", function() diffview_for(selected()) end, opts("Git Diff (diffview)"))
  end,
})
-- empty folders: no expand arrow, like PyCharm. No option for it, so this wraps an
-- nvim-tree internal; if an nvim-tree update breaks it, just delete this block.
local padding = require("nvim-tree.renderer.components.padding")
local get_arrows = padding.get_arrows
padding.get_arrows = function(node)
  local arrows = get_arrows(node)
  if arrows and node.nodes and #node.nodes == 0 and not node.has_children then
    arrows.str = string.rep(" ", vim.fn.strdisplaywidth(arrows.str))
  end
  return arrows
end
-- .gitignore'd folders: gray like ignored files. git.show_on_dirs = false turns off all git
-- colors on folders, so this wraps an nvim-tree internal to keep a folder's own "ignored"
-- status; if an nvim-tree update breaks it, just delete this block.
local DirectoryNode = require("nvim-tree.node.directory")
local get_git_xy = DirectoryNode.get_git_xy
DirectoryNode.get_git_xy = function(self)
  local xy = get_git_xy(self)
  if xy == nil and self.git_status and self.git_status.file == "!!" then return { "!!" } end
  return xy
end
vim.api.nvim_set_hl(0, "NvimTreeGitFolderIgnoredHL", { link = "NvimTreeGitFileIgnoredHL" })
-- folder icons and arrows: text color instead of blue
vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { link = "Normal" })
-- ignored files: plain gray (default links to Comment, which is bold in quiet)
vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg })
-- git status colors: quiet makes them all plain text color, so PyCharm (Darcula)-like ones
for group, fg in pairs({
  Dirty = "#7cadf8", -- modified: blue, as in PyCharm (new UI)
  Renamed = "#7cadf8",
  Staged = "#83b97f", -- staged (e.g. added): green, as in PyCharm
  New = "#e88f89", -- untracked: red, as in PyCharm ("Unversioned Files"; measured, sRGB)
  Deleted = "#808080",
  Merge = "#d54e53", -- conflict: bright red
}) do
  vim.api.nvim_set_hl(0, "NvimTreeGitFile" .. group .. "HL", { fg = fg })
  vim.api.nvim_set_hl(0, "NvimTreeGit" .. group .. "Icon", { fg = fg })
end
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File tree: toggle" })
-- PyCharm "Select Opened File": open the tree (if closed) and jump to the current file;
-- pressed in the tree: the file of the window used last
vim.keymap.set("n", "<leader>E", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "NvimTree" then
    local prev = vim.fn.win_getid(vim.fn.winnr("#"))
    if prev == 0 then return end
    buf = vim.api.nvim_win_get_buf(prev)
  end
  require("nvim-tree.api").tree.find_file({ buf = buf, open = true, focus = true })
end, { desc = "File tree: reveal current file" })
-- `/` in the tree like PyCharm speed search: cursor still jumps while typing, but no match
-- highlights leak into other windows, and the editor's last search (n / N) survives.
local tree_search = vim.api.nvim_create_augroup("tree_search", {})
vim.api.nvim_create_autocmd("BufEnter", {
  group = tree_search,
  pattern = "NvimTree_*",
  callback = function()
    vim.b.saved_search = vim.fn.getreg("/")
    vim.o.hlsearch = false
  end,
})
vim.api.nvim_create_autocmd("BufLeave", {
  group = tree_search,
  pattern = "NvimTree_*",
  callback = function()
    local saved = vim.b.saved_search or ""
    vim.o.hlsearch = true
    -- autocmds restore the search pattern when they finish, so set it right after
    vim.schedule(function() vim.fn.setreg("/", saved) end)
  end,
})
-- `nvim <dir>`: tree as a sidebar + empty buffer on the right, instead of a full-window tree
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 0 then return end
    vim.cmd.enew() -- empty buffer replaces the directory one
    vim.cmd.bwipeout(data.buf)
    -- blank placeholder: no line number / `~` rows; wiped once a file opens in its window
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.opt_local.number = false
    vim.opt_local.fillchars:append({ eob = " " })
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_create_autocmd("BufWinEnter", { -- first file opened there: back to normal look
      callback = function()
        if vim.api.nvim_get_current_win() ~= win then return end
        vim.wo[win].number = vim.go.number
        vim.wo[win].fillchars = vim.go.fillchars
        return true -- delete this autocmd
      end,
    })
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
  end,
})

-- aerial: PyCharm-like "Structure" panel on the right (classes / functions / headings).
-- Symbols come from treesitter parsers or an LSP; nvim bundles parsers only for
-- lua, vim, c, markdown, vimdoc, query. (? in the panel lists keys)
vim.pack.add({ "https://github.com/stevearc/aerial.nvim" })
-- Symbols overlapping lines changed since the last commit (gitsigns hunks) get the tree's
-- "modified" blue, like PyCharm; parents of a changed symbol too.
local function mark_changed(bufnr, items)
  local ok, gitsigns = pcall(require, "gitsigns")
  local ranges = {}
  for _, h in ipairs(ok and gitsigns.get_hunks(bufnr) or {}) do
    local first = math.max(h.added.start, 1) -- deleted lines: the line next to them
    table.insert(ranges, { first, first + math.max(h.added.count, 1) - 1 })
  end
  local function walk(list)
    for _, item in ipairs(list or {}) do
      item.changed = vim.iter(ranges):any(function(r)
        return r[1] <= item.end_lnum and r[2] >= item.lnum
      end)
      walk(item.children)
    end
  end
  walk(items)
  return items
end
require("aerial").setup({
  layout = { default_direction = "right" },
  show_guides = true, -- tree lines, like PyCharm
  nerd_font = true, -- other languages: font icons instead of [F], [C], ... (Ghostty font has them)
  -- yaml / json like PyCharm: <> mappings / objects, [] lists, ⓟ plain values
  -- (plain values come from queries/{yaml,json}/aerial.scm in this config)
  icons = {
    yaml = { Class = "<>", Enum = "[]", Property = "ⓟ" },
    json = { Class = "<>", Enum = "[]", Property = "ⓟ" },
    jsonc = { Class = "<>", Enum = "[]", Property = "ⓟ" },
  },
  filter_kind = { -- which kinds to list; yaml / json: all (aerial's default hides values)
    yaml = false,
    json = false,
    jsonc = false,
    _ = { "Class", "Constructor", "Enum", "Function", "Interface", "Module", "Method", "Struct" },
  },
  keymaps = { ["<C-j>"] = false, ["<C-k>"] = false }, -- were move + scroll; now: panels
  post_add_all_symbols = mark_changed,
  get_highlight = function(symbol, is_icon)
    if symbol.changed and not is_icon then return "AerialChanged" end
  end,
})
vim.api.nvim_set_hl(0, "AerialChanged", { fg = "#7cadf8" }) -- = tree's modified blue
vim.api.nvim_set_hl(0, "AerialClassIcon", { fg = "#a0a0a0" }) -- <> : light gray, like PyCharm
vim.api.nvim_set_hl(0, "AerialEnumIcon", { fg = "#a0a0a0" })
vim.api.nvim_set_hl(0, "AerialPropertyIcon", { fg = "#b294bb" }) -- ⓟ : purple (Ghostty palette)
-- gitsigns finishes after aerial (async): re-read symbols then, so the blue is up to date
vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function(args)
    local bufnr = args.data and args.data.buffer
    if bufnr then pcall(require("aerial").refetch_symbols, bufnr) end
  end,
})
-- current symbol: subtle gray bar like the tree's selected line (default: reversed magenta)
vim.api.nvim_set_hl(0, "AerialLine", { link = "CursorLine" })
vim.api.nvim_set_hl(0, "AerialLineNC", { link = "CursorLine" })
vim.keymap.set("n", "<leader>s", "<cmd>AerialToggle<cr>", { desc = "Structure panel: toggle" })
-- JSON with comments (devcontainer.json, tsconfig.json): filetype jsonc, so // comments
-- aren't flagged as errors (plain json's syntax paints them red); same parser as json
vim.filetype.add({
  filename = { ["devcontainer.json"] = "jsonc", [".devcontainer.json"] = "jsonc" },
  pattern = { [".*/tsconfig[^/]*%.json"] = "jsonc" },
})
vim.treesitter.language.register("json", "jsonc")
-- extra treesitter parsers for the panel: built once, in the background, with the system
-- C compiler into nvim's own data dir (no tree-sitter CLI / nvim-treesitter on the host).
-- To rebuild (e.g. update), delete ~/.local/share/nvim/site/parser/<lang>.so and restart.
local ts_parsers = {
  json = "https://github.com/tree-sitter/tree-sitter-json",
  yaml = "https://github.com/tree-sitter-grammars/tree-sitter-yaml",
}
local parser_dir = vim.fn.stdpath("data") .. "/site/parser" -- on 'runtimepath' by default
for lang, url in pairs(ts_parsers) do
  local so = parser_dir .. "/" .. lang .. ".so"
  if not vim.uv.fs_stat(so) then
    local src = vim.fn.stdpath("cache") .. "/ts-" .. lang
    local function done(msg, level) vim.schedule(function() vim.notify(msg, level) end) end
    vim.fn.mkdir(parser_dir, "p")
    vim.fn.delete(src, "rf")
    vim.system({ "git", "clone", "--depth=1", "--quiet", url, src }, {}, function(clone)
      if clone.code ~= 0 then return done(lang .. " parser: git clone failed", vim.log.levels.WARN) end
      local cmd = { "cc", "-shared", "-fPIC", "-O2", "-I", src .. "/src", "-o", so, src .. "/src/parser.c" }
      if vim.uv.fs_stat(src .. "/src/scanner.c") then table.insert(cmd, src .. "/src/scanner.c") end
      vim.system(cmd, {}, function(build)
        if build.code ~= 0 then return done(lang .. " parser: build failed\n" .. build.stderr, vim.log.levels.WARN) end
        vim.fn.delete(src, "rf")
        done(lang .. " parser installed")
      end)
    end)
  end
end

-- gitsigns: PyCharm-like gutter bars on lines changed since the last commit
-- (blue modified, green added, gray mark where lines were deleted)
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
local bar = { text = "▎" }
local git_signs = {
  add = bar, change = bar, changedelete = bar, untracked = bar,
  delete = { text = "▁" }, topdelete = { text = "▔" },
}
require("gitsigns").setup({
  signs = git_signs,
  signs_staged = git_signs, -- staged changes: same bars, dimmer colors (gitsigns default)
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
    map("]h", function() gs.nav_hunk("next") end, "Next change (git)")
    map("[h", function() gs.nav_hunk("prev") end, "Previous change (git)")
    -- space gh…: the changed block (hunk) under the cursor, like LazyVim
    map("<leader>ghp", gs.preview_hunk_inline, "Preview change")
    map("<leader>ghr", gs.reset_hunk, "Revert change") -- PyCharm "Rollback Lines"
    map("<leader>ghs", gs.stage_hunk, "Stage change")
  end,
})
-- git blame for lines first..last of buf only (git blame -L: fast even on huge files);
-- unsaved edits count. Returns { [line] = "hash  date  author" } and the longest entry's width.
local function blame_range(buf, first, last)
  local path = vim.api.nvim_buf_get_name(buf)
  local root = vim.fs.root(path, ".git")
  if not root then return vim.notify("Git blame: not in a git repo", vim.log.levels.WARN) end
  local contents = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  local result = vim.system({ "git", "-C", root, "blame", "--date=short", "-L", first .. "," .. last,
    "--contents", "-", "--", vim.fs.relpath(root, path) }, { stdin = contents, text = true }):wait()
  if result.code ~= 0 then
    return vim.notify("git blame failed\n" .. result.stderr, vim.log.levels.WARN)
  end
  local entries, width = {}, 0
  for _, line in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
    -- hash [old file name, if the file was moved] (author date line) text
    local hash, author, date, lnum = line:match("^%^?(%x+)%s+[^(]*%((.-)%s+(%d+%-%d+%-%d+)%s+(%d+)%)")
    if hash then
      if author == "External file (--contents)" then hash, author = "", "Not Committed Yet" end
      local entry = ("%-8s %s %s"):format(hash:sub(1, 7), date, author)
      entries[tonumber(lnum)], width = entry, math.max(width, #entry)
    end
  end
  if width == 0 then return vim.notify("Git blame: couldn't read git's output", vim.log.levels.WARN) end
  return entries, width
end
local function visual_range() -- first, last line of the selection; leaves visual mode
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  vim.cmd("normal! \27")
  if first > last then first, last = last, first end
  return first, last
end
local blame_eol = vim.api.nvim_create_namespace("blame_eol")

-- PyCharm "Annotate with Git Blame": author / date column on the left, scrolls with the
-- file (Enter on a line: its commit). Pressed again (from either side) or q: closes it.
-- Also closes / clears the selection blames below.
local blame_filetypes = { ["gitsigns-blame"] = true, ["blame-lines"] = true }
vim.keymap.set("n", "<leader>gb", function()
  if #vim.api.nvim_buf_get_extmarks(0, blame_eol, 0, -1, { limit = 1 }) > 0 then
    return vim.api.nvim_buf_clear_namespace(0, blame_eol, 0, -1)
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if blame_filetypes[vim.bo[vim.api.nvim_win_get_buf(w)].filetype] then
      return vim.api.nvim_win_close(w, true)
    end
  end
  require("gitsigns").blame()
end, { desc = "Git: blame (annotate) toggle" })

-- visual space gb: the same column, filled only for the selected lines. q in the column
-- or space gb: closes it.
vim.keymap.set("x", "<leader>gb", function()
  local first, last = visual_range()
  local src_win, src_buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  local entries, width = blame_range(src_buf, first, last)
  if not entries then return end
  local column = {} -- one entry per source line; blank outside the selection
  for i = 1, vim.api.nvim_buf_line_count(src_buf) do column[i] = entries[i] or "" end
  vim.cmd("leftabove " .. math.min(width + 1, 50) .. "vnew")
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, column)
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].modifiable = "nofile", "wipe", false
  vim.bo[buf].filetype = "blame-lines"
  pcall(vim.api.nvim_buf_set_name, buf, ("blame %s:%d-%d"):format(vim.fs.basename(vim.api.nvim_buf_get_name(src_buf)), first, last))
  for opt, value in pairs({ number = false, relativenumber = false, signcolumn = "no",
    foldcolumn = "0", wrap = false, winfixwidth = true, winhighlight = "Normal:Comment" }) do
    vim.wo[win][opt] = value
  end
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "Close" })
  -- keep both sides on the same lines; the file can't wrap while the column is open
  local src_wrap = vim.wo[src_win].wrap
  vim.wo[src_win].wrap = false
  for _, w in ipairs({ win, src_win }) do
    vim.wo[w].scrollbind, vim.wo[w].cursorbind = true, true
  end
  vim.api.nvim_set_current_win(src_win)
  vim.cmd("syncbind")
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(src_win) then
        vim.wo[src_win].scrollbind, vim.wo[src_win].cursorbind = false, false
        vim.wo[src_win].wrap = src_wrap
      end
    end,
  })
end, { desc = "Git blame: selected lines (column)" })

-- visual space gB: the selected lines' blame as gray text at their ends, like GitLens.
-- space gb (normal): clears it.
vim.keymap.set("x", "<leader>gB", function()
  local first, last = visual_range()
  local entries = blame_range(0, first, last)
  if not entries then return end
  vim.api.nvim_buf_clear_namespace(0, blame_eol, 0, -1)
  for lnum, entry in pairs(entries) do
    vim.api.nvim_buf_set_extmark(0, blame_eol, lnum - 1, 0, {
      virt_text = { { "    " .. entry, "Comment" } },
      virt_text_pos = "eol",
    })
  end
end, { desc = "Git blame: selected lines (end of line)" })

-- space gc: the commit that last changed the cursor line (blames just that line), opened in
-- diffview with all its files, this file selected
vim.keymap.set("n", "<leader>gc", function()
  local lnum = vim.fn.line(".")
  local entries = blame_range(0, lnum, lnum)
  local hash = entries and entries[lnum]:match("^%x+")
  if not hash then
    if entries then vim.notify("Git commit: this line isn't committed yet", vim.log.levels.INFO) end
    return
  end
  vim.cmd(("DiffviewOpen %s^! --selected-file=%s"):format(hash, vim.fn.fnameescape(vim.fn.expand("%:p"))))
end, { desc = "Git: commit of this line" })
vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#83b97f" })
vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#7cadf8" })
vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#7cadf8" })
vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#83b97f" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#808080" })
vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = "#808080" })
vim.o.signcolumn = "yes" -- keep the gutter column, so text doesn't shift when bars appear

-- which-key: after <leader> (or g, z, ", ...) and a short pause, a popup lists the next keys.
-- Names come from each mapping's `desc`; groups (prefixes) are named here.
vim.pack.add({ "https://github.com/folke/which-key.nvim" })
require("which-key").setup({
  preset = "helix", -- popup in the bottom-right corner, like Helix
  icons = { mappings = false }, -- no per-mapping icons (no icon plugin installed)
  spec = {
    { "<leader>g", group = "git" },
    { "<leader>gh", group = "hunks (changed block)" },
    { "<leader>b", group = "buffers" },
  },
})

-- space bc / bo: close the current buffer / all others (LazyVim: bd / bo). Unlike :bd, windows
-- stay: each one showing the buffer switches to the previous file (or an empty buffer),
-- so the tree never takes over the screen. Unsaved changes: asks first (bc) / skipped (bo).
local function delete_buffer(buf)
  if vim.bo[buf].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Yes\n&No\n&Cancel", 3)
    if choice == 1 then vim.api.nvim_buf_call(buf, function() vim.cmd.write() end)
    elseif choice ~= 2 then return end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then vim.cmd.buffer(alt)
      else
        vim.cmd("silent! bprevious")
        if vim.api.nvim_get_current_buf() == buf then vim.cmd.enew() end
      end
    end)
  end
  if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
end
vim.keymap.set("n", "<leader>bc", function() delete_buffer(vim.api.nvim_get_current_buf()) end,
  { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bo", function()
  local current, skipped = vim.api.nvim_get_current_buf(), 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      if vim.bo[buf].modified then skipped = skipped + 1 else vim.api.nvim_buf_delete(buf, {}) end
    end
  end
  if skipped > 0 then vim.notify(skipped .. " buffer(s) with unsaved changes kept") end
end, { desc = "Close other buffers" })

-- space y: copy to the system clipboard (cmd+v elsewhere); plain y stays nvim-only.
-- Visual: the selection; normal: takes a motion like y (space yy: line, space yiw: word)
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })

-- OS-like moves (non-default; Option is reserved for Lithuanian input)
-- ctrl-h/j/k/l in normal mode: move to the panel (window) left / below / above / right,
-- like LazyVim (= ctrl-w h/j/k/l). Tree and Structure panel override ctrl-k / ctrl-j
-- for themselves, so they're unmapped there (see their setups).
for _, dir in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. dir .. ">", "<C-w>" .. dir, { desc = "Go to panel " .. dir })
end
-- ctrl+arrows in normal mode: resize the panel (window) by 2, like LazyVim
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Panel taller" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Panel shorter" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Panel wider" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Panel narrower" })
-- word back / forward (normal mode: b / w): ctrl+left / ctrl+right (in insert / command line
-- that's the default) and ctrl-h / ctrl-l
for _, k in ipairs({ { "<C-Left>", "b" }, { "<C-Right>", "w" } }) do
  vim.keymap.set({ "x", "o" }, k[1], k[2], { desc = k[2] == "b" and "Word back" or "Word forward" })
end
vim.keymap.set({ "x", "o" }, "<C-h>", "b", { desc = "Word back" })
vim.keymap.set({ "x", "o" }, "<C-l>", "w", { desc = "Word forward" })
vim.keymap.set({ "i", "c" }, "<C-h>", "<C-Left>", { desc = "Word back" })
vim.keymap.set({ "i", "c" }, "<C-l>", "<C-Right>", { desc = "Word forward" })
-- ctrl-l used to clear search highlight; now Esc does
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear search highlight" })

-- cmd+h / cmd+l, cmd+left / cmd+right (Ghostty sends them as <D-h> / <D-l> /
-- <D-Left> / <D-Right>, see its config):
-- first non-blank / last non-blank; pressed again: line start / end
local function line_edge(to_end)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- col: 0-based byte
  local line = vim.api.nvim_get_current_line()
  local insert = vim.fn.mode() == "i" -- insert cursor sits between chars
  local target
  if to_end then
    local last = #line:match("^(.-)%s*$") -- end of last non-blank
    local soft = insert and last or last - 1
    target = col == soft and (insert and #line or #line - 1) or soft
  else
    local first = (line:find("%S") or 1) - 1
    target = col == first and 0 or first
  end
  vim.api.nvim_win_set_cursor(0, { row, math.max(target, 0) })
end
for _, k in ipairs({ "<D-h>", "<D-Left>" }) do
  vim.keymap.set({ "n", "x", "i" }, k, function() line_edge(false) end, { desc = "Line start (smart)" })
  vim.keymap.set("c", k, "<Home>")
end
for _, k in ipairs({ "<D-l>", "<D-Right>" }) do
  vim.keymap.set({ "n", "x", "i" }, k, function() line_edge(true) end, { desc = "Line end (smart)" })
  vim.keymap.set("c", k, "<End>")
end

-- everything under ~/.zsh is sourced by zsh, whatever the extension
vim.filetype.add({
  pattern = { ['.*/%.zsh/.*%.sh'] = 'zsh' },
})
