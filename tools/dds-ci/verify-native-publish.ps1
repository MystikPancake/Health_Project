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

Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class DdsNativeProbe {
  [DllImport("kernel32", SetLastError=true, CharSet=CharSet.Unicode)]
  public static extern IntPtr LoadLibraryW(string path);
  [DllImport("kernel32", SetLastError=true, CharSet=CharSet.Ansi)]
  public static extern IntPtr GetProcAddress(IntPtr module, string name);
  [DllImport("kernel32", SetLastError=true)]
  [return: MarshalAs(UnmanagedType.Bool)]
  public static extern bool FreeLibrary(IntPtr module);
}
'@

Write-Host '--- PDFium native load probe ---'
$module = [DdsNativeProbe]::LoadLibraryW($pdfium)
if ($module -eq [IntPtr]::Zero) {
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    throw "Windows LoadLibrary failed for pdfium.dll. Win32 error: $err"
}
try {
    foreach ($export in @('FPDF_InitLibrary','FPDF_DestroyLibrary','FPDF_SetSandBoxPolicy','FPDF_LoadDocument','FPDF_RenderPageBitmap')) {
        $ptr = [DdsNativeProbe]::GetProcAddress($module, $export)
        Write-Host "$export => $ptr"
        if ($ptr -eq [IntPtr]::Zero) { throw "Required PDFium export missing: $export" }
    }
} finally {
    [void][DdsNativeProbe]::FreeLibrary($module)
}
Write-Host 'PDFium LoadLibrary/export probe passed.'

Remove-Item $smokeError -Force -ErrorAction SilentlyContinue
$process = Start-Process -FilePath $appExe -ArgumentList '--release-smoke-test' -PassThru
if (-not $process.WaitForExit(15000)) {
    try { $process.Kill() } catch { }
    throw 'DDS --release-smoke-test did not exit within 15 seconds.'
}
Write-Host "DDS native smoke exit code: $($process.ExitCode)"
if ($process.ExitCode -ne 0) {
    if (Test-Path $smokeError) {
        Write-Host '--- DDS native smoke error ---'
        Get-Content $smokeError -Raw | Write-Host
    }
    throw "DDS PDFium smoke test failed: $($process.ExitCode)"
}

Write-Host 'DDS native publish smoke test passed.'
