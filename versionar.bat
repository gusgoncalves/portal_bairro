@echo off
if exist "%~dp0storage\versionamento.git\config" (
 git --git-dir="%~dp0storage\versionamento.git" --work-tree="%~dp0." %*
) else (
 git -C "%~dp0." %*
)
