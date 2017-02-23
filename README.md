# [EPOCH 1.0.6+] Vehicle Key Changer
Vehicle key changer script updated for Epoch 1.0.6+ by salival.

* Discussion URL: https://epochmod.com/forum/topic/43348-release-vehicle-key-changer-updated-for-epoch-106/
* original discussion url: https://epochmod.com/forum/topic/5972-release-vehicle-key-changer-for-making-masterkey-v-14-updated-06152014/
* updated discussion url: https://epochmod.com/forum/topic/43048-release-vehicle-key-changer-for-making-masterkey-v-141-updated-for-epoch-106/
	
* Tested as working on a blank Epoch 1.0.6+
* This adds support for briefcases, gems and coins.
* Uses the epoch vehicle upgrade system to do the key changing/claiming.

# Install:

* This install basically assumes you have NO custom variables.sqf or compiles.sqf or fn_selfActions.sqf, I would recommend diffmerging where possible.

**[>> Download <<] (https://github.com/oiad/vkc/archive/master.zip)**

# Mission folder install:

1. In mission\init.sqf find: <code>call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";</code> and add directly below:

	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\variables.sqf";
	```
	
2. In mission\init.sqf find: <code>call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";</code> and add directly below:

	```sqf
	call compile preprocessFileLineNumbers "dayz_code\init\compiles.sqf";
	```

# dayz_server folder install:

1. Replace or merge the contents of <code>server_publishVehicle3.sqf.sqf</code> provided with your original copy.

# If you are running Epoch 1.0.6 and NOT running Epoch 1.0.6.1+ you must make sure you have the newer epoch_tempKeys that is in the supplied compiles.sqf.


	
# Infistar setup:

1. Make sure the variable _BCM (around line 99) is set to false.

2. In your AHconfig.sqf make sure the variable _cMenu (around line 158) contains "#USER:_keyMenu".