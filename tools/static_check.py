#!/usr/bin/env python3
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'addons' / 'main'
CONFIG = ADDON / 'config.cpp'
errors=[]; warnings=[]; notes=[]

# Strip comments and quoted strings while preserving newlines and delimiters outside them.
def strip_noncode(text: str) -> str:
    out=[]; i=0; n=len(text); state='code'; quote=None
    while i<n:
        c=text[i]; d=text[i+1] if i+1<n else ''
        if state=='code':
            if c=='/' and d=='/': state='line'; out.extend('  '); i+=2; continue
            if c=='/' and d=='*': state='block'; out.extend('  '); i+=2; continue
            if c in ('"', "'"):
                state='string'; quote=c; out.append(' '); i+=1; continue
            out.append(c); i+=1; continue
        if state=='line':
            if c=='\n': state='code'; out.append('\n')
            else: out.append(' ')
            i+=1; continue
        if state=='block':
            if c=='*' and d=='/': state='code'; out.extend('  '); i+=2
            else:
                out.append('\n' if c=='\n' else ' '); i+=1
            continue
        if state=='string':
            if c==quote:
                # SQF/config quote escaping by doubling the quote.
                if d==quote:
                    out.extend('  '); i+=2; continue
                state='code'; quote=None; out.append(' '); i+=1; continue
            if c=='\\' and d: out.extend('  '); i+=2; continue
            out.append('\n' if c=='\n' else ' '); i+=1
    if state=='block': errors.append('Unterminated block comment')
    if state=='string': errors.append('Unterminated quoted string')
    return ''.join(out)

# 1. Delimiter balance for source/config files.
for p in sorted(ADDON.rglob('*')):
    if p.suffix.lower() not in {'.sqf','.hpp','.cpp'}: continue
    raw=p.read_text(encoding='utf-8')
    code=strip_noncode(raw)
    pairs={')':'(',']':'[','}':'{'}; opens=set(pairs.values()); stack=[]
    line=1
    positions=[]
    for idx,c in enumerate(code):
        if c=='\n': line+=1
        if c in opens: stack.append((c,line))
        elif c in pairs:
            if not stack or stack[-1][0]!=pairs[c]:
                errors.append(f'{p.relative_to(ROOT)}:{line}: unmatched {c}')
                break
            stack.pop()
    if stack:
        errors.append(f'{p.relative_to(ROOT)}:{stack[-1][1]}: unclosed {stack[-1][0]}')

# 2. CfgFunctions declarations <-> files.
cfg=CONFIG.read_text(encoding='utf-8')
func_block=cfg.split('class CfgFunctions',1)[1].split('class CfgRemoteExec',1)[0]
declared=set(re.findall(r'\bclass\s+([A-Za-z]\w*)\s*\{[^{}]*(?:preInit|postInit)?[^{}]*\};', func_block, flags=re.S))
# Filter category/root classes accidentally caught (they have nested braces and normally aren't matched, but be explicit).
declared -= {'FCash','Init','Common','Client','Server'}
files={p.stem[3:] for p in (ADDON/'functions').glob('fn_*.sqf')}
missing_files=sorted(declared-files); undeclared=sorted(files-declared)
if missing_files: errors.append('CfgFunctions missing files: '+', '.join(missing_files))
if undeclared: errors.append('Function files not declared in CfgFunctions: '+', '.join(undeclared))

# 3. Every FCash function reference resolves to a declared function.
refs=set()
for p in ADDON.rglob('*'):
    if p.is_file() and p.suffix.lower() in {'.sqf','.hpp','.cpp','.md'}:
        txt=p.read_text(encoding='utf-8')
        refs |= set(re.findall(r'FCash_fnc_([A-Za-z]\w*)', txt))
unknown=sorted(refs-declared)
if unknown: errors.append('Unknown FCash function references: '+', '.join(unknown))

# 4. Client-requested operations must exist in the server dispatcher.
client_ops=set()
for p in (ADDON/'functions').glob('fn_*.sqf'):
    if p.name=='fn_serverRequest.sqf': continue
    txt=p.read_text(encoding='utf-8')
    for m in re.finditer(r'\[\s*"([A-Z][A-Z0-9_]+)"\s*,[^\]]*\]\s*remoteExecCall\s*\[\s*"FCash_fnc_serverRequest"', txt, re.S):
        client_ops.add(m.group(1))
