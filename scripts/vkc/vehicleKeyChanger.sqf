private ["_action","_amount","_characterID","_copyMenu","_cursorTarget","_displayName","_enoughMoney","_exit","_i","_itemText","_j","_keyArray","_keyItemName","_keyList","_keyMenu","_keyName","_max","_message","_moneyInfo","_name","_playerNear","_position","_snext","_success","_typeOf","_vehicleID","_vehicleUID","_wealth"];

_cursorTarget = (_this select 3) select 0;
_characterID = (_this select 3) select 1;
_action = (_this select 3) select 2;
_keyList = (_this select 3) select 3;
_displayName = (_this select 3) select 4;
_keyName = (_this select 3) select 5;
_keyItemName = (_this select 3) select 6;

/*
	This version adds support for both single currency and gems (from the epoch 1.0.6 update) as well as the original epoch briefcase currency system. 
	Instead of pricing things like the original way, prices are now done on a "worth" similar to how coins are done. The price value of items are below.
	If you are using coins, I would recommend using the _currencyModifier variable since coins typically are 10x the value of briefcase based currency (1 brief == 100,000 coins)

	1 silver = 1 worth
	1 10oz silver = 10 worth
	1 gold = 100 worth
	1 10oz gold = 1,000 worth
	1 briefcase = 10,000 worth

	Please see dayz_code\configVariables.sqf for the value of gems (DZE_GemWorthArray) and their relevant worth if they are enabled.
*/

_amount = 5000;

player removeAction s_player_claimVehicle;
s_player_claimVehicle = 1;
player removeAction s_player_copyToKey;
s_player_copyToKey = 1;

_exit = {
	s_player_copyToKey = -1;
	s_player_claimVehicle = -1;
};

_playerNear = {isPlayer _x} count (([_cursorTarget] call FNC_GetPos) nearEntities ["CAManBase", 10]) > 1;
if (_playerNear) exitWith {call _exit; localize "str_pickup_limit_5" call dayz_rollingMessages;};

if (isNull _cursorTarget) exitWith {call _exit; systemChat "cursorTarget isNull!";};

if !(_cursorTarget isKindOf "Air" || {_cursorTarget isKindOf "LandVehicle"} || {_cursorTarget isKindOf "Ship"}) exitWith {call _exit; "cursorTarget is not a vehicle." call dayz_rollingMessages;};

_vehicleID = _cursorTarget getVariable ["ObjectID","0"];
_vehicleUID = _cursorTarget getVariable ["ObjectUID","0"];

_typeOf = typeOf _cursorTarget;
_name = getText(configFile >> "cfgVehicles" >> _typeOf >> "displayName");

if (_vehicleID == "0" && {_vehicleUID == "0"}) exitWith {call _exit; format ["Sorry but %1 does not support Keychange/Claiming!",_name] call dayz_rollingMessages;};

if (_vehicleUID == "0") then {
	_vehicleUID = "";
	{
		_x = _x * 10;
		if (_x < 0) then {_x = _x * -10};
		_vehicleUID = _vehicleUID + str(round(_x));
	} forEach getPosATL _cursorTarget;
	_vehicleUID = _vehicleUID + str(round((getDir _cursorTarget) + time));
	_cursorTarget setVariable["ObjectUID",_vehicleUID,true];
};

keyNameList = [];
for "_i" from 0 to (count _displayName) -1 do {
	keyNameList set [(count keyNameList),_displayName select _i];
};

keyNumberList = [];
for "_i" from 0 to (count _keyList) -1 do {
	keyNumberList set [(count keyNumberList),_keyList select _i];
};

keyNameSelect = "";
_snext = false;

_message = if (_action == "change") then {
	["%1's key has been changed to %2","change the key for","changed the key for"]
} else {
	["%1 has been claimed, the key is: %2","claim the key for","claimed"]
};

_itemText = if (Z_SingleCurrency) then {format ["%1 %2",[_amount] call BIS_fnc_numberText,CurrencyName]} else {[_amount,true] call z_calcCurrency};

