$path = $('.\'+'Decimate')
if($(Test-Path $path) -ne $true){New-Item -Path $path -ItemType Directory}
else
{
    $files = (Get-ChildItem -Path $path)
    foreach($var in $files)
    {
        $ogName = $var.Name
        $tempName = ($var.BaseName + ".temp" + $var.Extension)
        $framerate = -1
        # ffprobe returns framerate as a String representing fraction rather than a number('240/1' instead of 240)
        # we split the string to later perform a division to get the number
        $fr = $(ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate $var.FullName).Split('/')
        # casting strings as ints
        $fr[0] = $fr[0] -as [int]
        $fr[1] = $fr[1] -as [int]
        # performing division to get actual framerate
        $framerate = $fr[0] / $fr[1]
        if($framerate -gt 0)
        {
            $fps = $framerate / 2
        }
        ffmpeg -i $var.FullName -c:v hevc_nvenc -c:a copy -preset losslesshp -tune lossless -level 0 -r $fps $($path+'\'+$tempName)
        $tempFile = Get-ChildItem $($path+'\'+$tempName)
        $tempFile.Length
        if($tempFile.Length -gt 0)
        {
            Remove-Item $var.FullName
            Rename-Item $($path+'\'+$tempName).Replace("[", "``[").replace("]", "``]") $ogName
        }
        else
        {
            Remove-Item $tempFile.FullName
        }
    }
}