# Also request wrapper calls: ["OP", data] call FCash_fnc_serverRequest aren't client patterns, ignore.
server_txt=(ADDON/'functions'/'fn_serverRequest.sqf').read_text(encoding='utf-8')
server_ops=set(re.findall(r'^    case\s+"([A-Z][A-Z0-9_]+)"', server_txt, re.M))
missing_ops=sorted(client_ops-server_ops)
if missing_ops: errors.append('Client operations absent from server dispatcher: '+', '.join(missing_ops))

# 5. UI IDC references are backed by defined controls.
dialog=(ADDON/'ui'/'dialogs.hpp').read_text(encoding='utf-8')
defined_idcs=set(map(int,re.findall(r'\bidc\s*=\s*(\d+)\s*;', dialog)))
referenced_idcs=set()
for p in (ADDON/'functions').glob('fn_*.sqf'):
    txt=p.read_text(encoding='utf-8')
    referenced_idcs |= set(map(int,re.findall(r'displayCtrl\s+(\d+)',txt)))
    referenced_idcs |= set(map(int,re.findall(r'\bctrl\s+(\d+)',txt)))
missing_idcs=sorted(x for x in referenced_idcs if x not in defined_idcs)
if missing_idcs: errors.append('UI references undefined IDCs: '+', '.join(map(str,missing_idcs)))

# 6. UI coordinate expressions containing safeZone must be quoted for HEMTT config parsing.
for p in sorted((ADDON / 'ui').rglob('*.hpp')):
    txt = p.read_text(encoding='utf-8')
    for m in re.finditer(r'\b(x|y|w|h)\s*=\s*(safeZone[^;]+);', txt):
        line = txt.count('\n', 0, m.start()) + 1
        errors.append(f'{p.relative_to(ROOT)}:{line}: unquoted UI coordinate expression: {m.group(0)}')

# 7b. Detect duplicate properties within each config class body (top-level only).
def iter_class_blocks(text: str):
    code = strip_noncode(text)
    for m in re.finditer(r'\bclass\s+([A-Za-z_]\w*)[^;{]*\{', code):
        name = m.group(1)
        start = m.end()
        depth = 1
        i = start
        while i < len(code) and depth:
            if code[i] == '{': depth += 1
            elif code[i] == '}': depth -= 1
            i += 1
        if depth == 0:
            yield name, start, i - 1, code[start:i - 1]

for p in sorted((ADDON / 'ui').rglob('*.hpp')):
    raw = p.read_text(encoding='utf-8')
    for class_name, start, end, body in iter_class_blocks(raw):
        depth = 0
        props = {}
        i = 0
        while i < len(body):
            c = body[i]
            if c == '{':
                depth += 1
                i += 1
                continue
            if c == '}':
                depth = max(0, depth - 1)
                i += 1
                continue
            if depth == 0:
                m = re.match(r'\s*([A-Za-z_]\w*(?:\[\])?)\s*=\s*', body[i:])
                if m:
                    prop = m.group(1)
                    absolute = start + i + m.start(1)
                    line = raw.count('\n', 0, absolute) + 1
                    if prop in props:
                        errors.append(f'{p.relative_to(ROOT)}:{line}: duplicate property {prop} in class {class_name} (first defined on line {props[prop]})')
                    else:
                        props[prop] = line
                    semi = body.find(';', i + m.end())
                    i = len(body) if semi < 0 else semi + 1
                    continue
            i += 1

# 7. Remote-exec surface remains minimal.
remote_block=cfg.split('class CfgRemoteExec',1)[1]
remote_funcs=set(re.findall(r'class\s+(FCash_fnc_\w+)\s*\{',remote_block))
expected={'FCash_fnc_serverRequest','FCash_fnc_serverZeusRequest','FCash_fnc_serverPromoteTerrainATM','FCash_fnc_clientSync','FCash_fnc_clientNotify','FCash_fnc_clientEvent','FCash_fnc_clientInstallObjectActions','FCash_fnc_clientZeusContext','FCash_fnc_clientSharedLog'}
if remote_funcs!=expected:
    errors.append(f'Unexpected CfgRemoteExec surface: got {sorted(remote_funcs)}, expected {sorted(expected)}')

# 8. High-risk server functions should reject direct remote execution.
high_risk=['serverInit','serverAdjustWallet','serverAdjustBank','serverAdjustStorage','serverCreateShared','serverAdjustShared','serverRenameShared','serverSetSharedMember','serverDeleteShared','registerStorage','registerTerminal','unregisterStorage','unregisterTerminal','exportState','importState','getAuditLog']
for name in high_risk:
    txt=(ADDON/'functions'/f'fn_{name}.sqf').read_text(encoding='utf-8')
    if 'isRemoteExecuted' not in txt:
        errors.append(f'High-risk server API lacks direct remote-execution rejection: {name}')

