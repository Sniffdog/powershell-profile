<#
    .SYNOPSIS
    Custom PowerShell profile with some Unix like additions
#>


#region functions
function prompt {
    # Set prompt options
    $IndyFeedCurrentItem = Get-Content $PSScriptRoot\RSSFeed.txt
    $Host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $WeatherString + " ~ " + $IndyFeedCurrentItem
    $CurrentDir = Split-Path (Get-Location) -Leaf
    Write-Host "[$env:USERNAME] " -NoNewline -ForegroundColor Cyan
    "$CurrentDir>"
}


function New-RSSFeedCurrentItem {
    # Format RSS Item and store in temp file
    param(
        [parameter(mandatory=$true)]
        [string]$Item
    )
    $Item = $Item -replace "&apos;", "'"`
                  -replace "&lt;", "<"`
                  -replace "&gt;", ">"`
                  -replace "&quot;", '"'`
                  -replace "&amp;", "&"
    $Item | Out-File $PSScriptRoot\RSSFeed.txt
    $Item
}


function Set-ConsoleTheme {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'WindowsDefault')] 
        [switch]$WindowsDefault,

        [Parameter(Mandatory = $true, ParameterSetName = 'DarkTheme')]
        [switch]$DarkTheme
    )
    if ($DarkTheme) {
        # Set ColorTable04 (DarkRed)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable04' -Value '0x002b39c0' -Type DWord
        # Set ColorTable05 (DarkMagenta)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable05' -Value '0x00222222' -Type DWord
        $ItemProps = @{
            Path = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
            Name = "ColorTable05"
            Value = "0x00222222"
            Type = "DWord"
        }
        Set-ItemProperty @ItemProps
        # Set ColorTable06 (DarkYellow)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable06' -Value '0x00fc4f1' -Type DWord
        $ItemProps = @{
            Path = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
            Name = "ColorTable06"
            Value = "0x00fc4f1"
            Type = "DWord"
        }
        Set-ItemProperty @ItemProps
        # Set ColorTable11 (Cyan)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable11' -Value '0x00b98029' -Type DWord
    }
    if ($WindowsDefault) {
        # Set ColorTable04 (DarkRed)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable04' -Value '0x00000080' -Type DWord
        # Set ColorTable05 (DarkMagenta)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable05' -Value '0x00562401' -Type DWord
        $ItemProps = @{
            Path = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
            Name = "ColorTable05"
            Value = "0x00562401"
            Type = "DWord"
        }
        Set-ItemProperty @ItemProps
        # Set ColorTable06 (DarkYellow)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable06' -Value '0x00008080' -Type DWord
        $ItemProps = @{
            Path = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
            Name = "ColorTable06"
            Value = "0x00f0edee"
            Type = "DWord"
        }
        Set-ItemProperty @ItemProps
        # Set ColorTable11 (Cyan)
        Set-ItemProperty -Path HKCU:\Console -Name 'ColorTable11' -Value '0x00ffff00' -Type DWord
    }
}


