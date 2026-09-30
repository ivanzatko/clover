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
-- nastavený priečinok neexistuje (zmazaný, premenovaný) → radšej domov než pád panelov
if WORKDIR ~= home and not pcall(wezterm.read_dir, WORKDIR) then WORKDIR = home end
local PANES = user.panes or 4 -- 1, 2 alebo 4
local CLAUDE = 'claude' .. (user.claude_args and (' ' .. user.claude_args) or '')

local RESTORE = user.restore ~= false -- obnoviť sessions z minulého spustenia
-- Úplne prvý štart: uvítanie (vitaj.sh) v paneli 1. Kto ešte nie je prihlásený do Clauda,
-- dostane len jeden panel, aby sa prihlásenie neotvorilo štyrikrát naraz.
-- Súbor welcomed vytvorí vitaj.sh / vitaj.ps1.
local function exists(p) local fh = io.open(p, 'r'); if fh then fh:close() return true end return false end
local FIRST_RUN = not exists(table.concat({ home, '.config', 'clover', 'state', 'welcomed' }, sep))
local function logged_in()                  -- Claude už prihlásený? (~/.claude.json má oauthAccount)
  local fh = io.open(home .. sep .. '.claude.json', 'r'); if not fh then return false end
  local s = fh:read('*a') or ''; fh:close()
  return s:find('"oauthAccount"', 1, true) ~= nil
end
if FIRST_RUN and not logged_in() then PANES = 1 end   -- 4 prihlásenia naraz nikto nechce

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
  local okd, old = pcall(wezterm.read_dir, table.concat({ home, '.config', 'clover', 'state', 'wait' }, sep))
  if okd then for _, f in ipairs(old) do os.remove(f) end end
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

-- ── Káva ☕: prvých 48 h po inštalácii ────────────────────────────────────────
-- Inštalácia je zadarmo. Prvých 48 h po nej ukazuje lišta hore odkaz na kávu (20 €)
-- a raz za spustenie príde notifikácia (klik = platba). Po zaplatení alebo po 48 h
-- to navždy zmizne. installed_at, email a paid zapisuje inštalátor do ~/.config/clover.
local CFG = table.concat({ home, '.config', 'clover' }, sep)
local API = 'https://www.ivanzatko.com/api/clover'
local PAY_CHECK = table.concat({ CFG, 'state', 'paid-check' }, sep)
local function cfg_read(name)
  local fh = io.open(CFG .. sep .. name, 'r'); if not fh then return nil end
  local v = fh:read('*l'); fh:close(); return v
end
local function urlenc(s) return (s:gsub('[^%w%.%-_~@]', function(c) return string.format('%%%02X', c:byte()) end)) end
local function coffee_url()
  local email = cfg_read('email') or ''
  return API .. '/pay' .. (email ~= '' and ('?email=' .. urlenc(email)) or '')
end
local function coffee_active()                       -- true = ešte ukazovať kávu
  if cfg_read('paid') then return false end
  local t = tonumber(cfg_read('installed_at') or '')
  return t ~= nil and os.time() - t < 48 * 3600
end
local function coffee_check()                        -- na pozadí overí platbu, výsledok v PAY_CHECK
  local email = cfg_read('email'); if not email or email == '' then return end
  pcall(wezterm.background_child_process, { is_windows and 'curl.exe' or '/usr/bin/curl',
    '-fsS', '--max-time', '8', '-o', PAY_CHECK, API .. '/install?email=' .. urlenc(email) })
end
local function coffee_paid_result()                  -- prečíta výsledok kontroly; true = zaplatené
  local fh = io.open(PAY_CHECK, 'r'); if not fh then return false end
  local r = fh:read('*a') or ''; fh:close(); os.remove(PAY_CHECK)
  if not r:find('"paid":true', 1, true) then return false end
  local w = io.open(CFG .. sep .. 'paid', 'w'); if w then w:write(os.date('!%Y-%m-%dT%H:%M:%SZ') .. '\n'); w:close() end
  return true
end