# 9. Capability-protected server internals should check token when remote.
protected=['serverEnsureAccount','serverRateLimit','serverSyncPlayer','serverNotify','serverAudit','serverGeneratePin','serverSharedLog','serverResolveStartingValue','serverApply3DENObject']
for name in protected:
    txt=(ADDON/'functions'/f'fn_{name}.sqf').read_text(encoding='utf-8')
    if 'isRemoteExecuted' not in txt or 'FCash_server_internalToken' not in txt:
        errors.append(f'Internal server API lacks remote capability guard: {name}')

# 10. Key expected server operations.
expected_ops={'SYNC','WALLET_GIVE','WALLET_TAKE','STORAGE_DEPOSIT','STORAGE_WITHDRAW','PERSONAL_DEPOSIT','PERSONAL_WITHDRAW','PERSONAL_TRANSFER','DIRECT_SEND','SHARED_CREATE','SHARED_INVITE','SHARED_INVITE_RESPONSE','SHARED_DEPOSIT','SHARED_WITHDRAW','SHARED_TRANSFER','SHARED_TOGGLE_PUBLIC','SHARED_LOG_REQUEST','SHARED_SET_ROLE','SHARED_REMOVE'}
if server_ops != expected_ops:
    errors.append('Server operation set differs from expected: missing='+str(sorted(expected_ops-server_ops))+' extra='+str(sorted(server_ops-expected_ops)))


# 11. Zeus remote dispatcher must verify the caller is an assigned curator.
zeus_txt=(ADDON/'functions'/'fn_serverZeusRequest.sqf').read_text(encoding='utf-8')
if 'remoteExecutedOwner' not in zeus_txt or 'getAssignedCuratorLogic' not in zeus_txt:
    errors.append('Zeus dispatcher lacks caller/curator authorization checks')

# 12. Every public Zeus module must be advertised in CfgPatches and carry a known operation.
zeus_cfg=(ADDON/'zeus.hpp').read_text(encoding='utf-8')
zeus_modules=set(re.findall(r'class\s+(FCash_Module_[A-Za-z0-9_]+)\s*:\s*FCash_ModuleBase', zeus_cfg))
units_match=re.search(r'units\[\]\s*=\s*\{(.*?)\};', cfg, re.S)
patch_units=set(re.findall(r'"(FCash_Module_[A-Za-z0-9_]+)"', units_match.group(1))) if units_match else set()
if not zeus_modules.issubset(patch_units):
    errors.append('CfgPatches is missing Zeus modules: '+str(sorted(zeus_modules-patch_units)))
eden_modules={'FCash_Module_3DENSharedBank'}
if not eden_modules.issubset(patch_units):
    errors.append('CfgPatches is missing 3DEN modules: '+str(sorted(eden_modules-patch_units)))
zeus_ops=set(re.findall(r'FCash_operation\s*=\s*"([A-Z][A-Z0-9_]+)"', zeus_cfg))
server_zeus_ops=set(re.findall(r'"([A-Z][A-Z0-9_]+)"', re.search(r'private _allOps\s*=.*?;\n', zeus_txt, re.S).group(0))) if re.search(r'private _allOps\s*=.*?;\n', zeus_txt, re.S) else set()
# _allOps is composed from arrays, so compare against all operation strings occurring in the dispatcher before its switch.
zeus_dispatch_prefix=zeus_txt.split('switch (_action)',1)[0]
server_zeus_ops=set(re.findall(r'"([A-Z][A-Z0-9_]+)"', zeus_dispatch_prefix))
missing_zeus_ops=sorted(zeus_ops-server_zeus_ops)
if missing_zeus_ops:
    errors.append('Zeus modules reference operations absent from dispatcher declarations: '+', '.join(missing_zeus_ops))


# 13. CBA settings must be registered through XEH preInit so Configure Addons works in 3DEN.
xeh_cfg = cfg
if 'class Extended_PreInit_EventHandlers' not in xeh_cfg or 'XEH_preInit.sqf' not in xeh_cfg:
    errors.append('CBA settings are not wired through Extended_PreInit_EventHandlers for 3DEN')
xeh_file = ADDON / 'XEH_preInit.sqf'
if not xeh_file.exists() or 'fn_registerSettings.sqf' not in xeh_file.read_text(encoding='utf-8'):
    errors.append('XEH_preInit.sqf does not register FCash CBA settings')

