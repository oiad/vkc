private ["_activatingPlayer","_isOK","_object","_worldspace","_location","_dir","_class","_uid","_key","_keySelected","_characterID","_donotusekey","_action"];
//PVDZE_veh_Publish2 = [_veh,[_dir,_location],_part_out,false,_keySelected,_activatingPlayer];
#include "\z\addons\dayz_server\compile\server_toggle_debug.hpp"

_object = 		_this select 0;
_worldspace = 	_this select 1;
_class = 		_this select 2;
_donotusekey =	_this select 3;
_keySelected =  _this select 4;
_activatingPlayer =  _this select 5;
_action = if (count _this > 6) then {_this select 6} else {""};
_characterID = _keySelected;

_isOK = isClass(configFile >> "CfgVehicles" >> _class);
if (!_isOK || isNull _object) exitWith {
	diag_log ("HIVE-pv3: Vehicle does not exist: "+ str(_class));
	dze_waiting = "fail";
	(owner _activatingPlayer) publicVariableClient "dze_waiting";
};

#ifdef OBJECT_DEBUG
diag_log ("PUBLISH: Attempt " + str(_object));
#endif

_dir = 		_worldspace select 0;
_location = _worldspace select 1;
_uid = _worldspace call dayz_objectUID2;

//Send request
_key = format["CHILD:308:%1:%2:%3:%4:%5:%6:%7:%8:%9:",dayZ_instance, _class, 0 , _characterID, _worldspace, [], [], 1,_uid];
#ifdef OBJECT_DEBUG
diag_log ("HIVE: WRITE: "+ str(_key)); 
#endif

_key call server_hiveWrite;

// Switched to spawn so we can wait a bit for the ID
[_object,_uid,_characterID,_class,_dir,_location,_donotusekey,_activatingPlayer,_action] spawn {
   private ["_object","_uid","_characterID","_done","_retry","_key","_result","_outcome","_oid","_class","_location","_donotusekey","_activatingPlayer","_countr","_objectID","_objectUID","_dir","_newobject","_weapons","_magazines","_backpacks","_objWpnTypes","_objWpnQty","_fuel","_hitpoints","_strH","_selection","_dam","_isAir","_newHitPoints","_action","_name","_playerUID","_mgp","_message"];

   _object = _this select 0;
   _objectID 	= _object getVariable ["ObjectID","0"];
   _objectUID	= _object getVariable ["ObjectUID","0"];
   _uid = _this select 1;
   _characterID = _this select 2;
   _class = _this select 3;
   _dir = _this select 4;
   // _location = _this select 5;
   _location = [_object] call fnc_getPos;
   _donotusekey = _this select 6;
   _activatingPlayer = _this select 7;
   _action = _this select 8;

   _done = false;
	_retry = 0;
	// TODO: Needs major overhaul for 1.1
	while {_retry < 10} do {
		// GET DB ID
		_key = format["CHILD:388:%1:",_uid];
		#ifdef OBJECT_DEBUG
		diag_log ("HIVE: WRITE: "+ str(_key));
		#endif
		
		_result = _key call server_hiveReadWrite;
		_outcome = _result select 0;
		if (_outcome == "PASS") then {
			_oid = _result select 1;
			//_object setVariable ["ObjectID", _oid, true];
			#ifdef OBJECT_DEBUG
			diag_log("CUSTOM: Selected " + str(_oid));
			#endif
			
			_done = true;
			_retry = 100;

		} else {
			diag_log("CUSTOM: trying again to get id for: " + str(_uid));
			_done = false;
			_retry = _retry + 1;
			uiSleep 1;
		};
	};

	if (!_done) exitWith {
		diag_log("HIVE-pv3: failed to get id for : " + str(_uid));
		_key = format["CHILD:310:%1:",_uid];
		_key call server_hiveWrite;
		
		dze_waiting = "fail";
		(owner _activatingPlayer) publicVariableClient "dze_waiting";
	};
	
	_hitpoints = _object call vehicle_getHitpoints;
	_newHitPoints = [];
	_fuel = fuel _object;
	
	{
		_dam = [_object,_x] call object_getHit;
		_selection = getText (configFile >> "CfgVehicles" >> (typeOf _object) >> "HitPoints" >> _x >> "name");
		_newHitPoints set [count _newHitPoints,[_selection,_dam]];
	} forEach _hitpoints;

	// add items from previous vehicle here
	_weapons = 		getWeaponCargo _object;
	_magazines = 	getMagazineCargo _object;
	_backpacks = 	getBackpackCargo _object;

	clearWeaponCargoGlobal _object;
	clearMagazineCargoGlobal _object;
	clearBackpackCargoGlobal _object;

	// Remove marker
	deleteVehicle _object;

	_newobject = _class createVehicle [0,0,0];

	// remove old vehicle from DB
	[_objectID,_objectUID,_activatingPlayer,_class] call server_deleteObj;

	// switch var to new vehicle at this point.
	_object = _newobject;

	_object setDir _dir;
	_object setPosATL _location;
	_object setVectorUp surfaceNormal _location;
	_object setFuel _fuel;

	_isAir = _object isKindOf "Air";
	{
		_selection = _x select 0;
		_dam = if (!_isAir && {_selection in dayZ_explosiveParts}) then {(_x select 1) min 0.8;} else {_x select 1;};
		_strH = "hit_" + (_selection);
		_object setHit[_selection,_dam];
		_object setVariable [_strH,_dam,true];
	} foreach _newHitPoints;

	clearWeaponCargoGlobal _object;
	clearMagazineCargoGlobal _object;
	clearBackpackCargoGlobal _object;
	
	//Add weapons
	_objWpnTypes = _weapons select 0;
	_objWpnQty = _weapons select 1;
	_countr = 0;
	{
		_object addWeaponCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes;
	
	//Add Magazines
	_objWpnTypes = _magazines select 0;
	_objWpnQty = _magazines select 1;
	_countr = 0;
	{
		_object addMagazineCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes;

	//Add Backpacks
	_objWpnTypes = _backpacks select 0;
	_objWpnQty = _backpacks select 1;
	_countr = 0;
	{
		_object addBackpackCargoGlobal [_x,(_objWpnQty select _countr)];
		_countr = _countr + 1;
	} count _objWpnTypes;

	_object setVariable ["ObjectID", _oid, true];
	_object setVariable ["lastUpdate",time];
	_object setVariable ["CharacterID", _characterID, true];

	dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_object];

	_object call fnc_veh_ResetEH;
	[_object,"all"] call server_updateObject;
	
	// for non JIP users this should make sure everyone has eventhandlers for vehicles.
	PVDZE_veh_Init = _object;
	publicVariable "PVDZE_veh_Init";

	dze_waiting = "success";
	(owner _activatingPlayer) publicVariableClient "dze_waiting";
	
	_name = if (alive _activatingPlayer) then {name _activatingPlayer} else {"unknown player"};
	_playerUID = getPlayerUID _activatingPlayer;
	_mgp = mapGridPosition _location;
	
	if (_action == "") then {
		_message = format ["%1 (%2) upgraded %3 @%4 %5",_name,_playerUID,_class,_mgp,_location];
	} else {
		_message = format ["%1 (%2) %6 %3 @%4 %5",_name,_playerUID,_class,_mgp,_location,_action];
	};
	diag_log _message;
};
