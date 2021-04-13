# [EPOCH 1.0.7] Vehicle Key Changer
Vehicle key changer script for Epoch 1.0.7 by salival updated by Airwaves Man.

* Discussion URL: https://epochmod.com/forum/topic/43348-release-vehicle-key-changer-updated-for-epoch-106/
* original discussion url: https://epochmod.com/forum/topic/5972-release-vehicle-key-changer-for-making-masterkey-v-14-updated-06152014/
* updated discussion url: https://epochmod.com/forum/topic/43048-release-vehicle-key-changer-for-making-masterkey-v-141-updated-for-epoch-106/
	
* Tested as working on a blank Epoch 1.0.7
* This adds support for briefcases, gems and coins.
* Uses the epoch vehicle upgrade system to do the key changing/claiming.

# REPORTING ERRORS/PROBLEMS

1. Please, if you report issues can you please attach (on pastebin or similar) your CLIENT rpt log file as this helps find out the errors very quickly. To find this logfile:

	```sqf
	C:\users\<YOUR WINDOWS USERNAME>\AppData\Local\Arma 2 OA\ArmA2OA.RPT
	```

# Index:

* [Mission folder install](https://github.com/oiad/vkc#mission-folder-install)
* [dayz_server folder install](https://github.com/oiad/vkc#dayz_server-folder-install)
* [BattlEye filter install](https://github.com/oiad/vkc#battleye-filter-install)
	
**[>> Download <<](https://github.com/oiad/vkc/archive/master.zip)**	
	
# Install:

* This install basically assumes you have a custom variables.sqf, compiles.sqf and fn_selfActions.sqf.

# Mission folder install:

1. 	Open your fn_selfactions.sqf and search for:

	```sqf
	// ZSC
	if (Z_singleCurrency) then {
	```

	Add this code lines above:
	
	```sqf	
	if (_isVehicle && !_isMan && _isAlive && {_characterID == "0"} && {"ItemKeyKit" in weapons player}) then {
		if (s_player_claimVehicle < 0) then {
			_totalKeys = call epoch_tempKeys;
			if (count (_totalKeys select 0) > 0) then {
				s_player_claimVehicle = player addAction [format["<t color='#0059FF'>%1</t>",format[localize "STR_CL_VKC_CLAIM_ACTION",_text]],"scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,"claim"],5,false,true];
			};
		};
	} else {
		player removeAction s_player_claimVehicle;
		s_player_claimVehicle = -1;
	};
	```	
	
2. 	Open your fn_selfactions.sqf and search for:

	```sqf
	// Allow Owner to lock and unlock vehicle
	if (_player_lockUnlock_crtl) then {
		if (s_player_lockUnlock_crtl < 0) then {
			local _totalKeys = call epoch_tempKeys;
			local _temp_keys = _totalKeys select 0;
			local _temp_keys_names = _totalKeys select 1;
			local _hasKey = _characterID in _temp_keys;
			local _oldOwner = (_characterID == _uid);
			local _unlock = [];
			
			if (_isLocked) then {
				if (_hasKey || _oldOwner) then {
					_unlock = player addAction [format[localize "STR_EPOCH_ACTIONS_UNLOCK",_text], "\z\addons\dayz_code\actions\unlock_veh.sqf",[_cursorTarget,(_temp_keys_names select (_temp_keys find _characterID))], 2, true, true];
					s_player_lockunlock set [count s_player_lockunlock,_unlock];
					s_player_lockUnlock_crtl = 1;
				} else {
					if (_hasHotwireKit) then {
						_unlock = player addAction [format[localize "STR_EPOCH_ACTIONS_HOTWIRE",_text], "\z\addons\dayz_code\actions\hotwire_veh.sqf",_cursorTarget, 2, true, true];
					} else {
						_unlock = player addAction [format["<t color='#ff0000'>%1</t>",localize "STR_EPOCH_ACTIONS_VEHLOCKED"], "",_cursorTarget, 2, false, true];
					};
					s_player_lockunlock set [count s_player_lockunlock,_unlock];
					s_player_lockUnlock_crtl = 1;
				};
			} else {
				if (_hasKey || _oldOwner) then {
					_lock = player addAction [format[localize "STR_EPOCH_ACTIONS_LOCK",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 1, true, true];
					s_player_lockunlock set [count s_player_lockunlock,_lock];
					s_player_lockUnlock_crtl = 1;
				};
			};
		};
	} else {
		{player removeAction _x} count s_player_lockunlock;s_player_lockunlock = [];
		s_player_lockUnlock_crtl = -1;
	};
	```

	Replace the code from above with this code:
	
	```sqf	
	// Allow Owner to lock and unlock vehicle
	if (_player_lockUnlock_crtl) then {
		local _totalKeys = call epoch_tempKeys;
		local _temp_keys = _totalKeys select 0;
		local _temp_keys_names = _totalKeys select 1;
		local _hasKey = _characterID in _temp_keys;
		
		if (s_player_lockUnlock_crtl < 0) then {
			local _oldOwner = (_characterID == _uid);
			local _unlock = [];
			
			if (_isLocked) then {
				if (_hasKey || _oldOwner) then {
					_unlock = player addAction [format[localize "STR_EPOCH_ACTIONS_UNLOCK",_text], "\z\addons\dayz_code\actions\unlock_veh.sqf",[_cursorTarget,(_temp_keys_names select (_temp_keys find _characterID))], 2, true, true];
					s_player_lockunlock set [count s_player_lockunlock,_unlock];
					s_player_lockUnlock_crtl = 1;
				} else {
					if (_hasHotwireKit) then {
						_unlock = player addAction [format[localize "STR_EPOCH_ACTIONS_HOTWIRE",_text], "\z\addons\dayz_code\actions\hotwire_veh.sqf",_cursorTarget, 2, true, true];
					} else {
						_unlock = player addAction [format["<t color='#ff0000'>%1</t>",localize "STR_EPOCH_ACTIONS_VEHLOCKED"], "",_cursorTarget, 2, false, true];
					};
					s_player_lockunlock set [count s_player_lockunlock,_unlock];
					s_player_lockUnlock_crtl = 1;
				};
			} else {
				if (_hasKey || _oldOwner) then {
					_lock = player addAction [format[localize "STR_EPOCH_ACTIONS_LOCK",_text], "\z\addons\dayz_code\actions\lock_veh.sqf",_cursorTarget, 1, true, true];
					s_player_lockunlock set [count s_player_lockunlock,_lock];
					s_player_lockUnlock_crtl = 1;
				};
			};
		};
		if (s_player_copyToKey < 0) then {
			if ((_hasKey && !_isLocked && {"ItemKeyKit" in weapons player} && {(count _temp_keys) > 1}) || {_cursorTarget getVariable ["hotwired",false]}) then {
				s_player_copyToKey = player addAction [format["<t color='#0059FF'>%1</t>",localize "STR_CL_VKC_CHANGE_ACTION"],"scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,if (_cursorTarget getVariable ["hotwired",false]) then {"claim"} else {"change"}],5,false,true];
			};
		};		
	} else {
		{player removeAction _x} count s_player_lockunlock;s_player_lockunlock = [];
		s_player_lockUnlock_crtl = -1;
		player removeAction s_player_copyToKey;
		s_player_copyToKey = -1;
	};
	```		
	
3. In fn_selfactions search for this codeblock:

	```sqf
	player removeAction s_bank_dialog3;
	s_bank_dialog3 = -1;
	player removeAction s_player_checkWallet;
	s_player_checkWallet = -1;	
	```	
	
	And add this below:
	
	```sqf
	player removeAction s_player_copyToKey;
	s_player_copyToKey = -1;
	player removeAction s_player_claimVehicle;
	s_player_claimVehicle = -1;
	```
	
4. Open your variables.sqf and search for:

	```sqf
	s_bank_dialog3 = -1;
	s_player_checkWallet = -1;	
	```
	And add this below:
	
	```sqf
	s_player_copyToKey = -1;
	s_player_claimVehicle = -1;
	```
	
5. Open your variables.sqf and search for:	

	```sqf
	if (!isDedicated) then {
	```
	
	And add this inside the square brackets so it looks like this:
	
	```sqf
	if (!isDedicated) then {
		vkc_claimPrice = 1000; // Amount in worth for claiming a vehicle. See the top of this script for an explanation.
		vkc_changePrice = 5000; // Amount in worth for changing the key for a vehicle. See the top of this script for an explanation.
	};	
	```
	
6. Open your variables.sqf and search for:	

	```sqf
	if (isServer) then {
	```
	
	And add this inside the square brackets so it looks like this:
	
	```sqf
	if (isServer) then {
		vkc_clearAmmo = true; // Clear the ammo of vehicles after they have been rekeyed/claimed? (stops users getting a free rearm)
		vkc_disableThermal = [""]; // Array of vehicle config classes as well as vehicle classnames to disable thermal on when being spawned. i.e: ["All","Land","Air","Ship","StaticWeapon","AH1Z","MTVR"];
	};	
	```		
	
7. In mission\description.ext add the following line directly at the bottom:

	```sqf
	#include "scripts\vkc\vkc.hpp"
	```
	
# dayz_server folder install:

1. Replace or merge the contents of <code>server_publishVehicle3.sqf</code> provided with your original copy.

# Battleye filter install:

1. In your config\<yourServerName>\Battleye\scripts.txt around line 17: <code>5 cashMoney</code> add this to the end of it:

	```sqf
	!="nfo = [false,[],[],[],0];\n_wealth = player getVariable [([\"cashMoney\",\"globalMoney\"] select Z_persistentMoney),0];\n\nif (Z_Single"
	```

	So it will then look like this for example:

	```sqf
	5 cashMoney <CUT> !="nfo = [false,[],[],[],0];\n_wealth = player getVariable [([\"cashMoney\",\"globalMoney\"] select Z_persistentMoney),0];\n\nif (Z_Single"
	```
	
2. In your config\<yourServerName>\Battleye\scripts.txt around line 22: <code>1 compile</code> add this to the end of it:

	```sqf
	!="ialization;\n\nif (isNil \"vkc_init\") then {\nvkc_vehicleInfo = compile preprocessFileLineNumbers \"scripts\\vkc\\vehicleInfo.sqf\";\nvkc"
	```

	So it will then look like this for example:

	```sqf
	1 compile <CUT> !="ialization;\n\nif (isNil \"vkc_init\") then {\nvkc_vehicleInfo = compile preprocessFileLineNumbers \"scripts\\vkc\\vehicleInfo.sqf\";\nvkc"
	```	
	
3. In your config\<yourServerName>\Battleye\scripts.txt around line 24: <code>5 createDialog</code> add this to the end of it:

	```sqf
	!="urrencyName]} else {[_amount,true] call z_calcCurrency};\n\ncreateDialog \"vkc\";\n{ctrlShow [_x,false]} count [4803,4850,4851];\n\ncal"
	```

	So it will then look like this for example:

	```sqf
	5 createDialog <CUT> !="urrencyName]} else {[_amount,true] call z_calcCurrency};\n\ncreateDialog \"vkc\";\n{ctrlShow [_x,false]} count [4803,4850,4851];\n\ncal"
	```	
	
4. In your config\<yourServerName>\Battleye\scripts.txt around line 43: <code>5 globalMoney</code> add this to the end of it:

	```sqf
	!="[],[],[],0];\n_wealth = player getVariable [([\"cashMoney\",\"globalMoney\"] select Z_persistentMoney),0];\n\nif (Z_SingleCurrency) the"
	```

	So it will then look like this for example:

	```sqf
	5 globalMoney <CUT> !="[],[],[],0];\n_wealth = player getVariable [([\"cashMoney\",\"globalMoney\"] select Z_persistentMoney),0];\n\nif (Z_SingleCurrency) the"
	```	

5. In your config\<yourServerName>\Battleye\scripts.txt around line 50: <code>5 lbSet</code> add this to the end of it:

	```sqf
	!="bAdd ((vkc_keyList select 1) select _forEachIndex);\n_control lbSetPicture [_index,getText(configFile >> \"CfgWeapons\" >> ((vkc_ke"
	```

	So it will then look like this for example:

	```sqf
	5 lbSet <CUT> !="bAdd ((vkc_keyList select 1) select _forEachIndex);\n_control lbSetPicture [_index,getText(configFile >> \"CfgWeapons\" >> ((vkc_ke"
	```
	
6. In your config\<yourServerName>\Battleye\scripts.txt around line 53: <code>1 nearEntities</code> add this to the end of it:

	```sqf
	!="{isPlayer _x} count (([vkc_cursorTarget] call FNC_GetPos) nearEntities [\"CAManBase\", 10]) > 1;\nif (_playerNear) exitWith {call _"
	```

	So it will then look like this for example:

	```sqf
	1 nearEntities <CUT> !="{isPlayer _x} count (([vkc_cursorTarget] call FNC_GetPos) nearEntities [\"CAManBase\", 10]) > 1;\nif (_playerNear) exitWith {call _"
	```	
	
7. In your config\<yourServerName>\Battleye\scripts.txt around line 80: <code>5 setVehicle</code> add this to the end of it:

	```sqf
	!="stentMoney),(_wealth - _amount),true];};\n\nvkc_cursorTarget setVehicleLock \"LOCKED\";\nplayer playActionNow \"Medic\";\n\n_position = ["
	```

	So it will then look like this for example:

	```sqf
	5 setVehicle <CUT> !="stentMoney),(_wealth - _amount),true];};\n\nvkc_cursorTarget setVehicleLock \"LOCKED\";\nplayer playActionNow \"Medic\";\n\n_position = ["
	```	
	
8. In your config\<yourServerName>\Battleye\scripts.txt around line 49: <code>5 lbCurSel</code> add this to the end of it:

	```sqf
	!="vkc_charID = (vkc_keyList select 0) select (lbCurSel 4802);vkc_keyName = (vkc_keyList select 1) select (lbCurSel 4802);"
	```

	So it will then look like this for example:

	```sqf
	5 lbCurSel <CUT> !="vkc_charID = (vkc_keyList select 0) select (lbCurSel 4802);vkc_keyName = (vkc_keyList select 1) select (lbCurSel 4802);"
	```	

**** *For Epoch 1.0.6.2 only* ****
**[>> Download <<](https://github.com/oiad/vkc/archive/refs/tags/Epoch_1.0.6.2.zip)**

Visit this link: https://github.com/oiad/vkc/tree/Epoch_1.0.6.2	