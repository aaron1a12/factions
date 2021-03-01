resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'


client_scripts {
	'global.lua',
	'respawn.lua',
	'mood.lua',
	'client.lua'
}

server_scripts {
	--'server.lua',
}

dependencies {
}

ui_page('html/index.html')

files {
	'html/index.html',
	'html/js/howler.min.js',
	'html/sounds/death.ogg'
}


files {
	'weapons.meta',
	'weaponrevolver.meta',
	'weaponanimations.meta'
}
 
data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponrevolver.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'