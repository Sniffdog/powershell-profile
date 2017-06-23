function prompt
{
    # Set prompt options
    $IndyFeedCurrentItem = Get-Content $PSScriptRoot\IndyFeed.txt
    $host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $IndyFeedCurrentItem
    $currentDir = Split-Path (Get-Location) -Leaf
    "[$env:USERNAME] $currentDir>"
}

# Set initial working directory
Set-Location E:\Cher\Scripts

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

# Get weather information from Yahoo
$weatherCity = "Southampton"
$weatherCountry = "UK"
$URI = "https://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid in (select woeid from geo.places(1) where text='{0}, {1}')`
 and u='c'&format=json&env=store://datatables.org/alltableswithkeys"  -f $weatherCity, $weatherCountry

$Data = Invoke-RestMethod -Uri  $URI
$weatherString = $Data.query.results.channel.item.forecast | ?{$_.date -eq (Get-Date).ToString('dd MMM yyyy')}
$weatherString = $weatherString.high + "$([char]0x00B0) " + $weatherString.text

# Get news feed from Independent.co.uk
[xml]$IndyRSS = Invoke-WebRequest -Uri 'http://www.independent.co.uk/rss'
$IndyFeed = $IndyRSS.rss.channel
$Timer = New-Object System.Timers.Timer
$Timer.Interval = 30000
$TimerAction = {
    $i++
    If ($i -lt ($IndyFeed.Item.Count))
    {
        $IndyFeedCurrentItem = $IndyFeed.Item[$i].title
        $Host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $IndyFeedCurrentItem
        $IndyFeedCurrentItem | Out-File $PSScriptRoot\IndyFeed.txt
    }
}
Register-ObjectEvent -InputObject $Timer -EventName Elapsed -SourceIdentifier IndyFeed -Action $TimerAction | Out-Null
$Timer.Start()
