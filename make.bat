set PROJECT_BASE=.\
set RGBDS_PATH=%PROJECT_BASE%\Compile\rgbds-0.8.0-win64
set PATH=%RGBDS_PATH%
set ROM_NAME=codeVSart

:::::::::::::::::::::::::::
:: GB Pixel Art Jam 2025 ::
:::::::::::::::::::::::::::
rgbgfx.exe -b 0x80 -u -o gfx/picture_tiles.bin -t gfx/picture_map.bin gfx/picture.png

::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: B U I L D
::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Assemble the game into an object
rgbasm -o obj\%ROM_NAME%.o %ROM_NAME%.asm

:: Link the objects together and run rgbfix
rgblink -d -m %ROM_NAME%.map -o %ROM_NAME%.gb -n %ROM_NAME%.sym obj\%ROM_NAME%.o
rgbfix -m0x02 -l0x33 -t %ROM_NAME% -r 2 -n 0 -p 0xFF -fhg %ROM_NAME%.gb
:: -C = Game Boy Color–only
:: -c = Game Boy Color–compatible
::
:: -m0x02 = MBC1+RAM
:: -m0x03 = MBC1+RAM+BATTERY
:: -m0x13 = MBC3+RAM+BATTERY
:: -m0x1A = MBC5+RAM
:: -m0x1B = MBC5+RAM+BATTERY

