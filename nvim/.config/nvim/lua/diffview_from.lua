-- Helper for the <leader>gD maps in lua/plugins/diffview.lua: "diff from-to".
--
-- Each key fixes one side; the other is a ref chosen interactively. Choosing a
-- ref is two steps, because snacks pickers have one selectable list and the
-- right-hand pane is a preview, not a list -- so a branch's commits cannot be
-- picked from the branch picker itself. Step 1 picks the branch, step 2 picks a
-- commit on it. The branch tip is the first entry, so taking the top commit is
-- the same as "just this branch".
local M = {}

---Focus a normal editor window before opening any diffview.
---
---diffview opens its tab with `:tab split` of the CURRENT window. From a
---sidebar (neo-tree, Outline, a terminal panel) that copies the sidebar buffer
---into the new tab, edgy grabs it while diffview is still building its
---windows, and the two sides come out swapped: working tree on the LEFT.
---(A/B verified: same keys with edgy's autocmds cleared = correct sides.)
---A typed :DiffviewOpen from a sidebar still hits this; the keys don't.
function M.focus_editor()
  local function normal(win)
    return vim.api.nvim_win_get_config(win).relative == ""
      and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
  end
  if normal(vim.api.nvim_get_current_win()) then
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if normal(win) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

---Run a diffview command from a normal editor window (see focus_editor).
---@param cmd string
function M.open(cmd)
  M.focus_editor()
  vim.cmd(cmd)
end

---Branch picker, then a commit picker scoped to that branch.
---@param label string shown in both picker titles
---@param cb fun(sha: string, branch: string)
local function pick_ref(label, cb)
  Snacks.picker.git_branches({
    all = true,
    title = label .. ": branch  —  Enter to select",
    confirm = function(picker, item)
      picker:close()
      local branch = item and (item.branch or item.commit)
      if not branch then
        return
      end
      -- Defer so the picker window is torn down before the next one opens.
      vim.schedule(function()
        Snacks.picker.git_log({
          -- opts.cmd_args is appended after `git log`, so this scopes the log
          -- to the chosen branch.
          cmd_args = { branch },
          -- No preview pane. The default git_log preview runs `git show <sha>`
          -- on every cursor move, which stalls badly on large commits -- and we
          -- only need the subject line to pick one.
          layout = { preview = false },
          title = label .. ": commit on " .. branch .. "  —  Enter to select",
          confirm = function(p, c)
            p:close()
            local sha = c and c.commit
            if not sha then
              return
            end
            vim.schedule(function()
              cb(sha, branch)
            end)
          end,
        })
      end)
    end,
  })
end

---Diffview always puts the working tree / INDEX on the RIGHT (measured from a
---normal window, 2026-09-26), so the picked ref is the LEFT side.
---Want the other order? Ctrl-w x in a diff window swaps the two on screen.
---@param what "working"|"staged"
local function cmd_for(what, ref)
  if what == "staged" then
    -- ref -> INDEX. diffview's --staged takes an optional rev, default HEAD.
    return ("DiffviewOpen --staged %s"):format(ref)
  end
  -- ref -> working tree -- the CLion "Compare with Branch" comparison. The
  -- right side is the real file on disk: editable, LSP attached.
  return ("DiffviewOpen %s"):format(ref)
end

---Pick a ref and diff it against the working tree / INDEX.
---@param what "working"|"staged"
function M.pick(what)
  pick_ref("FROM", function(sha)
    M.open(cmd_for(what, sha))
  end)
end

---Both sides picked. Two-dot (a..b): the literal difference between the two,
---which is what CLion's compare shows.
function M.pick_two()
  pick_ref("FROM", function(a)
    pick_ref("TO", function(b)
      M.open(("DiffviewOpen %s..%s"):format(a, b))
    end)
  end)
end

return M
