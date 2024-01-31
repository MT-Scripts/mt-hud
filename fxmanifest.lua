fx_version 'cerulean'
author 'Marttins'
description 'Simple Player HUD for FiveM'
game 'gta5'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

ui_page 'web/index.html'

files {
    'web/*.html',
    'web/*.css',
    'web/*.js'
}
