$ErrorActionPreference = 'Stop'

$project = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Dokkaebi.DocumentStudio.Native.csproj'
$main = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\MainWindow.xaml.cs'
$controls = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Themes\Controls.xaml'
$models = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\Pdf\PdfModels.cs'
$tests = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native.Tests\Program.cs'
$app = Join-Path $PSScriptRoot '..\..\dds\src\Dokkaebi.DocumentStudio.Native\App.xaml.cs'

foreach ($required in @($project,$main,$controls,$models,$tests,$app)) {
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

$modelText = [IO.File]::ReadAllText($models)
$modelText = $modelText.Replace('public double Height => Math.Max(0, Bottom - Top);', 'public double Height => Math.Abs(Top - Bottom);')
$modelText = $modelText.Replace('public double Height => Math.Max(0, Top - Bottom);', 'public double Height => Math.Abs(Top - Bottom);')
[IO.File]::WriteAllText($models, $modelText)

$testText = [IO.File]::ReadAllText($tests)
$testText = $testText.Replace('var rect = PdfViewMath.PdfToView(new PdfRect(10, 80, 30, 100), 200, 2);', 'var rect = PdfViewMath.PdfToView(new PdfRect(10, 100, 30, 80), 200, 2);')
$testText = $testText.Replace('Near(20, rect.Left, "rectLeft"); Near(200, rect.Top, "rectTop");', 'Near(20, rect.Left, "rectLeft"); Near(200, rect.Top, "rectTop"); Near(40, rect.Height, "rectHeight");')
[IO.File]::WriteAllText($tests, $testText)

$appText = [IO.File]::ReadAllText($app)
if (-not $appText.Contains('using System.IO;')) { $appText = $appText.Replace('using System.Windows;', "using System.IO;`r`nusing System.Windows;") }
$oldCatch = @'
        catch (Exception ex)
        {
            MessageBox.Show($"Dokkaebi Document Studio could not initialize its native PDF engine.\n\n{ex.Message}", "DDS startup error", MessageBoxButton.OK, MessageBoxImage.Error);
            Shutdown(2);
        }
'@
$newCatch = @'
        catch (Exception ex)
        {
            if (e.Args.Any(arg => string.Equals(arg, "--release-smoke-test", StringComparison.OrdinalIgnoreCase)))
            {
                try { File.WriteAllText(Path.Combine(AppContext.BaseDirectory, "release-smoke-error.txt"), ex.ToString()); } catch { }
                Shutdown(2);
                return;
            }
            MessageBox.Show($"Dokkaebi Document Studio could not initialize its native PDF engine.\n\n{ex.Message}", "DDS startup error", MessageBoxButton.OK, MessageBoxImage.Error);
            Shutdown(2);
        }
'@
if ($appText.Contains($oldCatch.TrimStart("`r","`n"))) {
  $appText = $appText.Replace($oldCatch.TrimStart("`r","`n"), $newCatch.TrimStart("`r","`n"))
} elseif (-not $appText.Contains('release-smoke-error.txt')) {
  throw 'Expected DDS startup catch block was not found'
}
[IO.File]::WriteAllText($app, $appText)

$remaining = Select-String -Path $project,$main,$controls -Pattern 'UseWindowsForms|System\.Windows\.Forms|FolderBrowserDialog|new ExecutedRoutedEventArgs|CharacterSpacing'
if ($remaining) { throw "Legacy compile dependency remained after WPF patch: $($remaining -join '; ')" }
if (-not ([IO.File]::ReadAllText($models).Contains('Math.Abs(Top - Bottom)'))) { throw 'PDF rectangle height fix was not applied' }
if (-not ([IO.File]::ReadAllText($tests).Contains('new PdfRect(10, 100, 30, 80)'))) { throw 'PDF rectangle test fix was not applied' }
if (-not ([IO.File]::ReadAllText($app).Contains('release-smoke-error.txt'))) { throw 'Smoke diagnostics patch was not applied' }

Write-Host 'Applied DDS WPF compile, PDF geometry, and smoke diagnostics fixes.'
