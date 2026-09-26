-- Clover — konfig terminálu (Mac + Windows), postavené na WezTerm (MIT)
-- Po spustení: 1 okno, 4 panely v mriežke 2×2, v každom rovno beží Claude.
-- Keď Claude ukončíš (/exit), panel ostane otvorený ako obyčajný terminál.
--
-- Osobné nastavenia (priečinok, farby…) daj do ~/.clover.lua,
-- tento súbor sa pri aktualizácii prepíše. Príklad:
--   return { workdir = wezterm.home_dir .. '/AI', font_size = 13, restore = false }

local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil
local home = wezterm.home_dir
local sep = is_windows and '\\' or '/'

-- Lokálne nastavenia
local user = {}
local ok, loaded = pcall(dofile, home .. sep .. '.clover.lua')
if not ok then ok, loaded = pcall(dofile, home .. sep .. '.claude-terminal.lua') end
if ok and type(loaded) == 'table' then user = loaded end

local WORKDIR = user.workdir or home
local PANES = user.panes or 4 -- 1, 2 alebo 4
local CLAUDE = 'claude' .. (user.claude_args and (' ' .. user.claude_args) or '')

local RESTORE = user.restore ~= false -- obnoviť sessions z minulého spustenia
-- Úplne prvý štart: jeden panel s uvítaním (vitaj.sh), aby sa prihlásenie do Clauda
-- neotvorilo štyrikrát naraz. Súbor welcomed vytvorí vitaj.sh / vitaj.ps1.
local function exists(p) local fh = io.open(p, 'r'); if fh then fh:close() return true end return false end
local FIRST_RUN = not exists(table.concat({ home, '.config', 'clover', 'state', 'welcomed' }, sep))
if FIRST_RUN then PANES = 1 end

-- Príkaz pre panel s Claudom a pre obyčajný terminál.
-- slot 1–4 = panely z mriežky. Hook remember.sh si pre každý slot pamätá
-- aktuálnu session; pri ďalšom štarte ju panel obnoví. Po /exit sa slot vymaže
-- (panel začne nabudúce načisto); pri zavretí okna ostane → obnoví sa.
local shell_cmd
local function claude_cmd(slot)
  local args = user.claude_args and (' ' .. user.claude_args) or ''
  local s = slot and tostring(slot) or "''"
  if is_windows then
    local script = table.concat({ home, '.config', 'clover', 'start.ps1' }, sep)
    local pre = RESTORE and '' or "$env:CLOVER_RESTORE='0'; "
    -- ExecutionPolicy Bypass len pre tento proces: predvolené Restricted by start.ps1 zablokovalo
    return { 'powershell.exe', '-NoLogo', '-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', pre .. "& '" .. script:gsub("'", "''") .. "' " .. s .. args }
  end
  local sh = os.getenv('SHELL') or '/bin/zsh'
  -- unset: ak WezTerm spustil iný Claude, zdedí CLAUDE_CODE_CHILD_SESSION a pod.
  -- → Claude sa berie ako child session a neukladá transcript
  local clean = 'unset CLAUDECODE CLAUDE_CODE_CHILD_SESSION CLAUDE_CODE_SESSION_ID CLAUDE_PID '
    .. 'CLAUDE_CODE_MESSAGING_SOCKET CLAUDE_CODE_MESSAGING_TOKEN CLAUDE_CODE_ENTRYPOINT '
    .. 'CLAUDE_CODE_SESSION_ATTENDED CLAUDE_CODE_EXECPATH CLAUDE_EFFORT; '
  local pre = RESTORE and '' or 'CLOVER_RESTORE=0 '
  -- login shell, aby sedel PATH; po /exit ostane shell
  return { sh, '-lc', clean .. pre .. 'bash "$HOME/.config/clover/start.sh" ' .. s .. args .. '; exec ' .. sh .. ' -l' }
end
if is_windows then
  shell_cmd = { 'powershell.exe', '-NoLogo' }
else
  shell_cmd = { os.getenv('SHELL') or '/bin/zsh', '-l' }
end

-- Každý nový panel/tab rovno s Claudom
config.default_prog = claude_cmd()
config.default_cwd = WORKDIR

-- Štart: 4 panely 2×2, každý so svojím slotom
local function pane_opts(slot, extra)
  local o = { cwd = WORKDIR, args = claude_cmd(slot), set_environment_variables = { CLOVER_SLOT = tostring(slot) } }
  for k, v in pairs(extra or {}) do o[k] = v end
  return o
end
wezterm.on('gui-startup', function(cmd)
  if cmd and cmd.args then
    local _, _, window = mux.spawn_window { cwd = WORKDIR, args = cmd.args }
    window:gui_window():maximize()
    return
  end
  local _, p1, window = mux.spawn_window(pane_opts(1))
  window:gui_window():maximize()
  -- deliť až po maximalizácii, inak panely nevyjdú rovnako veľké
  wezterm.time.call_after(0.4, function()
    if PANES >= 2 then
      local p2 = p1:split(pane_opts(2, { direction = 'Right', size = 0.5 }))
      if PANES >= 4 then
        p1:split(pane_opts(3, { direction = 'Bottom', size = 0.5 }))
        p2:split(pane_opts(4, { direction = 'Bottom', size = 0.5 }))
      end
    end
    p1:activate()
  end)
end)

