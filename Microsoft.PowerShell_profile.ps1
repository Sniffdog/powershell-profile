function prompt
{
    # Set prompt options
    $host.UI.RawUI.WindowTitle = Get-Location
    $currentDir = Split-Path (Get-Location) -Leaf
    "[$env:USERNAME] $currentDir>"
}

# Configure shell theme/size
$host.UI.RawUI.ForegroundColor = "White"
$host.UI.RawUI.BackgroundColor = "Black"
$hostBufferSize = $host.UI.RawUI.BufferSize
$hostBufferSize.Width = 150
$hostBufferSize.Height = 5000
$host.UI.RawUI.BufferSize = $hostBufferSize
$hostWindowSize = $host.UI.RawUI.WindowSize
$hostWindowSize.Width = 150
$hostWindowSize.Height = 50
$host.UI.RawUI.WindowSize = $hostWindowSize
Clear-Host

# Configure unix style shell options with PSReadLine module.PSReadLine is installed by default in Windows 10. 
# On previous versions of Windows you need to install it from https://github.com/lzybkr/PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward

# Set initial working directory
Set-Location E:\Cher\Scripts