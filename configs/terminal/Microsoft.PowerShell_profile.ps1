# ==============================================================================
#  envwin by Vetro - Aesthetic PowerShell Profile
# ==============================================================================

# Enable UTF-8 encoding by default
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# PSReadLine configuration (Smart history navigation)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    try {
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
    } catch {}
}

# Helpful quick aliases
Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue
Set-Alias -Name c -Value Clear-Host -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue

# Aesthetic Minimalist Prompt
function prompt {
    $time = Get-Date -Format 'HH:mm'
    $path = (Get-Location).Path
    $homeDir = $HOME
    if ($path.StartsWith($homeDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $path = '~' + $path.Substring($homeDir.Length)
    }

    $branch = ''
    try {
        $isGit = & git rev-parse --is-inside-work-tree 2>$null
        if ($isGit -eq 'true') {
            $currentBranch = & git branch --show-current 2>$null
            if ($currentBranch) {
                $branch = " ($currentBranch)"
            }
        }
    } catch {}

    Write-Host ''
    Write-Host "[$time] " -ForegroundColor DarkGray -NoNewline
    Write-Host "$path" -ForegroundColor Cyan -NoNewline
    if ($branch) {
        Write-Host "$branch" -ForegroundColor Magenta -NoNewline
    }
    Write-Host ''
    Write-Host '❯ ' -ForegroundColor DarkMagenta -NoNewline
    return ' '
}