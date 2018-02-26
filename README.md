# [EPOCH 1.0.6.1] Vehicle Key Changer
Vehicle key changer script updated for Epoch 1.0.6.1 by salival.

* Discussion URL: https://epochmod.com/forum/topic/43348-release-vehicle-key-changer-updated-for-epoch-106/
* original discussion url: https://epochmod.com/forum/topic/5972-release-vehicle-key-changer-for-making-masterkey-v-14-updated-06152014/
* updated discussion url: https://epochmod.com/forum/topic/43048-release-vehicle-key-changer-for-making-masterkey-v-141-updated-for-epoch-106/
	
* Tested as working on a blank Epoch 1.0.6.1
* This adds support for briefcases, gems and coins.
* Uses the epoch vehicle upgrade system to do the key changing/claiming.

# REPORTING ERRORS/PROBLEMS

1. Please, if you report issues can you please attach (on pastebin or similar) your CLIENT rpt log file as this helps find out the errors very quickly. To find this logfile:

	```sqf
	C:\users\<YOUR WINDOWS USERNAME>\AppData\Local\Arma 2 OA\ArmA2OA.RPT
	```

# Index:

* [Fresh Install](https://github.com/oiad/vkc#fresh-install)
* [Mission folder install](https://github.com/oiad/vkc#mission-folder-install)
* [dayz_server folder install](https://github.com/oiad/vkc#dayz_server-folder-install)
* [BattlEye filter install](https://github.com/oiad/vkc#battleye-filter-install)
* [infiSTAR setup](https://github.com/oiad/vkc#infistar-setup)
* [Upgrading with previous version installed](https://github.com/oiad/vkc#upgrading-with-previous-version-installed)
	
# Fresh install:

* This install basically assumes you have NO custom variables.sqf or compiles.sqf or fn_selfActions.sqf, I would recommend diffmerging where possible.

**[>> Download <<](https://github.com/oiad/vkc/archive/master.zip)**

# Mission folder install:

1. In mission\init.sqf find: <code>call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";</code> and add this directly below:

	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\variables.sqf";
	```

2. In mission\init.sqf find: <code>call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";</code> and add this directly below:

	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\compiles.sqf";
	```

3. In mission\description.ext add the following line directly at the bottom:

	```sqf
	#include "scripts\vkc\vkc.hpp"
	```

4. Download the <code>stringTable.xml</code> file linked below from the [Community Localization GitHub](https://github.com/oiad/communityLocalizations) and copy it to your mission folder, it is a community based localization file and contains translations for major community mods including this one.

**[>> Download stringTable.xml <<](https://github.com/oiad/communityLocalizations/blob/master/stringtable.xml)**

# dayz_server folder install:

1. Replace or merge the contents of <code>server_publishVehicle3.sqf</code> provided with your original copy.

# Battleye filter install:

1. This assumes you are running the DEFAULT epoch filters.

2. On line 12 of <code>config\<yourServerName>\Battleye\scripts.txt</code>: <code>5 createDialog</code> add this to the end of it:
	```sqf
	!="createDialog \"vkc\";"
	```
	
	So it will then look like this for example:

	```sqf
	5 createDialog <CUT> !="createDialog \"vkc\";"
	```
	
# Infistar setup:

1. If you have <code>_CUD = true;</code> in your AHconfig.sqf: Add <code>4800</code> to the end of your <code>_ALLOWED_Dialogs</code> array, i.e:
	```sqf
	_ALLOWED_Dialogs = _ALLOWED_Dialogs + [81000,88890,20001,20002,20003,20004,20005,20006,55510,55511,55514,55515,55516,55517,55518,55519,555120,118338,118339,571113,4800]; // adding some others from community addons
	```

2. If you have <code>_CSA =  true;</code> in your AHconfig.sqf: Add <code>,"s_player_copyToKey","s_player_claimVehicle"</code> to the end of your <code>_dayzActions =</code> array, i.e:
	```sqf
	"Tow_settings_dlg_CV_btn_fermer","Tow_settings_dlg_CV_titre","unpackRavenAct","vectorActions","wardrobe","s_player_copyToKey","s_player_claimVehicle"
	```

# Upgrading with previous version installed:

1. Copy the files from the github repo in the <code>scripts\vkc</code> folder to your current VKC folder in your mission file overwriting anything when prompted.

2. Copy <code>dayz_server\compile\server_publishVehicle3.sqf</code> to your <code>dayz_server\compile</code> folder overwriting it when prompted.

3. In your <code>dayz_code\compile\fn_selfActions.sqf</code> find this code block:
	```sqf
	if (_hasKey && {_hasKeyKit} && {(count _temp_keys) > 1} && {!_isLocked}) then {
		_temp_key_name = (_temp_keys_names select (_temp_keys find _characterID));
		_vkc_carKeyName = getText (configFile >> "CfgWeapons" >> _temp_key_name >> "displayName");
		_temp_keys = _temp_keys - [_characterID];
		_vkc_temp_keys_names = _temp_keys_names - [_temp_key_name];
		s_player_copyToKey = player addAction ["<t color=""#0096FF"">Change vehicle key</t>","scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,"change",_temp_keys,_vkc_temp_keys_names],5,true,true];
	};
	```
	Replace it with this code block:
	```sqf
			if (_hasKey && {_hasKeyKit} && {(count _temp_keys) > 1} && {!_isLocked}) then {
				s_player_copyToKey = player addAction ["<t color=""#0096FF"">Change vehicle key</t>","scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,"change"],5,false,true];
			};
	```
	Also in your <code>dayz_code\compile\fn_selfActions.sqf</code> find this code block:
	```sqf
	if (s_player_claimVehicle < 0) then {
		_totalKeys = call epoch_tempKeys;
		_temp_keys = _totalKeys select 0;
		_temp_keys_names = _totalKeys select 1;
		if (count _temp_keys > 0) then {
			s_player_claimVehicle = player addAction [format ["<t color=""#0096FF"">Claim %1</t>",_text],"scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,"claim",_temp_keys,_temp_keys_names],5,true,true];
		};
	};
	```
	Replace it with this code block:
	```sqf
		if (s_player_claimVehicle < 0) then {
			_totalKeys = call epoch_tempKeys;
			if (count (_totalKeys select 0) > 0) then {
				s_player_claimVehicle = player addAction [format ["<t color=""#0096FF"">Claim %1</t>",_text],"scripts\vkc\vehicleKeyChanger.sqf",[_cursorTarget,_characterID,"claim"],5,false,true];
			};
		};
	```
4. In your <code>dayz_code\init\variables.sqf</code> find this line:
	```sqf
	//Player self-action handles
	```
	Add these two lines above it:
	```sqf
	vkc_claimPrice = 1000; // Amount in worth for claiming a vehicle. See the top of this script for an explanation.
	vkc_changePrice = 5000; // Amount in worth for changing the key for a vehicle. See the top of this script for an explanation.
	```
5. In mission\description.ext add the following line directly at the bottom:

	```sqf
	#include "scripts\vkc\vkc.hpp"
	```

6. Install new the BattlEye filter for your scripts.txt [BattlEye filter install](https://github.com/oiad/vkc#battleye-filter-install)
7. If you run infiSTAR: In your AHconfig.sqf remove from the _cMenu array (around line 158) <code>,"#USER:_keyMenu"</code> also make sure you run this install step: [Infistar setup](https://github.com/oiad/vkc#infistar-setup)