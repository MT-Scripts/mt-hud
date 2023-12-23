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

server_scripts {
    'server/*.lua',
}

ui_page 'web/index.html'

files {
    'locales/*.json',
    'web/*.html',
    'web/*.css',
    'web/*.js'
}