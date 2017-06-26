#region globals
$profileInitialDir = 'E:\Cher\Scripts'
$RSSUri = 'http://www.independent.co.uk/news/uk/rss'
$weatherCity = 'Salisbury'
$weatherCountry = 'UK'
#endregion

#region functions
function prompt
{
    # Set prompt options
    $IndyFeedCurrentItem = Get-Content $PSScriptRoot\RSSFeed.txt
    $host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $IndyFeedCurrentItem
    $currentDir = Split-Path (Get-Location) -Leaf
    Write-Host "[$env:USERNAME] " -NoNewline -ForegroundColor Cyan
    "$currentDir>"
}

function New-RSSFeedCurrentItem
{
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
    return $Item
}

function Set-ConsoleTheme
{
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'WindowsDefault')] 
        [switch]$WindowsDefault,

        [Parameter(Mandatory = $true, ParameterSetName = 'DarkTheme')]
        [switch]$DarkTheme
    )
    If ($DarkTheme)
    {
        # Set ColorTable04 (DarkRed)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable04' -Value '0x002b39c0' -Type DWord
        # Set ColorTable05 (DarkMagenta)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable05' -Value '0x00222222' -Type DWord
        Set-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name 'ColorTable05' -Value '0x00222222' -Type DWord
        # Set ColorTable06 (DarkYellow)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable06' -Value '0x00fc4f1' -Type DWord
        Set-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name 'ColorTable06' -Value '0x00fc4f1' -Type DWord
        # Set ColorTable11 (Cyan)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable11' -Value '0x00b98029' -Type DWord
    }
    If ($WindowsDefault)
    {
        # Set ColorTable04 (DarkRed)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable04' -Value '0x00000080' -Type DWord
        # Set ColorTable05 (DarkMagenta)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable05' -Value '0x00800080' -Type DWord
        Set-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name 'ColorTable05' -Value '0x00562401' -Type DWord
        # Set ColorTable06 (DarkYellow)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable06' -Value '0x00008080' -Type DWord
        Set-ItemProperty HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name 'ColorTable06' -Value '0x00f0edee' -Type DWord
        # Set ColorTable11 (Cyan)
        Set-ItemProperty HKCU:\Console -Name 'ColorTable11' -Value '0x00ffff00' -Type DWord
    }
}

function ls {
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
  $fore = $Host.UI.RawUI.ForegroundColor
  $ls_compressed = New-Object System.Text.RegularExpressions.Regex('\.(zip|tar|gz|rar)$', $regex_opts)
  $ls_executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|ps1|psm1|vbs|rb|reg|dll|o|lib)$', $regex_opts)
  $ls_source = New-Object System.Text.RegularExpressions.Regex('\.(py|pl|cs|rb|h|cpp)$', $regex_opts)
  $ls_text = New-Object System.Text.RegularExpressions.Regex('\.(txt|cfg|conf|ini|csv|log|xml)$', $regex_opts)

  Invoke-Expression ("Get-ChildItem $args") |
    %{
      if ($_.GetType().Name -eq 'DirectoryInfo') {
        $fore = 'Cyan'
      } elseif ($ls_compressed.IsMatch($_.Name)) {
        $fore = 'DarkYellow'
      } elseif ($ls_executable.IsMatch($_.Name)) {
        $fore = 'DarkRed'
      } elseif ($ls_text.IsMatch($_.Name)) {
        $fore = 'DarkGreen'
      } elseif ($ls_source.IsMatch($_.Name)) {
        $fore = 'DarkGray'
      } else {
        $fore = 'DarkMagenta'
      }
      $_ | Out-String -Stream | Write-Host -ForegroundColor $fore
    }
}
#endregion

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
$uri = "https://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid in (select woeid from geo.places(1) where text='{0}, {1}')`
 and u='c'&format=json&env=store://datatables.org/alltableswithkeys"  -f $weatherCity, $weatherCountry
$data = Invoke-RestMethod -Uri  $uri
$weatherString = $data.query.results.channel.item.forecast | ?{$_.date -eq (Get-Date).ToString('dd MMM yyyy')}
$weatherString = $weatherString.high + "$([char]0x00B0) " + $weatherString.text

# Get news feed from RSS url
$i = 0
Remove-Item -Path $PSScriptRoot\RSSFeed.* -Force
[xml]$RSS = Invoke-WebRequest -Uri $RSSUri
$RSS.rss.channel | Export-Clixml $PSScriptRoot\RSSFeed.xml
$RSSFeed = Import-Clixml $PSScriptRoot\RSSFeed.xml

# Set background task to loop through RSS feed
$timer = New-Object System.Timers.Timer
$timer.Interval = 30000
$timerAction = {
    If ($i -lt ($RSSFeed.Item.Count))
    {
        $indyFeedCurrentItem = New-RSSFeedCurrentItem $RSSFeed.Item[$i].title
        $host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $indyFeedCurrentItem
        $i++
    }
}
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier RSSFeed -Action $timerAction | Out-Null
$timer.Start()

Write-Host "Hello $env:USERNAME!"
