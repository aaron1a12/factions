resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

--this_is_a_map 'yes'

client_scripts {
	'config.lua',
	'global.lua',
	'respawn.lua',
	'mood.lua',
	'reticule.lua',
	'client.lua',
	'Client.net.dll',
}

server_scripts {
	'config.lua',
	'server.lua',
	'Server.net.dll',	
}

dependencies {
}

ui_page('html/index.html')

files {
	'html/index.html',
	'html/img/reticle.png',
	'html/img/reticle_shotgun.png',
	'html/css/main.css',
	'html/css/DIN-Medium.ttf',
	'html/js/howler.min.js',
	'html/sounds/death.ogg'
}


files {
	'weapons.meta',
	'weaponrevolver.meta',
	'weaponanimations.meta',
	'weapons_doubleaction.meta'
}
 
data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponrevolver.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_doubleaction.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'