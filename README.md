# Spam

A modern flat auto-spam and auto-reply addon for World of Warcraft (Wrath of the Lich King 3.3.5a / Conquest of Azeroth).

Send messages to **multiple chat channels simultaneously**, on a configurable timer, with random message rotation and auto-reply to whispers.

**Version:** 1.5
**Author:** ayro
**Interface:** 30300

---

## Features

- **Multi-channel spam** — enable one or more channels at the same time (Say, Yell, Party, Raid, Guild, Instance, and custom Channels 1–10). Each enabled channel receives every spam message.
- **Auto-spam timer** — toggle Auto-spam once and the addon will keep sending messages at the interval you set, in seconds.
- **Random message order** — cycle randomly through your message pool instead of always sending the first one.
- **5 message slots** — store up to 5 different messages.
- **Auto-reply to whispers** — automatically reply to incoming whispers with a custom message, throttled to once per sender per hour.
- **Dynamic channel tooltips** — hover any channel checkbox to see its real in-game name (e.g. "Trade - City", "LookingForGroup") resolved via `GetChannelName()`. Built-in channels show a short description instead.
- **Message tooltips** — hover any message box, the delay field, or the auto-reply box to see its full text in a tooltip (useful when the text is truncated by the box width).
- **Select All / Clear All** buttons for quick bulk toggling of channels.
- **Minimap button** — click to toggle the main window, drag to reposition around the minimap. Position is saved across sessions.
- **Slash commands** — `/spam` and `/sp` to toggle the window.
- **Saved variables** — all settings persist across sessions and characters.
- **Modern flat dark UI** — clean dark theme with blue accents.

---

## Installation

1. Download the latest release `.zip` from the [Releases](../../releases) page.
2. Extract the archive. You should end up with a single folder named `Spam` containing:
   - `Spam.toc`
   - `Spam.lua`
   - `icon.tga`
3. Move the `Spam` folder into your WoW `Interface/AddOns/` directory. The final path should look like:
   ```
   WoW/Interface/AddOns/Spam/Spam.toc
   WoW/Interface/AddOns/Spam/Spam.lua
   WoW/Interface/AddOns/Spam/icon.tga
   ```
4. **Clear the addon cache** before launching the game (especially after upgrading from an older version). Delete the contents of:
   ```
   WoW/Cache/WDB/
   ```
5. Launch WoW, log in, and make sure the addon is enabled in the character selection screen (AddOns button, bottom-left).
6. In-game, type `/spam` or `/sp` to open the main window, or click the minimap button.

---

## Usage

### Messages
- Fill the 5 message boxes with the text you want to spam.
- Each box supports up to 255 characters.
- Hover a box to see the full text in a tooltip.

### Spam Settings
- **Random message order** — when enabled, each send picks a random non-empty message from your 5 slots. When disabled, only **Message 1** is sent.
- **Delay** — seconds between each auto-spam tick. Minimum recommended: 5 (WoW throttles chat messages server-side, very low values may get you disconnected or silenced).

### Channels
- Tick one or more checkboxes to choose where messages are sent. All ticked channels receive the message simultaneously.
- Hover a checkbox to see the real in-game channel name (for Channels 1–10) or a short description (for built-in channels like Say, Yell, Party, etc.).
- Use **SELECT ALL** / **CLEAR ALL** to quickly toggle every channel.
- Custom channels (Channel 1–10) must be joined in-game before they can be used. If you tick a channel you haven't joined, the send will silently fail for that channel.

### Auto-Reply
- Tick "Enable auto-reply to whispers" to automatically reply to incoming whispers.
- Set the reply message in the text box below.
- The reply is sent **at most once per hour per sender** to avoid spamming people who whisper you multiple times.

### Bottom Bar
- **Auto-spam** checkbox — starts/stops the auto-spam timer.
- **SEND NOW** button — immediately sends one message to all enabled channels without affecting the timer.

### Minimap Button
- **Click** — toggle the main window.
- **Drag** — reposition the button around the minimap. The position is saved.

---

## Slash Commands

| Command | Action |
|---------|--------|
| `/spam`  | Toggle the main window |
| `/sp`   | Toggle the main window (shortcut) |

---

## Supported Channels

| Value           | Label      | Type     | Notes |
|-----------------|------------|----------|-------|
| `SAY`           | Say        | Built-in | Visible to nearby players |
| `YELL`          | Yell       | Built-in | Visible to far players |
| `PARTY`         | Party      | Built-in | Party members only |
| `RAID`          | Raid       | Built-in | Raid members only |
| `GUILD`         | Guild      | Built-in | Guild members only |
| `INSTANCE_CHAT` | Instance   | Built-in | Battleground / instance group |
| `CHANNEL1`–`CHANNEL10` | Channel 1–10 | User | Must be joined in-game first |

---

## Changelog

### v1.5
- Updated README documentation.

### v1.4
- Wider and shorter main window (620×760).
- Channel grid changed from 2 columns × 8 rows to **4 columns × 4 rows**.
- Dynamic tooltips on channel checkboxes showing the real in-game channel name (via `GetChannelName()`).
- Wider message and auto-reply text boxes.

### v1.3
- Added tooltips on message boxes, delay field, and auto-reply box showing full text on hover.
- Taller main window with more spacing.
- Removed commas from comments.
- SEND NOW button enlarged.

### v1.2
- Fixed `attempt to index field 'channels' (a nil value)` crash when upgrading from v1.0 SavedVariables.
- Recursive default merge so old SavedVariables gain new fields automatically.
- Triple fallback defense for `SpamDB.channels` (nil-safe in every code path).
- `channelCheckboxes` declared `local` to avoid globals pollution.

### v1.1
- **Breaking change:** replaced single-channel dropdown with **multi-channel** checkbox grid.
- New `SendToAllChannels()` function sends to all enabled channels simultaneously.
- Added **SELECT ALL** / **CLEAR ALL** buttons.
- Backward-compatible migration of the old `SpamDB.channel` field.

### v1.0
- Initial release: single-channel auto-spam, auto-reply, minimap button, slash commands.

---

## Known Limitations

- WoW throttles chat messages server-side. Setting a very low delay (under ~5 seconds) may cause the server to silently drop messages, disconnect you, or trigger anti-spam silence mechanics. Use responsibly.
- Custom channels (Channel 1–10) must be joined in-game before they can be used as spam targets. The addon does not auto-join channels.
- The auto-reply throttle (1 hour per sender) is per-session and is not persisted across relogs.

---

## Disclaimer

Use this addon responsibly and in accordance with the rules of the server you play on. Automated spamming may violate the terms of service of some servers and can result in account suspension. The author is not responsible for any consequences arising from the use of this addon.

---

## License

All Rights Reserved.
