$raw = [Console]::In.ReadToEnd()
$Esc = [char]27

# Caveman badge — writes directly to Console, cannot be captured via pipeline
& "$env:USERPROFILE\.claude\hooks\caveman-statusline.ps1" 2>$null
$cavActive = (Test-Path "$env:USERPROFILE\.claude\.caveman-active")

# Model + effort — combined in one bracket
# Format "claude-sonnet-4-6" → "Sonnet 4.6"
$data = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
$modelRaw = if ($data.model -is [string]) { $data.model } else { $data.model.id }
if ($modelRaw -match 'claude-(\w+)-(\d+)-(\d+)') {
    $modelName = (Get-Culture).TextInfo.ToTitleCase($matches[1]) + ' ' + $matches[2] + '.' + $matches[3]
} else { $modelName = $modelRaw }

$settingsPath = "$env:USERPROFILE\.claude\settings.json"
$effort = ''
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    $effort = $settings.effortLevel
}

if ($modelName) {
    $sep = if ($cavActive) { ' ' } else { '' }
    $label = if ($effort) { "$modelName | $effort" } else { $modelName }
    [Console]::Write("${sep}${Esc}[38;5;75m[$label]${Esc}[0m")
}

# OS — map build number to human name
$osVer = [System.Environment]::OSVersion
$osBuild = $osVer.Version.Build
$osName = switch ($osVer.Platform) {
    'Win32NT' {
        if ($osBuild -ge 22000) { 'Windows 11' }
        elseif ($osBuild -ge 10240) { 'Windows 10' }
        elseif ($osBuild -ge 9200) { 'Windows 8' }
        else { 'Windows' }
    }
    'Unix' { (uname -s 2>$null) }
    default { $osVer.Platform }
}
if ($osName) { [Console]::Write(" ${Esc}[38;5;214m[$osName]${Esc}[0m") }