-- ── Aktualizácie ────────────────────────────────────────────────────────────
-- Raz za 6 h (prvýkrát 30 s po štarte) si Clover na pozadí stiahne súbor VERSION z kitu:
-- 1. riadok = verzia, ďalšie = čo je nové. Keď je novší než ~/.config/clover/version,
-- príde notifikácia a lišta hore. Nič sa neinštaluje samo: aktualizáciu spustí až človek
-- cez Cmd+Shift+U (Windows Ctrl+Shift+U) a v novom tabe vidí, čo sa deje.
local KIT = user.kit_url or 'https://raw.githubusercontent.com/ivanzatko/clover/main'
local LATEST = table.concat({ CFG, 'state', 'latest' }, sep)
local function ver_newer(a, b)                       -- a > b? verzie typu 2026.09.28.2
  local x, y = {}, {}
  for n in a:gmatch('%d+') do x[#x + 1] = tonumber(n) end
  for n in b:gmatch('%d+') do y[#y + 1] = tonumber(n) end
  for i = 1, math.max(#x, #y) do
    if (x[i] or 0) ~= (y[i] or 0) then return (x[i] or 0) > (y[i] or 0) end
  end
  return false
end
local function update_check()
  pcall(wezterm.background_child_process, { is_windows and 'curl.exe' or '/usr/bin/curl',
    '-fsS', '--max-time', '8', '--create-dirs', '-o', LATEST, KIT .. '/VERSION' })
end
local function update_available()                    -- nová verzia a novinky, inak nil
  local fh = io.open(LATEST, 'r'); if not fh then return nil end
  local s = fh:read('*a') or ''; fh:close()
  local v, notes = s:match('^(%d[%d%.]*)\r?\n(.*)$') -- bez konca riadku = ešte sa sťahuje
  if not v or not ver_newer(v, cfg_read('version') or '0') then return nil end
  notes = notes:gsub('%s+$', ''):gsub('%s*\r?\n%s*', ' · ')
  return v, notes
end
local update_cmd = is_windows
  and { 'powershell.exe', '-NoLogo', '-ExecutionPolicy', 'Bypass', '-Command',
    "$env:CLOVER_UPDATE='1'; irm '" .. KIT .. "/install-win.ps1' | iex; [void][Console]::ReadKey($true)" }
  or { '/bin/bash', '-c', "curl -fsSL '" .. KIT .. "/install-mac.sh' | CLOVER_UPDATE=1 /bin/bash; read -rsn1" }

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
  -- káva ☕ (platba 20 €, odkaz ukazujeme len prvých 48 h po inštalácii)
  { key = 'k', mods = mod .. (is_windows and '' or '|SHIFT'), action = wezterm.action_callback(function()
    wezterm.open_with(coffee_url())
  end) },
  -- aktualizácia Cloveru v novom tabe (Mac: Cmd+Shift+U, Windows: Ctrl+Shift+U)
  { key = 'u', mods = mod .. (is_windows and '' or '|SHIFT'), action = act.SpawnCommandInNewTab { args = update_cmd, cwd = home } },
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
-- Claude v režime fullscreen (/tui) si myš berie sám, obyčajný klik mu padne a odkaz sa neotvorí.
-- Cmd+klik (Windows: Ctrl+klik) otvorí odkaz vždy, aj keď appka myš zachytáva.
local link_mod = is_windows and 'CTRL' or 'SUPER'
for _, rep in ipairs { false, true } do
  table.insert(config.mouse_bindings, { event = { Down = { streak = 1, button = 'Left' } },
    mods = link_mod, mouse_reporting = rep, action = act.Nop })
  table.insert(config.mouse_bindings, { event = { Up = { streak = 1, button = 'Left' } },
    mods = link_mod, mouse_reporting = rep, action = act.OpenLinkAtMouseCursor })
end

-- ── Kto na teba čaká ────────────────────────────────────────────────────────
-- Hook notify.sh zapíše do state/wait/<pane id> „wait <čas>" (Claude čaká na povolenie
-- alebo odpoveď) alebo „done <čas>" (dokončil). Tu to každú sekundu prečítame:
-- ak sa na ten panel práve nepozeráš, príde notifikácia a hore sa ukáže lišta.
-- Keď sa na panel pozrieš (alebo mu odpíšeš), stav zmizne.
local WAIT_DIR = table.concat({ home, '.config', 'clover', 'state', 'wait' }, sep)
config.status_update_interval = 1000
config.use_fancy_tab_bar = false

local function read_state(path)
  local fh = io.open(path, 'r'); if not fh then return nil end
  local line = fh:read('*l') or ''; fh:close()
  return line:match('^(%a+) (%d+)')
end

local function where(info, tab)
  local size, parts = tab:get_size(), {}
  if info.width < size.cols - 2 then
    table.insert(parts, info.left + info.width / 2 < size.cols / 2 and 'vľavo' or 'vpravo')
  end
  if info.height < size.rows - 2 then
    table.insert(parts, info.top + info.height / 2 < size.rows / 2 and 'hore' or 'dole')
  end
  return table.concat(parts, ' ')             -- '' = jediný panel v okne
end

wezterm.on('update-status', function(window, pane)
  local ok, files = pcall(wezterm.read_dir, WAIT_DIR)
  if not ok then files = {} end
  local tab = window:active_tab()
  local infos = {}
  for _, i in ipairs(tab:panes_with_info()) do infos[tostring(i.pane:pane_id())] = i end
  local looking = window:is_focused() and tostring(pane:pane_id()) or nil
  local items = {}
  for _, f in ipairs(files) do
    local id = f:match('([^/\\]+)$')
    local state, stamp = read_state(f)
    local alive = pcall(function() return mux.get_pane(tonumber(id)):pane_id() end)
    if not state or not alive or id == looking then
      os.remove(f)                                  -- panel neexistuje alebo sa naň pozeráš
    elseif infos[id] then
      local label = where(infos[id], tab)
      local who = label == '' and 'Claude' or 'Claude ' .. label
      local key = 'clover_seen_' .. id
      if wezterm.GLOBAL[key] ~= stamp then
        wezterm.GLOBAL[key] = stamp
        window:toast_notification('Clover 🍀',
          who .. (state == 'wait' and ' čaká na teba' or ' je hotový'),
          nil, 6000)
      end
      local l = label == '' and 'Claude' or label
      table.insert(items, (state == 'wait' and '⏳ ' .. l .. ' čaká' or '✓ ' .. l .. ' hotovo'))
    end
  end
  local now = os.time()
  wezterm.GLOBAL.clover_started = wezterm.GLOBAL.clover_started or now
  -- nová verzia: kontrola každých 6 h, notifikácia raz za verziu a spustenie
  if now >= (wezterm.GLOBAL.clover_vercheck or wezterm.GLOBAL.clover_started + 30) then
    wezterm.GLOBAL.clover_vercheck = now + 6 * 3600
    update_check()
  end
  local upd_v, upd_notes = update_available()
  local upd_key = is_windows and 'Ctrl+Shift+U' or 'Cmd+Shift+U'
  if upd_v and wezterm.GLOBAL.clover_upd_toast ~= upd_v then
    wezterm.GLOBAL.clover_upd_toast = upd_v
    window:toast_notification('Clover 🍀', 'Nová verzia Cloveru' .. (upd_notes ~= '' and (': ' .. upd_notes) or '')
      .. '. Aktualizuješ cez ' .. upd_key .. '.', nil, 15000)
  end
  -- káva: kontrola platby každých 10 min, notifikácia raz za spustenie (minútu po štarte)
  local coffee = coffee_active()
  if coffee then
    if coffee_paid_result() then
      coffee = false
    elseif (wezterm.GLOBAL.clover_paycheck or 0) + 600 < now then
      wezterm.GLOBAL.clover_paycheck = now
      coffee_check()
    end
    if coffee and not wezterm.GLOBAL.clover_coffee_toast and wezterm.GLOBAL.clover_started + 60 < now then
      wezterm.GLOBAL.clover_coffee_toast = true
      window:toast_notification('Clover 🍀', 'Sadol ti Clover? Kúp mi kávu za 20 €. Klikni sem.', coffee_url(), 15000)
    end
  end

  local o = window:get_config_overrides() or {}
  local show = #items > 0 or coffee or upd_v ~= nil
  if (o.hide_tab_bar_if_only_one_tab == false) ~= show then
    o.hide_tab_bar_if_only_one_tab = not show
    window:set_config_overrides(o)
  end
  local status = {}
  if #items > 0 then
    table.insert(status, { Foreground = { Color = '#e0af68' } })
    table.insert(status, { Text = table.concat(items, '   ·   ') .. '   ' })
  end
  if coffee then
    table.insert(status, { Foreground = { Color = '#9aa5ce' } })
    table.insert(status, { Text = (#items > 0 and '·   ' or '') .. '☕ Sadol ti Clover? Kávu kúpiš cez '
      .. (is_windows and 'Ctrl+Shift+K' or 'Cmd+Shift+K') .. '   ' })
  end
  if upd_v then
    table.insert(status, { Foreground = { Color = '#9ece6a' } })
    table.insert(status, { Text = ((#items > 0 or coffee) and '·   ' or '') .. '🆕 Nová verzia Cloveru, aktualizuješ cez ' .. upd_key .. '   ' })
  end
  window:set_right_status(show and wezterm.format(status) or '')
end)

return config
