-- Tvoje osobné nastavenia Cloveru. Odkomentuj, čo chceš zmeniť.
-- Zmena sa prejaví po reštarte WezTermu.
local wezterm = require 'wezterm'

return {
  -- priečinok, v ktorom sa panely otvoria (Claude vidí len jeho obsah, na ostatné sa pýta)
  workdir = wezterm.home_dir .. '/AI',

  -- počet panelov pri štarte: 1, 2 alebo 4
  -- panes = 4,

  -- parametre pre claude, napr. '--continue' = pokračuj v poslednej konverzácii
  -- claude_args = '',

  -- font_size = 14,
  -- color_scheme = 'Tokyo Night',
}
