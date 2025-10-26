fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Enhanced TrapPhone Script'
description 'Advanced Trap Phone System with Ox_lib Integration'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*'
}

dependencies {
    'ox_lib',
    'ox_inventory'
}