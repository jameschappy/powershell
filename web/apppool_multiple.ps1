Import-Module WebAdministration -ErrorAction SilentlyContinue
 
$pooltable = @{} 
  
$pools = gci iis:\apppools
$i = 0
 
Write-Host "Select Application Pool to Restart"
Write-Host ""
 
foreach ($a in $pools ){
    $pool = $a.Name
    $i += 1
    $pooltable.Add($i, $pool)
    Write-Host "$i – To restart app pool $pool"
}
 
Write-Host ""
$answer = read-host "Enter # of Application Pool to Restart "
 
if ($answer)
{
    foreach ($h in $pooltable.GetEnumerator()) {
        $key = $h.Name
        $val = $h.Value
        if ($key -eq $answer)
        {
            Write-Host "Restarting $val"
            Restart-WebAppPool $val
        }
    }
}
 
Write-Host "Complete" -ForegroundColor Magenta
Write-Host ""