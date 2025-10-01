fx_version("cerulean")
game("gta5")

name("@https://github.com/thezyric")
author("@https://github.com/thezyric")
version("2.42.7")
description ("@https://github.com/thezyric")
repository("@https://github.com/thezyric")

shared_scripts({
    "require.lua",
    "init.lua",
})

ui_page("dist/index.html")

files({
    "dist/index.html",
    "dist/assets/*.js",
    "dist/assets/*.css",
    "dist/**/*.woff2",
    "config/*.lua",
    "config/functions.lua",
    "modules/interface/client.lua",
    "modules/utility/shared/logger.lua",
    "modules/utility/shared/main.lua",
    "modules/seatbelt/client.lua",
    "modules/frameworks/**/*.lua",
    "modules/threads/client/**/*.lua",
})

lua54("yes")
use_experimental_fxv2_oal("yes")
nui_callback_strict_mode("true")