_copyMenu = {
	private ["_keyMenu","_keyArray"];
	_keyMenu = [["",true], [format ["Select the new key (%1):",_itemText], [-1], "", -5, [["expression", ""]], "1", "0"]];
	for "_i" from (_this select 0) to (_this select 1) do {
		_keyArray = [format['%1', keyNameList select (_i)], [_i - (_this select 0) + 2], "", -5, [["expression", format ["keyNameSelect = keyNameList select %1; keyNumberSelect = keyNumberList select %1", _i]]], "1", "1"];
		_keyMenu set [_i + 2, _keyArray];
	};
	_keyMenu set [(_this select 1) + 2, ["", [-1], "", -5, [["expression", ""]], "1", "0"]];
	if (count keyNameList > (_this select 1)) then {
		_keyMenu set [(_this select 1) + 3, ["Next", [12], "", -5, [["expression", "_snext = true;"]], "1", "1"]];
	} else {
		_keyMenu set [(_this select 1) + 3, ["", [-1], "", -5, [["expression", ""]], "1", "0"]];
	};
	_keyMenu set [(_this select 1) + 4, ["Exit", [13], "", -5, [["expression", "keyNameSelect = 'exitscript';"]], "1", "1"]];
	showCommandingMenu "#USER:_keyMenu";
};

_j = 0;
_max = 10;
if (_max > 9) then {_max = 10;};
while {keyNameSelect == ""} do {
	[_j, (_j + _max) min (count keyNameList)] call _copyMenu;
	_j = _j + _max;
	waitUntil {keyNameSelect != "" || _snext};
	_snext = false;
};

if (keyNameSelect == "exitscript") exitWith {call _exit;};

_enoughMoney = false;
_moneyInfo = [false,[],[],[],0];
_wealth = player getVariable[Z_MoneyVariable,0];

if (Z_SingleCurrency) then {
	_enoughMoney = (_wealth >= _amount);
} else {
	Z_Selling = false;
	if (Z_AllowTakingMoneyFromVehicle) then {false call Z_checkCloseVehicle};
	_moneyInfo = _amount call Z_canAfford;
	_enoughMoney = _moneyInfo select 0;
};

_success = if (Z_SingleCurrency) then {true} else {[player,_amount,_moneyInfo,true,0] call Z_payDefault};

if (!_success && {_enoughMoney}) exitWith {systemChat localize "STR_EPOCH_TRADE_GEAR_AND_BAG_FULL"}; // Not enough room in gear or bag to accept change

if (_enoughMoney) then {
	_success = if (Z_SingleCurrency) then {_amount <= _wealth} else {[player,_amount,_moneyInfo,false,0] call Z_payDefault};
	if (_success) then {
		if (Z_SingleCurrency) then {
			player setVariable[Z_MoneyVariable,(_wealth - _amount),true];
		};

		_cursorTarget setVehicleLock "LOCKED";
		player playActionNow "Medic";
		
		_position = getPosASL _cursorTarget;
	
		if !(surfaceIsWater _position) then {_position = ASLToATL _position;};
		
		[_typeOf,objNull] call fn_waitForObject;
		dze_waiting = nil;
		
		PVDZE_veh_Upgrade = [_cursorTarget,[getDir _cursorTarget,_position],_typeOf,false,keyNumberSelect,player,_message select 2];
		publicVariableServer "PVDZE_veh_Upgrade";

		{player reveal _x;} count (player nearEntities [["LandVehicle"],10]);
 
		waitUntil {!isNil "dze_waiting"};
		
		if (dze_waiting == "fail") then {
			systemChat format ["Failed to upgrade %1, you have been refunded the cost. If this continues, contact the admin",_name];
			if (z_singleCurrency) then {
				player setVariable[Z_MoneyVariable,_wealth,true];
			} else {
				Z_Selling = true;
				_success = [_amount,0,false,0,[],[],false] call Z_returnChange;
			};
		} else {
			format [_message select 0,_name,keyNameSelect] call dayz_rollingMessages;
		};
	} else {
		systemChat localize "STR_EPOCH_TRADE_DEBUG";
	};
} else {
	systemChat format ["You need %1 to %2 %3.",_itemText,_message select 1,_name];
};

call _exit; 