function ls 
{
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
  $fore = $Host.UI.RawUI.ForegroundColor
  $ls_compressed = New-Object System.Text.RegularExpressions.Regex('\.(zip|tar|gz|rar)$', $regex_opts)
  $ls_executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|ps1|psm1|vbs|rb|reg|dll|o|lib)$', $regex_opts)
  $ls_source = New-Object System.Text.RegularExpressions.Regex('\.(py|pl|cs|rb|h|cpp)$', $regex_opts)
  $ls_text = New-Object System.Text.RegularExpressions.Regex('\.(txt|cfg|conf|ini|csv|log|xml)$', $regex_opts)
  Invoke-Expression ("Get-ChildItem $args") |
    %{
      if ($_.GetType().Name -eq 'DirectoryInfo') {
        $Host.UI.RawUI.ForegroundColor = 'DarkCyan'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($ls_compressed.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'DarkYellow'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($ls_executable.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'DarkRed'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($ls_text.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'DarkGreen'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } elseif ($ls_source.IsMatch($_.Name)) {
        $Host.UI.RawUI.ForegroundColor = 'DarkGray'
        $_
        $Host.UI.RawUI.ForegroundColor = $fore
      } else {
        $_
      }
    }
}
#endregion


$profileInitialDir = 'E:\Cher\Scripts'
$RSSUri = 'http://www.independent.co.uk/news/uk/rss'
$weatherCity = 'Salisbury'
$weatherCountry = 'UK'

# Set initial working directory
If (Test-Path $profileInitialDir)
{
    Set-Location $profileInitialDir
}

# Unregister PowerShell 'ls' alias as we have defined our own 'ls' function
Remove-Item alias:\ls

# Configure shell theme/size
$host.UI.RawUI.ForegroundColor = 'Gray'
$host.UI.RawUI.BackgroundColor = 'DarkMagenta'
$host.PrivateData.WarningForegroundColor = 'DarkYellow'
$host.PrivateData.ErrorForegroundColor = 'DarkRed'
$host.PrivateData.WarningBackgroundColor = 'DarkMagenta'
$host.PrivateData.ErrorBackgroundColor = 'DarkMagenta'
$hostBufferSize = $host.UI.RawUI.BufferSize
$hostBufferSize.Width = 150
$hostBufferSize.Height = 5000
$host.UI.RawUI.BufferSize = $hostBufferSize
$hostWindowSize = $host.UI.RawUI.WindowSize
$hostWindowSize.Width = 150
$hostWindowSize.Height = 40
$host.UI.RawUI.WindowSize = $hostWindowSize
Clear-Host

# Configure PSReadLine module.PSReadLine is installed by default in Windows 10. 
# On previous versions of Windows you need to install it from https://github.com/lzybkr/PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineOption -TokenKind Variable -ForegroundColor DarkRed
Set-PSReadlineOption -TokenKind Command -ForegroundColor DarkYellow

# Get weather information from Yahoo
$WeatherUri = ("https://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid in " +
               "(select woeid from geo.places(1) where text='{0}, {1}') and " +
               "u='c'&format=json&env=store://datatables.org/alltableswithkeys") -f $WeatherCity, $WeatherCountry
$WeatherData = Invoke-RestMethod -Uri $WeatherUri
$WeatherString = $WeatherData.query.results.channel.item.forecast | Where-Object {
    $_.date -eq (Get-Date).ToString('dd MMM yyyy')
}
$WeatherString = $WeatherString.high + "$([char]0x00B0) " + $WeatherString.text

# Get news feed from RSS url and display in Window title bar
$i = 0
Remove-Item -Path $PSScriptRoot\RSSFeed.* -Force
[xml]$RSS = Invoke-WebRequest -Uri $RSSUri
$RSS.rss.channel | Export-Clixml $PSScriptRoot\RSSFeed.xml
$RSSFeed = Import-Clixml $PSScriptRoot\RSSFeed.xml
$IndyFeedCurrentItem = New-RSSFeedCurrentItem $RSSFeed.Item[$i].title
$Host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $WeatherString + " ~ " + $IndyFeedCurrentItem
$i++

# Set background task to loop through remaining RSS feed items
$Timer = New-Object System.Timers.Timer
$Timer.Interval = 30000
$TimerAction = {
    if ($i -lt ($RSSFeed.Item.Count)) {
        $IndyFeedCurrentItem = New-RSSFeedCurrentItem $RSSFeed.Item[$i].title
        $Host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $WeatherString + " ~ " + $IndyFeedCurrentItem
        $i++
    } else {
        $i = 0
        Remove-Item -Path $PSScriptRoot\RSSFeed.* -Force
        [xml]$RSS = Invoke-WebRequest -Uri $RSSUri
        $RSS.rss.channel | Export-Clixml $PSScriptRoot\RSSFeed.xml
        $RSSFeed = Import-Clixml $PSScriptRoot\RSSFeed.xml
        $IndyFeedCurrentItem = New-RSSFeedCurrentItem $RSSFeed.Item[$i].title
        $Host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $WeatherString + " ~ " + $IndyFeedCurrentItem
        $i++
    }
}
$ObjectEventProps = @{
    InputObject = $Timer
    EventName = "Elapsed"
    SourceIdentifier = "RSSFeed"
    Action = $TimerAction
}
Register-ObjectEvent @ObjectEventProps | Out-Null
$Timer.Start()
