function Video_chose{
    Clear-History
    Write-Host "Выберите видеофайл для сжатия`n"

    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Видео (*.mp4)|*.mp4"
    $openFileDialog.Title = "Выберите видеофайл"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $inputFile = $openFileDialog.FileName
    } else {
        Write-Host "Файл не выбран. Выход...`n"
        pause
        exit
    }
    

    Clear-History
    Write-Host "Выберите место для сохранения`n"

    Add-Type -AssemblyName System.Windows.Forms

    # Создаем диалоговое окно для сохранения файла
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "Видео (*.mp4)|*.mp4"
    $saveFileDialog.Title = "Выберите место для сохранения файла"
    $DesktopPath = $env:USERPROFILE + "\Desktop"
    $saveFileDialog.InitialDirectory = $DesktopPath

    # Если пользователь выбрал файл и нажал "Сохранить"
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputFile = $saveFileDialog.FileName
        Write-Host "Выбранный путь для сохранения файла: $outputFile"
    } else {
        Write-Host "Файл не выбран. Выход...`n"
        pause
        exit
    }
    return @{inputFile = $inputFile; outputFile = $outputFile}
}



try {
    ffmpeg -h > $null 2>&1
}
catch {
    Write-Host "Путь к ffmpeg не установлен!"
    Write-Host "Выберите путь к ffmpeg.exe`n"


    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "ffmpeg (*.exe)|ffmpeg.exe"
    $openFileDialog.Title = "Выберите файл ffmpeg.exe"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ffmpegDir = [System.IO.Path]::GetDirectoryName($openFileDialog.FileName)
    } else {
        Write-Host "Файл не выбран. Выход...`n"
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

    Write-Host "`n`n`n`nГотово!"
    pause
    exit

}


# Чтение конфигурации из файла
$configFile = $PSScriptRoot + "\config.json"
$config = Get-Content -Path $configFile | ConvertFrom-Json


$result = Video_chose
$inputFile = $result.inputFile
$outputFile = $result.outputFile

& ffmpeg -i "$inputFile" -c:v $($config.videoCodec) -preset $($config.preset) -b:v $($config.bitrateVideo) -c:a $($config.audioCodec) -b:a $($config.bitrateAudio) -movflags $($config.movflags) "$outputFile"
Write-Host "`n`n`n`nГотово!"
pause