# 14. Keep the public Zeus module surface intentionally compact.
expected_zeus_modules = {
    'FCash_Module_ManageFunds', 'FCash_Module_ManageSharedBanks',
    'FCash_Module_ManageStash', 'FCash_Module_SetBankTerminal',
    'FCash_Module_RemoveBankTerminal'
}
if zeus_modules != expected_zeus_modules:
    errors.append('Unexpected Zeus module surface: got='+str(sorted(zeus_modules))+' expected='+str(sorted(expected_zeus_modules)))


# 15. Runtime/config text must remain ASCII to avoid HEMTT token/parser surprises.
for p in sorted(ADDON.rglob('*')):
    if p.is_file() and p.suffix.lower() in {'.sqf', '.hpp', '.cpp'}:
        txt = p.read_text(encoding='utf-8')
        if any(ord(ch) > 127 for ch in txt):
            errors.append(f'Non-ASCII token remains in runtime/config source: {p.relative_to(ROOT)}')

# 16. Native ATM coverage is intentional and must stay in config, client action install and server validation.
required_atms = {'Land_Atm_01_F', 'Land_Atm_02_F', 'Land_ATM_01_malden_F', 'Land_ATM_02_malden_F'}
for rel in ['config.cpp', 'functions/fn_clientInit.sqf', 'functions/fn_serverValidateTerminal.sqf']:
    txt = (ADDON / rel).read_text(encoding='utf-8')
    missing = sorted(x for x in required_atms if x not in txt)
    if missing:
        errors.append(f'{rel} missing required native ATM classes: {", ".join(missing)}')

# 17. Security/anti-abuse tuning is intentionally not exposed to mission makers in Addon Options.
settings_txt=(ADDON/'functions'/'fn_registerSettings.sqf').read_text(encoding='utf-8')
for setting in ['FCash_setting_maxTransaction','FCash_setting_requestBurst','FCash_setting_requestWindow','FCash_setting_auditLimit']:
    if setting in settings_txt:
        errors.append(f'Security setting should not be exposed through CBA Addon Options: {setting}')

# 18. Account identifiers must be formatted through the fixed seven-digit helper in user-visible account surfaces.
for rel in ['functions/fn_bankingRefresh.sqf','functions/fn_recipientSearchRefresh.sqf','functions/fn_zeusDialogOnLoad.sqf']:
    txt=(ADDON/rel).read_text(encoding='utf-8')
    if 'FCash_fnc_formatAccountNumber' not in txt:
        errors.append(f'{rel} does not normalize displayed account identifiers')

# 19. Recipient UI is search driven; recipient dropdowns are not part of the release UI.
dialog_txt=(ADDON/'ui'/'dialogs.hpp').read_text(encoding='utf-8')
for idc in ['61128','61148']:
    pattern=rf'class\s+\w+\s*:\s*FCash_RscCombo\s*\{{[^}}]*idc\s*=\s*{idc}'
    if re.search(pattern, dialog_txt, re.S):
        errors.append(f'Recipient dropdown found for IDC {idc}; transfers should use recipient search')

# 20. Native ATM support covers ordinary spawned ATMs and anonymous map-baked terrain ATMs.
client_init=(ADDON/'functions'/'fn_clientInit.sqf').read_text(encoding='utf-8')
terrain_scan=(ADDON/'functions'/'fn_clientScanTerrainATMs.sqf').read_text(encoding='utf-8')
terrain_promote=(ADDON/'functions'/'fn_serverPromoteTerrainATM.sqf').read_text(encoding='utf-8')
if 'ace_interact_menu_fnc_addActionToClass' not in client_init or 'FCash_OpenBanking_' not in client_init:
    errors.append('ATM access is not installed as a class-level ACE action for spawned/editor ATMs')
if 'nearestTerrainObjects' not in terrain_scan or 'FCash_fnc_serverPromoteTerrainATM' not in terrain_scan:
    errors.append('Map-baked terrain ATM discovery/promotion path is missing')
if 'nearestTerrainObjects' not in terrain_promote or 'hideObjectGlobal' not in terrain_promote or 'createVehicle' not in terrain_promote:
    errors.append('Server terrain ATM promotion does not validate and replace terrain objects')

# 21. 3DEN object attributes are the supported object/unit authoring surface.
cfg3den_txt=(ADDON/'cfg3den.hpp').read_text(encoding='utf-8')
for prop in ['FCash_3denWalletRaw','FCash_3denBankRaw','FCash_3denIsStorage','FCash_3denStorageRaw','FCash_3denIsTerminal']:
    if prop not in cfg3den_txt:
        errors.append(f'Cfg3DEN is missing Fuhrizen\'s Cash object attribute: {prop}')
