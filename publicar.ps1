# Publica esta carpeta en https://github.com/lukasmk257/intercambiador-calor-webgl y activa GitHub Pages.
# Usa el token que Git Credential Manager guardo para lukasmk257 (no se imprime).
$ErrorActionPreference = 'Stop'
$user = 'lukasmk257'
$repo = 'intercambiador-calor-webgl'
Set-Location $PSScriptRoot

# 1) Token guardado de lukasmk257
$cred = "protocol=https`nhost=github.com`nusername=$user`n`n" | git credential-manager get
$token = ($cred | Where-Object { $_ -like 'password=*' }) -replace '^password=', ''
if (-not $token) { throw "No hay credencial guardada para $user. Repite el login." }
$h = @{ Authorization = "Bearer $token"; 'User-Agent' = 'publicar-ps1'; Accept = 'application/vnd.github+json' }

# 2) Verifica que el token es de lukasmk257
$me = Invoke-RestMethod https://api.github.com/user -Headers $h
if ($me.login -ne $user) { throw "El token pertenece a $($me.login), no a $user." }

# 3) Crea el repo publico (si ya existe, lo reutiliza)
try {
  Invoke-RestMethod https://api.github.com/user/repos -Method Post -Headers $h `
    -Body (@{ name = $repo; description = 'Intercambiador de calor 3D (Unity WebGL) para systeme.io'; private = $false } | ConvertTo-Json) | Out-Null
  Write-Host 'Repo creado.'
} catch { Write-Host 'El repo ya existe o no se pudo crear: se continua.' }

# 4) Commit local y push (usa la credencial de lukasmk257)
if (-not (Test-Path .git)) { git init -q -b main }
git add -A
git -c user.name='Luis Marroquin' -c user.email='lc.marroquin25@gmail.com' commit -q -m 'Build WebGL 2 parcheado, snippet para systeme.io y demo'
if (git remote) { git remote remove origin }
git remote add origin "https://$user@github.com/$user/$repo.git"
git push -u origin main

# 5) Activa GitHub Pages desde main /
try {
  Invoke-RestMethod "https://api.github.com/repos/$user/$repo/pages" -Method Post -Headers $h `
    -Body (@{ source = @{ branch = 'main'; path = '/' } } | ConvertTo-Json) | Out-Null
} catch { Write-Host 'Pages ya estaba activo o hay que activarlo en Settings > Pages.' }

Write-Host ''
Write-Host "Demo (tarda 1-3 min en estar lista): https://$user.github.io/$repo/"
