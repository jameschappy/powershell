############################################################################
#
#   Dirty script to RIP RA Mixes from MixCloud
#   Created by James Chapman 4-1-2015
#   Download function stolen from 'A Man on the Internet'
#   
#   RA Mix list available @ http://ra.co/500/ 
#
#   Script requires that you have disabled flash in IE (as you should!)
#
############################################################################

#Requires -Version 3.0 

function Download-File($url, $targetFile)

{
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count

    while ($count -gt 0) 
    {
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count

        Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    }

    Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}

$option = Read-Host "Please enter the mix number you require (eg '217') Or for all 500 mixes type 'all'"

if ($option -eq 'all'){

    $mixes = 1..500 | ForEach-Object {"http://www.residentadvisor.net/podcast-episode.aspx?id=$_"}

foreach ($mix in $mixes) {

### get url for MixCloud player Widget

        $ra = Invoke-WebRequest -Uri "$mix"
        $iframe = $ra.allelements | where {$_.innerhtml -like "<IFRAME*"}
        $title = ($ra.allelements | where {$_.innerhtml -like "RA.*"}).innerhtml
        $content = $iframe.innerHTML
        $content -match 'https.+"'

### Load widget in IE and click play to expose m4a url

        $url = $matches[0]
        $ie = New-Object -comobject InternetExplorer.Application
        $ie.visible = $true
        $ie.silent = $true
        $ie.Navigate( $url )
    
        while
            ($ie.busy){Start-Sleep 1} 
    
        $play = $ie.document.getElementsByclassname('widget-play-button')
    
        for 
            ($i=0; $i -lt $play.length; $i++) {$play[$i].click()}
        for 
            ($i=0; $i -lt $play.length; $i++) {$play[$i].click()}

        $source = $ie.Document.getElementsByTagName('source')
        $file = $source | select -exp src
        $localfile = "C:\RA\$title.mp3"

        get-process -processname iexplore | stop-process 

## Replace M4A Uri with Mp3

        $file = $file -replace "m4a$", "mp3"
        $file = $file -replace "m4a/64", "originals"
        write-host "New URI is $file" -Foregroundcolor Yellow

## Download the file

        Write-host "Downloading $title" -ForegroundColor Yellow
        download-file "$file" "$localfile"

}

}

else {

### get url for MixCloud player Widget

        $ra = Invoke-WebRequest -Uri "http://www.residentadvisor.net/podcast-episode.aspx?id=$option"
        $iframe = $ra.allelements | where {$_.innerhtml -like "<IFRAME*"}
        $title = ($ra.allelements | where {$_.innerhtml -like "RA.*"}).innerhtml
        $content = $iframe.innerHTML
        $content -match 'https.+"'

### Load widget in IE and click play to expose m4a url

        $url = $matches[0]
        $ie = New-Object -comobject InternetExplorer.Application
        $ie.visible = $true
        $ie.silent = $true
        $ie.Navigate( $url )
    
        while
            ($ie.busy){Start-Sleep 1} 
    
        $play = $ie.document.getElementsByclassname('widget-play-button')
    
        for 
            ($i=0; $i -lt $play.length; $i++) {$play[$i].click()}
        for 
            ($i=0; $i -lt $play.length; $i++) {$play[$i].click()}

        $source = $ie.Document.getElementsByTagName('source')
        $file = $source | select -exp src
        $localfile = "C:\RA\$title.mp3"

        get-process -processname iexplore | stop-process 

## Replace M4A Uri with Mp3

        $file = $file -replace "m4a$", "mp3"
        $file = $file -replace "m4a/64", "originals"
        write-host "New URI is $file" -Foregroundcolor Yellow

## Download the file

        Write-host "Downloading $title" -ForegroundColor Yellow
        download-file "$file" "$localfile"


}