function Video_chose{
    Clear-History
    Write-Host "�������� ��������� ��� ������`n"

    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "����� (*.mp4)|*.mp4"
    $openFileDialog.Title = "�������� ���������"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $inputFile = $openFileDialog.FileName
    } else {
        Write-Host "���� �� ������. �����...`n"
        pause
        exit
    }
    

    Clear-History
    Write-Host "�������� ����� ��� ����������`n"

    Add-Type -AssemblyName System.Windows.Forms

    # ������� ���������� ���� ��� ���������� �����
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "����� (*.mp4)|*.mp4"
    $saveFileDialog.Title = "�������� ����� ��� ���������� �����"
    $DesktopPath = $env:USERPROFILE + "\Desktop"
    $saveFileDialog.InitialDirectory = $DesktopPath

    # ���� ������������ ������ ���� � ����� "���������"
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputFile = $saveFileDialog.FileName
        Write-Host "��������� ���� ��� ���������� �����: $outputFile"
    } else {
        Write-Host "���� �� ������. �����...`n"
        pause
        exit
    }
    return @{inputFile = $inputFile; outputFile = $outputFile}
}



try {
    ffmpeg -h > $null 2>&1
}
catch {
    Write-Host "���� � ffmpeg �� ����������!"
    Write-Host "�������� ���� � ffmpeg.exe`n"


    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "ffmpeg (*.exe)|ffmpeg.exe"
    $openFileDialog.Title = "�������� ���� ffmpeg.exe"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ffmpegDir = [System.IO.Path]::GetDirectoryName($openFileDialog.FileName)
    } else {
        Write-Host "���� �� ������. �����...`n"
        pause
        exit
    }

    $PATH = [Environment]::GetEnvironmentVariable("PATH")
    [Environment]::SetEnvironmentVariable("PATH", "$PATH;$ffmpegDir", "Machine")
    $ffmpegDir = $ffmpegDir + "\ffmpeg.exe"


    $configFile = $PSScriptRoot + "\config.json"
    $config = Get-Content -Path $configFile | ConvertFrom-Json


    $result = Video_chose
    $inputFile = $result.inputFile
    $outputFile = $result.outputFile

    & $ffmpegDir -i "$inputFile" -c:v $($config.videoCodec) -preset $($config.preset) -b:v $($config.bitrateVideo) -c:a $($config.audioCodec) -b:a $($config.bitrateAudio) -movflags $($config.movflags) "$outputFile"

    Write-Host "`n`n`n`n������!"
    pause
    exit

}


# ������ ������������ �� �����
$configFile = $PSScriptRoot + "\config.json"
$config = Get-Content -Path $configFile | ConvertFrom-Json


$result = Video_chose
$inputFile = $result.inputFile
$outputFile = $result.outputFile

& ffmpeg -i "$inputFile" -c:v $($config.videoCodec) -preset $($config.preset) -b:v $($config.bitrateVideo) -c:a $($config.audioCodec) -b:a $($config.bitrateAudio) -movflags $($config.movflags) "$outputFile"
Write-Host "`n`n`n`n������!"
pause