if 'FCash_Module_3DENSetup' in cfg or 'module3DENSetup' in cfg:
    errors.append('Unsupported catch-all 3DEN setup module is exposed')

# 22. Internal 3DEN ownership markers must never be exposed as UI members.
sync_txt=(ADDON/'functions'/'fn_serverSyncPlayer.sqf').read_text(encoding='utf-8')
if 'MISSION:' not in sync_txt or 'find "MISSION:"' not in sync_txt:
    errors.append('Internal 3DEN ownership marker is not filtered from shared member snapshots')

# 23. Zeus dialog must dynamically adapt fields to the selected mode.
zeus_mode=(ADDON/'functions'/'fn_zeusDialogModeChanged.sqf').read_text(encoding='utf-8')
if 'SHARED_MANAGE' not in zeus_mode or 'STASH_MANAGE' not in zeus_mode or 'Change (+/-)' not in zeus_mode:
    errors.append('Zeus dialog mode-specific field visibility is incomplete')
if 'zeusDialogModeChanged' not in dialog_txt:
    errors.append('Zeus mode combo does not refresh field visibility')

# 24. Persistence schema is version 1.
export_txt = (ADDON / 'functions' / 'fn_exportState.sqf').read_text(encoding='utf-8')
import_txt = (ADDON / 'functions' / 'fn_importState.sqf').read_text(encoding='utf-8')
if not re.search(r'\[\s*1\s*,', export_txt):
    errors.append('Persistence export does not emit schema version 1')
if '(_state select 0) != 1' not in import_txt:
    errors.append('Persistence import does not require schema version 1')

# 25. Release signing configuration and secret exclusions.
import tomllib
project_cfg = tomllib.loads((ROOT / '.hemtt' / 'project.toml').read_text(encoding='utf-8'))
signing_cfg = project_cfg.get('signing', {})
release_cfg = project_cfg.get('hemtt', {}).get('release', {})
if signing_cfg.get('authority') != 'fuhrizen':
    errors.append('HEMTT signing authority must be fuhrizen')
if signing_cfg.get('version') != 3:
    errors.append('HEMTT signing version must be 3')
if release_cfg.get('sign') is not True:
    errors.append('HEMTT release signing must be enabled')
if release_cfg.get('archive') is not False:
    errors.append('Docker release workflow expects HEMTT archive creation to be disabled')
for rel in ['.gitignore', '.dockerignore']:
    txt = (ROOT / rel).read_text(encoding='utf-8')
    if '*.hemttprivatekey' not in txt:
        errors.append(f'{rel} does not exclude HEMTT private keys')

compose_txt = (ROOT / 'docker-compose.yml').read_text(encoding='utf-8')
compose_services = re.findall(r'^  ([A-Za-z0-9_-]+):\s*$', compose_txt, re.M)
if compose_services != ['build']:
    errors.append(f'Docker Compose must expose exactly one service named build, got: {compose_services}')
if 'source: .' not in compose_txt or 'target: /workspace' not in compose_txt:
    errors.append('Docker build service does not mount the repository at /workspace')
if 'FCASH_HEMTT_MODE' in compose_txt:
    errors.append('Docker Compose still contains the removed build/release mode split')

build_script = (ROOT / 'docker' / 'fcash-build.sh').read_text(encoding='utf-8')
if 'hemtt keys generate' in build_script or 'hemttprivatekey' in build_script:
    errors.append('Docker release builder contains interactive/private-key bootstrap logic')
for required in ['python3 tools/static_check.py', 'hemtt release', 'SHA256SUMS.txt']:
    if required not in build_script:
        errors.append(f'Docker release builder is missing required step: {required}')
if 'git status --porcelain' not in build_script:
    errors.append('Docker release builder does not reject uncommitted release source')

print(f'FCash static check: {len(errors)} error(s), {len(warnings)} warning(s)')
print(f'  functions: {len(declared)} declared / {len(files)} files')
print(f'  server operations: {len(server_ops)}')
print(f'  UI IDCs: {len(defined_idcs)} defined / {len(referenced_idcs)} referenced')
print(f'  Zeus modules: {len(zeus_modules)}')
for e in errors: print('ERROR:',e)
for w in warnings: print('WARN:',w)
if errors: sys.exit(1)
print('PASS')
