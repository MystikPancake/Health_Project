$ErrorActionPreference = 'Stop'

$project = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Dokkaebi.DocumentStudio.Native.csproj'
$main = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\MainWindow.xaml.cs'
$controls = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Themes\Controls.xaml'

foreach ($required in @($project,$main,$controls)) {
  if (-not (Test-Path $required)) { throw "DDS source not found: $required" }
}

$projectText = [IO.File]::ReadAllText($project)
$projectText = [Regex]::Replace($projectText, '(?m)^\s*<UseWindowsForms>true</UseWindowsForms>\s*\r?\n', '')
[IO.File]::WriteAllText($project, $projectText)

$mainText = [IO.File]::ReadAllText($main)
$mainText = $mainText.Replace('var d = new System.Windows.Forms.FolderBrowserDialog { Description = "Choose a folder for page images", UseDescriptionForTitle = true };', 'var d = new OpenFolderDialog { Title = "Choose a folder for page images" };')
$mainText = $mainText.Replace('if (d.ShowDialog() != System.Windows.Forms.DialogResult.OK) return;', 'if (d.ShowDialog(this) != true) return;')
$mainText = $mainText.Replace('PdfExportService.ExportAllPagesPng(_active.Document, d.SelectedPath)', 'PdfExportService.ExportAllPagesPng(_active.Document, d.FolderName)')
$mainText = $mainText.Replace('private void OpenFromHome() => OpenCommandExecuted(this, new ExecutedRoutedEventArgs(ApplicationCommands.Open, null));', 'private void OpenFromHome() => ApplicationCommands.Open.Execute(null, this);')
$mainText = $mainText.Replace('case "Open": OpenCommandExecuted(this, new ExecutedRoutedEventArgs(ApplicationCommands.Open, null)); break;', 'case "Open": ApplicationCommands.Open.Execute(null, this); break;')
$mainText = $mainText.Replace('case "Print": PrintCommandExecuted(this, new ExecutedRoutedEventArgs(ApplicationCommands.Print, null)); break;', 'case "Print": ApplicationCommands.Print.Execute(null, this); break;')
[IO.File]::WriteAllText($main, $mainText)

$controlsText = [IO.File]::ReadAllText($controls)
$controlsText = $controlsText.Replace('<Setter Property="CharacterSpacing" Value="60"/>', '')
[IO.File]::WriteAllText($controls, $controlsText)

$remaining = Select-String -Path $project,$main,$controls -Pattern 'UseWindowsForms|System\.Windows\.Forms|FolderBrowserDialog|new ExecutedRoutedEventArgs|CharacterSpacing'
if ($remaining) { throw "Legacy compile dependency remained after WPF patch: $($remaining -join '; ')" }

Write-Host 'Applied DDS WPF compile fixes.'
