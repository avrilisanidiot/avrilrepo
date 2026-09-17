param()

$repo = Read-Host 'Enter remote repo HTTPS URL (e.g. https://github.com/USER/repo.git)'
$user = Read-Host 'GitHub username'
$securePat = Read-Host 'Personal Access Token (will be hidden)' -AsSecureString

# convert secure string to plain for this run only (kept in memory)
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePat)
$pat = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)

Write-Host "Initializing git and committing..."
if (-not (Test-Path .git)) { git init }
git add .
try { git commit -m "Initial commit: Electron WebRTC prototype" } catch { }

git branch -M main

# build remote URL with embedded credentials for this push only
$remoteWithCred = $repo -replace '^https://','https://' + $user + ':' + $pat + '@'

# ensure no token remains in remote config
try { git remote remove origin } catch { }
git remote add origin $remoteWithCred

Write-Host "Pushing to remote..."
git push -u origin main

# replace remote with the clean URL (remove token from git config)
git remote set-url origin $repo

Write-Host "Push complete. IMPORTANT: revoke the PAT you used if it was temporary: https://github.com/settings/tokens"