$ErrorActionPreference = 'Stop'

$project = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Dokkaebi.DocumentStudio.Native.csproj'
$main = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\MainWindow.xaml.cs'

if (-not (Test-Path $project)) { throw "DDS project not found: $project" }
if (-not (Test-Path $main)) { throw "DDS MainWindow source not found: $main" }

$projectText = [IO.File]::ReadAllText($project)
$projectText = [Regex]::Replace($projectText, '(?m)^\s*<UseWindowsForms>true</UseWindowsForms>\s*\r?\n', '')
[IO.File]::WriteAllText($project, $projectText)

$mainText = [IO.File]::ReadAllText($main)
$mainText = $mainText.Replace('var d = new System.Windows.Forms.FolderBrowserDialog { Description = "Choose a folder for page images", UseDescriptionForTitle = true };', 'var d = new OpenFolderDialog { Title = "Choose a folder for page images" };')
$mainText = $mainText.Replace('if (d.ShowDialog() != System.Windows.Forms.DialogResult.OK) return;', 'if (d.ShowDialog(this) != true) return;')
$mainText = $mainText.Replace('PdfExportService.ExportAllPagesPng(_active.Document, d.SelectedPath)', 'PdfExportService.ExportAllPagesPng(_active.Document, d.FolderName)')
[IO.File]::WriteAllText($main, $mainText)

$remaining = Select-String -Path $project,$main -Pattern 'UseWindowsForms|System\.Windows\.Forms|FolderBrowserDialog'
if ($remaining) { throw "WinForms dependency remained after WPF patch: $($remaining -join '; ')" }

Write-Host 'Applied DDS WPF-only compile fix.'
