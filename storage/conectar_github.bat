@echo off
setlocal
cd /d "%~dp0.."
set "GH_CONFIG_DIR=%CD%\storage\github-auth"
"%CD%\storage\tools\gh\gh.exe" auth status --hostname github.com >nul 2>&1
if errorlevel 1 (
 "%CD%\storage\tools\gh\gh.exe" auth login --hostname github.com --git-protocol https --web
 if errorlevel 1 goto falha
)
python "%CD%\storage\finalizar_github.py"
if errorlevel 1 goto falha
echo.
echo Repositorio privado criado e envio verificado.
pause
exit /b 0
:falha
echo.
echo Nao foi possivel concluir. Consulte a mensagem acima.
pause
exit /b 1
