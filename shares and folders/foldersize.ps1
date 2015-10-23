# requires -version 3.0

function get-foldersize2 {
[cmdletbinding()]

Param (
[Parameter(position=0)]
[ValidateScript({test-path $_})]
[string]$Path="."
)

Write-host "Analysing $Path"

Get-ChildItem -path $path -Directory | ForEach -Begin {
    #measure files in $path
    $stats = Get-ChildItem -Path $path -file |
    Measure-Object -Property Length -Sum

    if ($stats.Count -eq 0) {
    $size = 0
    }
    else {
        $size= $stats.sum / 1MB 
        } 

$root = Get-Item -path $Path

$hash = [ordered] @{
    Fullname = $root.fullname
    Name = $root.Name
    SizeMB = $size 
    Count = $stats.count
    }

New-Object -TypeName PSObject -Property $hash

} -process {

$stats = dir $_.fullname -File -Recurse |
Measure-Object -Property Length -Sum
 if ($stats.Count -eq 0) {
    $size = 0
    }
    else {
        $size=$stats.sum / 1MB 
        } 

$hash = [ordered] @{
    Fullname = $root.fullname
    Name = $root.Name
    SizeMB = $size
    Count = $stats.count
    }

New-Object -TypeName PSObject -Property $hash
}

}

  