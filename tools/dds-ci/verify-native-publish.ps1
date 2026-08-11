$ErrorActionPreference = 'Stop'

$appDir = Join-Path $PSScriptRoot '..\..\dds\artifacts\app'
$workerDir = Join-Path $PSScriptRoot '..\..\dds\artifacts\worker'
$appExe = Join-Path $appDir 'DokkaebiDocumentStudio.exe'
$pdfium = Join-Path $appDir 'pdfium.dll'
$workerExe = Join-Path $workerDir 'DokkaebiDocumentStudio.OfficeWorker.exe'
$smokeError = Join-Path $appDir 'release-smoke-error.txt'

Write-Host '--- DDS publish directory ---'
Get-ChildItem $appDir -File | Sort-Object Name | Select-Object Name,Length | Format-Table -AutoSize | Out-String | Write-Host
Write-Host '--- DDS worker directory ---'
Get-ChildItem $workerDir -File | Sort-Object Name | Select-Object Name,Length | Format-Table -AutoSize | Out-String | Write-Host

if (-not (Test-Path $appExe)) { throw "DDS executable missing after publish: $appExe" }
if (-not (Test-Path $pdfium)) { throw "pdfium.dll missing after publish: $pdfium" }
if (-not (Test-Path $workerExe)) { throw "Office worker missing after publish: $workerExe" }

Remove-Item $smokeError -Force -ErrorAction SilentlyContinue
$process = Start-Process -FilePath $appExe -ArgumentList '--release-smoke-test' -PassThru -Wait
Write-Host "DDS native smoke exit code: $($process.ExitCode)"
if ($process.ExitCode -ne 0) {
    if (Test-Path $smokeError) {
        Write-Host '--- DDS native smoke error ---'
        Get-Content $smokeError -Raw | Write-Host
    }
    throw "DDS PDFium smoke test failed: $($process.ExitCode)"
}

Write-Host 'DDS native publish smoke test passed.'
