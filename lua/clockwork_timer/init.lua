local M = {}
local wk = require("which-key")
local token = os.getenv("CLOCKWORK_TOKEN")

if not token then
	vim.notify("CLOCKWORK_TOKEN not set in environment", vim.log.levels.ERROR)
	return M
end

local function get_branch()
	local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if not handle then
		return nil
	end
	local branch = handle:read("*a")
	handle:close()

	branch = branch:gsub("%s+", "") -- trim newline

	if branch == "" then
		return nil
	end

	return branch
end

local function get_issue_key_from_branch()
	-- read env var once
	local prefix = os.getenv("TICKET_PREFIX") or "TELFE"

	-- escape magic chars if user sets a weird prefix
	prefix = vim.pesc(prefix)

	-- build pattern dynamically
	local pattern = "^" .. prefix .. "%-?%d+"
	local branch
	get_branch()

	return branch:match(pattern)
end

local BASE_URL = "https://api.clockwork.report/v1"

local function post(path, data)
	local curl = require("plenary.curl")

	return curl.post(BASE_URL .. path, {
		body = data,
		headers = {
			["Authorization"] = "Token " .. token,
		},
	})
end

function M.start(issue_key)
	issue_key = (issue_key ~= "" and issue_key) or get_issue_key_from_branch()
	if not issue_key then
		vim.notify("Usage: :Clockwork start <ISSUE_KEY>", vim.log.levels.WARN)
		return
	end

	local res = post("/start_timer", "issue_key=" .. issue_key)
	if res.status == 200 then
		vim.notify("⏱ Timer started for " .. issue_key, vim.log.levels.INFO)
	elseif res.status == 422 then
		vim.notify("⚠️ Invalid issue key or request (422). Check the issue key: " .. issue_key, vim.log.levels.WARN)
	else
		vim.notify("❌ Failed to start timer (" .. res.status .. ")", vim.log.levels.ERROR)
	end
end

function M.stop(issue_key)
	issue_key = (issue_key ~= "" and issue_key) or get_issue_key_from_branch()
	if not issue_key then
		vim.notify("Usage: :ClockworkStop <ISSUE_KEY>", vim.log.levels.WARN)
		return
	end
	local res = post("/stop_timer", "issue_key=" .. issue_key)
	if res.status == 200 then
		vim.notify("✅ Timer stopped for " .. issue_key, vim.log.levels.INFO)
	elseif res.status == 422 then
		vim.notify("⚠️ Invalid issue key or request (422). Check the issue key: " .. issue_key, vim.log.levels.WARN)
	else
		vim.notify("❌ Failed to stop timer (" .. res.status .. ")", vim.log.levels.ERROR)
	end
end

-- Auto-register commands when module is required
vim.api.nvim_create_user_command("ClockworkStart", function(opts)
	M.start(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ClockworkStop", function(opts)
	M.stop(opts.args)
end, { nargs = "?" })

-- Start timer with <M-cg>
vim.keymap.set("n", "<M-cg>", function()
	M.start()
end, { noremap = true, silent = true, desc = "Clockwork Start Timer on current branch" })

-- Stop timer with <M-cs>
vim.keymap.set("n", "<M-cs>", function()
	M.stop()
end, { noremap = true, silent = true, desc = "Clockwork Stop Timer on current branch" })

wk.add({
	{ "<leader>c", group = "Clockwork" }, -- group title
	{
		"<leader>cg",
		function()
			M.start()
		end,
		desc = "Start Timer using current branch",
		mode = "n",
	},
	{
		"<leader>cs",
		function()
			M.stop()
		end,
		desc = "Stop Timer using current branch",
		mode = "n",
	},
})

return M
