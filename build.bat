@echo off
REM Build script for Space Game

SET ML64=ml64.exe
SET LINKER=link.exe

REM Assemble all source files
@echo on
@echo Assembling data.asm...
%ML64% /c /Fo"obj\data.obj" src\data.asm
if errorlevel 1 goto error

@echo Assembling callbacks.asm...
%ML64% /c /Fo"obj\callbacks.obj" src\callbacks.asm
if errorlevel 1 goto error

@echo Assembling parallel.asm...
%ML64% /c /Fo"obj\parallel.obj" src\parallel.asm
if errorlevel 1 goto error

@echo Assembling main.asm...
%ML64% /c /Fo"obj\main.obj" src\main.asm
if errorlevel 1 goto error

@REM Link all object files
@echo Linking...
@set LINK=
%LINKER% /SUBSYSTEM:EFI_APPLICATION /ENTRY:EFI_MAIN  /MACHINE:X64 ^
    obj\data.obj obj\callbacks.obj obj\parallel.obj obj\main.obj ^
    /OUT:SpaceGame.efi

if errorlevel 1 goto error

@echo Build successful!
@goto end

:error
@echo Build failed!
@exit /b 1

:end
