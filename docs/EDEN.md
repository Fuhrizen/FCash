# 3DEN authoring

Fuhrizen's Cash uses normal **Edit Attributes** categories for unit/object setup instead of a catch-all setup module.

## Unit attributes

Select a unit in 3DEN and open **Attributes > Fuhrizen's Cash**.

Available unit fields:

- **Starting wallet / code** - leave blank to use the mission default, enter a number, or enter `{}` SQF that returns a number.
- **Starting bank / code** - same behavior for the personal-bank balance.

A value script receives the entity in `_this`:

```sqf
{ params ["_entity"]; 500 + floor random 250 }
```

Playable player slots keep these authored values until their Steam UID is resolved. AI/NPC units use the transient server entity ledger.

## Object attributes

Select a non-man object and open **Attributes > Fuhrizen's Cash**.

Available object fields:

- **Cash stash** - registers the object as an FCash stash.
- **Stash starting cash / code** - number or `{}` value script used when the stash is registered.
- **Bank terminal** - enables banking access from the object.

This is intended for editor-placed desks, containers, safes, props and similar objects without requiring synchronization to a generic setup module.

## Shared Bank module

**Systems > Modules > Fuhrizen's Cash > Shared Bank** remains a dedicated 3DEN module because a shared bank is not an object property.

Attributes:

- **Bank name**
- **Starting value / code**
- **Public recipient search**

Synchronize player/playable units to grant membership. The first synchronized player slot becomes owner when that slot resolves; the remaining synchronized units become members.

Private shared banks do not appear in recipient browsing, but their seven-digit account number always remains a valid transfer destination.

## Native ATMs

The following classes are always bank terminals and require no 3DEN attribute:

```text
Land_Atm_01_F
Land_Atm_02_F
Land_ATM_01_malden_F
Land_ATM_02_malden_F
```

FCash installs the ACE **Open banking** interaction at the ATM class level for normal/editor/spawned ATM entities. Map-baked terrain-library ATMs are a separate Arma object type and may not expose a usable CfgVehicles interaction target. FCash therefore scans only a small radius around each player for the four supported ATM models; when one is encountered the server hides the terrain instance and recreates the same ATM class at the same transform. The recreated ATM is networked and receives the normal ACE action.
