@echo off
set /p id="Enter filename: "
asm6 %id%.asm %id%.nes %id%.txt
pause