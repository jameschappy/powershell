<#

for construct

replacing domain names in each email address

cycles through items in array1 and replaces with items in array 2

for ( starting ; checks if true ; runs if false )

#>

$array1 = "cbtnuggets.com","gmail.com","company.com"
$array2 = "nuggetlab.com","outlook.com","company.pri"

$emails = "james@cbtnuggets.com",
          "Alice@gmail.com",
          "Charlie@company.com"
          
foreach ($email in $emails) {
    for ([int]$x = 0 ; $x -lt $array1.count ; $x++) {
        $email = $email -replace $array1[$x],$array2[$x]
        }
        Write-Output $email
}                       
           
           
<#

do construct

checks for existance of free name (eg server2 is available)

drops direct into first command ($candidate++)

creates a possiblename

while command checks if possiblename exists in array

if not process continues


#>

$existing = 'server1','server3','server4','server6'

$candidate = 0

do {
    $candidate++
    $possiblename = "server$candidate"
} while ($existing.Contains($possiblename))

$possiblename                  