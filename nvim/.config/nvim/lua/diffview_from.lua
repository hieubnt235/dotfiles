-- Helper for the <leader>gD maps in lua/plugins/diffview.lua: "diff from-to".
--
-- Each key fixes the FROM side; the TO side is chosen interactively. Choosing a
-- ref is two steps, because snacks pickers have one selectable list and the
-- right-hand pane is a preview, not a list -- so a branch's commits cannot be
-- picked from the branch picker itself. Step 1 picks the branch, step 2 picks a
-- commit on it. The branch tip is the first entry, so taking the top commit is
-- the same as "just this branch".
local M = {}

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

---@param from "working"|"staged"|"head"
local function cmd_for(from, ref)
  if from == "staged" then
    -- index vs ref. diffview's --staged takes an optional rev, default HEAD.
    return ("DiffviewOpen --staged %s"):format(ref)
  elseif from == "head" then
    return ("DiffviewOpen HEAD..%s"):format(ref)
  end
  -- working tree vs ref -- the CLion "Compare with Branch" comparison.
  return ("DiffviewOpen %s"):format(ref)
end

---FROM is fixed (working tree / staged / HEAD); pick the TO ref.
---@param from "working"|"staged"|"head"
function M.pick(from)
  pick_ref("TO", function(sha)
    vim.cmd(cmd_for(from, sha))
  end)
end

---Both sides picked. Two-dot (a..b): the literal difference between the two,
---which is what CLion's compare shows.
function M.pick_two()
  pick_ref("FROM", function(a)
    pick_ref("TO", function(b)
      vim.cmd(("DiffviewOpen %s..%s"):format(a, b))
    end)
  end)
end

return M
