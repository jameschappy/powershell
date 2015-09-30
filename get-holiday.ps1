#requires -version 2.0

<#
This must be run from the PowerShell console. NOT in the ISE.

This is based on a script originally posted by The PowerShell Guy
http://thepowershellguy.com/blogs/posh/default.aspx
#>

Param(
[string]$Caption = "Happy Holidays"
)

#add the caption to the greeting line
$Greeting = "$([char]14) **$Caption** $([char]14)"

Clear-Host

Write-host "`n"
$Peek = " ^ "
$tree = "/|\"
$i = 20
$pos = $host.ui.rawui.CursorPosition

#adjust to center the display
$offset = ($host.ui.rawui.WindowSize.Width - 72)/2

Write-Host -ForegroundColor Red ($peek.PadLeft($i-1).PadRight(36) * 2)
Write-Host -ForegroundColor Green ($tree.PadLeft($i-1).PadRight(36) * 2)

1..16 | Foreach {
    #build out the tree
    $tree = $tree -replace "/(.*)\\",'//$1\\'
    Write-Host -ForegroundColor Green ($tree.PadLeft($i).PadRight(36) * 2)
    $i++
}

Write-Host -ForegroundColor Green ("|||".PadLeft(19).PadRight(36) *2)
Write-Host -ForegroundColor Green ("|||".PadLeft(19).PadRight(36) *2)

$rect = New-Object System.Management.Automation.Host.Rectangle
$rect.top = $pos.y
$rect.Right = 70
$rect.Bottom = $pos.y + 19
$buffer = $host.ui.rawui.getbuffercontents($rect)
#random number object
$R = New-Object System.Random
$ball = New-Object System.Management.Automation.Host.BufferCell
$ball.backgroundColor = $host.ui.rawui.BackgroundColor

1..150 | ForEach {
    #pause for a random number of milliseconds between 50 and 200
    sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 200)
    #get a random position
    $rx = $r.Next(19)
    $ry = $r.Next(70)

    #define a collection of figures to be used as ornaments
    $ornaments = '@','*','#',":","$"
    #get a random ornament
    $ball.Character = Get-Random $ornaments
    $ball.ForegroundColor = $r.next(16)

    if ($buffer[$rx,$ry].Character -eq '/') {$buffer[$rx,$ry] = $ball}
    if ($buffer[$rx,$ry].Character -eq '\') {$buffer[$rx,$ry] = $ball}
    $host.ui.rawui.SetBufferContents($pos,$buffer)
}

#write the greeting centered
$pos.y = $pos.y + 22
$pos.x = 36 - (($Greeting.Length)/2)
$host.ui.rawui.CursorPosition = $pos

Write-Host $Greeting -ForegroundColor Green -BackgroundColor Red

#add a couple blank lines
Write-Host "`n`n"