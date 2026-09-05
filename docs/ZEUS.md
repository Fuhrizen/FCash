# Zeus modules

The Zeus category is **Fuhrizen's Cash**. The public module surface is deliberately compact. Assigned curators use a server administrative endpoint that skips normal player proximity/terminal/rate-limit requirements while normal player transactions continue through the gameplay request path.

ZEN is optional. When present, FCash uses `zen_dialog_fnc_create`; otherwise the addon uses its compact vanilla-style fallback UI.

## Modules

| Module | Use |
|---|---|
| **Manage Funds** | Attach to a player/AI/corpse or registered stash. For units select Wallet or Bank, then Set / + / -. On a stash the module edits stash funds. |
| **Manage Shared Banks** | Create shows only name/starting balance, Change Balance shows only account plus a signed +/- change, and Remove shows only the account selector. |
| **Manage Stash** | Attach to an object. Create/Reset shows starting balance, Change Balance accepts a signed +/- change, and Remove hides all balance fields. |
| **Set Bank Terminal** | Attach to an object to enable bank access. |
| **Remove Bank Terminal** | Attach to an object to remove custom bank-terminal behavior. Native ATM classes remain terminals by class. |

## Administrative behavior

Zeus requests still execute on the server and require the caller to own an assigned curator logic. They intentionally bypass normal gameplay distance, terminal and request-rate checks so live administration is low-friction.

Player-facing notifications use the FCash HUD card. While the curator display is open, administrative feedback is routed through ZEN/vanilla Curator feedback instead.

The editor adapts its visible fields immediately when the operation mode changes, rather than leaving unrelated inputs on screen.
