@echo off
setlocal
cd /d "%~dp0"
where php >nul 2>nul
if errorlevel 1 (
  set "PATH=C:\xampp\php;%PATH%"
)
if not exist vendor\autoload.php (
  call composer install --no-dev --prefer-dist
  if errorlevel 1 goto erro
)
php spark portal:install
if errorlevel 1 goto erro
echo.
echo Portal: http://localhost:8080
echo Gestor: http://localhost:8080/gestor
echo Anunciante: http://localhost:8080/anunciantes
echo Master: http://localhost:8080/admin
echo Acessos iniciais: writable\ACESSOS_LOCAIS.txt
echo.
php -d upload_max_filesize=5M -d post_max_size=20M -S localhost:8080 -t public public/router.php
exit /b
:erro
echo.
echo Nao foi possivel iniciar. Confira o MySQL do XAMPP e as configuracoes do arquivo .env.
pause
exit /b 1
