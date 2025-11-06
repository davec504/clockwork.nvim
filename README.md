# Clockwork.nvim
A lightweight Neovim plugin for starting and stopping **Clockwork** time-tracking timers directly from inside Git branches.

It automatically extracts issue keys from your branch name (e.g., `COMPANY-1234`, `COMPANY1234`, or any custom prefix) and sends start/stop timer requests to the Clockwork API.

Perfect for “start timer for whatever branch I’m on right now”—without switching tools.

---

## ✨ Features

- ✅ Start/stop timers with one keypress  
- ✅ Automatically extracts issue keys from branch names  
- ✅ Supports custom prefixes via `TICKET_PREFIX` env var  
- ✅ Handles missing tokens and invalid requests gracefully  
- ✅ Works with both:
  - `COMPANY-1234`
  - `COMPANY1234`
- ✅ Includes Which-Key group & mappings  
- ✅ Written in pure Lua, no setup function required  

---

## 📦 Installation (Lazy.nvim)

```lua
{
  "yourname/clockwork.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/which-key.nvim" },
  config = function()
    require("clockwork")
  end,
}
````

---

## 🔧 Environment Variables

### `CLOCKWORK_TOKEN` (required)

Your API token from Clockwork.

```bash
export CLOCKWORK_TOKEN="your_api_token"
```

### `TICKET_PREFIX` (optional)

Default: `COMPANY`

```bash
export TICKET_PREFIX="ABC"
```

Matches:

* `ABC-123`
* `ABC123`

---

## ⌨️ Keymaps

### Start timer (current branch)

* `<M-cg>` — Start using current branch
* `<leader>cg` — Start (Which-Key)

### Stop timer

* `<M-cs>` — Stop
* `<leader>cs` — Stop (Which-Key)

---

## 🧪 Commands

Start:

```
:ClockworkStart
```

Start with explicit issue key:

```
:ClockworkStart ABC-123
```

Stop:

```
:ClockworkStop
```

Stop with explicit issue key:

```
:ClockworkStop ABC-123
```

---

## 🔍 Branch Parsing

Works on branches like:

* `COMPANY-1234/feature`
* `COMPANY1234-auth`
* `ABC-9999`
* `ABC9999`

Pattern is generated from `$TICKET_PREFIX` dynamically.

---

## 🚦 Error Handling

* **Token missing** – plugin shows an error on load
* **422 response** – “invalid key” warning
* **No match in branch** – usage hint
* **Git command fails** – warning, no crash

---

## 🛠 Troubleshooting

### Plugin loads but no keymaps appear

Ensure Which-Key is loaded **before** Clockwork.

### Timer not starting / issue key empty

Check your branch name and `TICKET_PREFIX`:

```bash
echo $TICKET_PREFIX
git branch --show-current
```

### Plugin not loading

Verify:

```bash
echo $CLOCKWORK_TOKEN
```

### curl errors

Ensure `plenary.nvim` is installed.

---

## 📚 Example Branch Names

| Branch Name       | Extracted Key |
| ----------------- | ------------- |
| `COMPANY-1234/auth` | COMPANY-1234    |
| `COMPANY1234-auth`  | COMPANY1234     |
| `ABC-99/new-ui`   | ABC-99        |
| `ABC99/card-fix`  | ABC99         |

---

