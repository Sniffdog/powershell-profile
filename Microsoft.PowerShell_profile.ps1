#region globals
$profileInitialDir = 'E:\Cher\Scripts'
$weatherCity = "Salisbury"
$weatherCountry = "UK"
#endregion

#region functions
function prompt
{
    # Set prompt options
    $IndyFeedCurrentItem = Get-Content $PSScriptRoot\IndyFeed.txt
    $host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $IndyFeedCurrentItem
    $currentDir = Split-Path (Get-Location) -Leaf
    Write-Host "[$env:USERNAME] " -NoNewline -ForegroundColor Magenta
    "$currentDir>"
}

function New-IndyFeedCurrentItem
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
    $Item | Out-File $PSScriptRoot\IndyFeed.txt
    return $Item
}
#endregion

# Set initial working directory
If (Test-Path $profileInitialDir)
{
    Set-Location $profileInitialDir
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

# Get weather information from Yahoo
$uri = "https://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid in (select woeid from geo.places(1) where text='{0}, {1}')`
 and u='c'&format=json&env=store://datatables.org/alltableswithkeys"  -f $weatherCity, $weatherCountry
$data = Invoke-RestMethod -Uri  $uri
$weatherString = $data.query.results.channel.item.forecast | ?{$_.date -eq (Get-Date).ToString('dd MMM yyyy')}
$weatherString = $weatherString.high + "$([char]0x00B0) " + $weatherString.text

# Get news feed from Independent.co.uk
$i = 0
Remove-Item -Path $PSScriptRoot\IndyFeed.* -Force
[xml]$indyRSS = Invoke-WebRequest -Uri 'http://www.independent.co.uk/news/uk/rss'
$indyRSS.rss.channel | Export-Clixml $PSScriptRoot\IndyFeed.xml
$indyFeed = Import-Clixml $PSScriptRoot\IndyFeed.xml

# Set background task to loop through RSS feed
$timer = New-Object System.Timers.Timer
$timer.Interval = 30000
$timerAction = {
    If ($i -lt ($indyFeed.Item.Count))
    {
        $indyFeedCurrentItem = New-IndyFeedCurrentItem $indyFeed.Item[$i].title
        $host.UI.RawUI.WindowTitle = $PWD.Path + " ~ " + $weatherString + " ~ " + $indyFeedCurrentItem
        $i++
    }
}
Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier IndyFeed -Action $timerAction | Out-Null
$timer.Start()