-- Vzhľad
wezterm.on('format-window-title', function() return 'Clover' end)
config.color_scheme = user.color_scheme or 'Tokyo Night'
config.font = wezterm.font_with_fallback { 'JetBrains Mono' } -- je súčasťou WezTermu
config.font_size = user.font_size or (is_windows and 10 or 12) -- Cmd/Ctrl + plus/mínus mení naživo
-- Mac: písmo podľa obrazovky, aby sa do panelov zmestilo rovnako textu všade.
-- Základ = 12 na FullHD (1920 bodov na šírku); Retina MacBook (~1500 bodov) tak dostane ~9,5.
-- Kto si nastaví font_size v ~/.clover.lua, tomu do toho nezasahujeme.
if not user.font_size and not is_windows then
  wezterm.on('window-config-reloaded', function(window)
    local ok, s = pcall(function() return wezterm.gui.screens().active end)
    if not ok or not s or not s.width then return end
    local points = s.width * 72 / (s.effective_dpi or 72)
    local size = math.floor(12 * points / 1920 * 2 + 0.5) / 2
    size = math.max(9, math.min(14, size))
    local o = window:get_config_overrides() or {}
    if o.font_size ~= size then o.font_size = size; window:set_config_overrides(o) end
  end)
end
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 8, right = 8, top = 8, bottom = 4 }
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 } -- aktívny panel svieti
config.scrollback_lines = 20000
config.audible_bell = 'Disabled'
config.adjust_window_size_when_changing_font_size = false

-- Ťahák: súbor skratky.txt vedľa konfigu, zavrie sa ľubovoľnou klávesou
local cheat = table.concat({ home, '.config', 'clover', 'skratky.txt' }, sep)
local cheat_cmd = is_windows
  and { 'powershell.exe', '-NoLogo', '-Command', "Get-Content -Encoding UTF8 '" .. cheat:gsub("'", "''") .. "'; [void][Console]::ReadKey($true)" }
  or { '/bin/bash', '-c', "cat '" .. cheat .. "'; read -rsn1" }

-- Skratky (Mac: Cmd, Windows: Ctrl+Shift)
local mod = is_windows and 'CTRL|SHIFT' or 'SUPER'
config.keys = {
  -- Shift+Enter = nový riadok v Claudovi
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
  -- nový panel s Claudom: vpravo / dole
  { key = 'd', mods = mod, action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = mod, action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- panel s obyčajným terminálom (bez Clauda)
  { key = 'n', mods = mod .. (is_windows and '' or '|SHIFT'), action = act.SplitHorizontal { args = shell_cmd } },
  -- zväčšiť/vrátiť aktuálny panel
  { key = 'Enter', mods = mod, action = act.TogglePaneZoomState },
  -- zavrieť panel
  { key = 'w', mods = mod, action = act.CloseCurrentPane { confirm = true } },
  -- prepínanie panelov šípkami
  { key = 'LeftArrow', mods = mod .. '|ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = mod .. '|ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = mod .. '|ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = mod .. '|ALT', action = act.ActivatePaneDirection 'Down' },
  -- ťahák skratiek (Mac: Cmd+/, Windows: Ctrl+Shift+/)
  { key = '/', mods = mod, action = act.SpawnCommandInNewTab { args = cheat_cmd } },
}

-- Písanie ako v bežnej appke (overené na Claude Code vstupe)
local function send(k, m, str) table.insert(config.keys, { key = k, mods = m, action = act.SendString(str) }) end
if is_windows then
  send('LeftArrow', 'CTRL', '\x1bb')   -- o slovo doľava
  send('RightArrow', 'CTRL', '\x1bf')  -- o slovo doprava
  send('Backspace', 'CTRL', '\x17')    -- zmazať slovo
  send('Home', 'NONE', '\x01')         -- začiatok riadku
  send('End', 'NONE', '\x05')          -- koniec riadku
  -- Ctrl+C: ak je niečo označené, skopíruj; inak klasicky preruš
  table.insert(config.keys, { key = 'c', mods = 'CTRL', action = wezterm.action_callback(function(win, pane)
    local sel = win:get_selection_text_for_pane(pane)
    if sel and sel ~= '' then
      win:perform_action(act.CopyTo 'Clipboard', pane)
      win:perform_action(act.ClearSelection, pane)
    else
      win:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
    end
  end) })
  table.insert(config.keys, { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' })
else
  send('LeftArrow', 'OPT', '\x1bb')    -- Option+← o slovo doľava
  send('RightArrow', 'OPT', '\x1bf')   -- Option+→ o slovo doprava
  send('LeftArrow', 'CMD', '\x01')     -- Cmd+← začiatok riadku
  send('RightArrow', 'CMD', '\x05')    -- Cmd+→ koniec riadku
  send('Backspace', 'OPT', '\x17')     -- Option+⌫ zmazať slovo
  send('Backspace', 'CMD', '\x15')     -- Cmd+⌫ zmazať po začiatok riadku
end

-- Odkazy na klik otvárame len webové a mailové. Iné schémy (file://, ssh://, vlastné URL appiek)
-- by jedným klikom mohli spustiť niečo nečakané, napr. z výpisu cudzej webstránky.
wezterm.on('open-uri', function(_, _, uri)
  if not (uri:match('^https?://') or uri:match('^mailto:')) then return false end
end)
-- Myš: označenie = hneď skopírované, pravé tlačidlo = vložiť
config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE',
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection' },
  { event = { Up = { streak = 2, button = 'Left' } }, mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
  { event = { Up = { streak = 3, button = 'Left' } }, mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE',
    action = act.PasteFrom 'Clipboard' },
}

return config
