param(
    [string]$SrcDir = "D:\studynotes\控制理论\控制工程基础\课件",
    [string]$OutDir = "D:\studynotes\控制理论\控制工程基础\_raw"
)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
Get-Process POWERPNT -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$app = New-Object -ComObject PowerPoint.Application
$files = Get-ChildItem "$SrcDir\*.ppt"

function Walk-Shapes($shapes, $lines) {
    foreach ($sh in $shapes) {
        try {
            if ($sh.Type -eq 6) {  # group
                Walk-Shapes $sh.GroupItems $lines
                continue
            }
            if ($sh.HasTextFrame) {
                $t = $sh.TextFrame.TextRange.Text
                if ($t -and $t.Trim()) { $lines += $t.Trim() }
            }
            # Tables
            if ($sh.HasTable) {
                $tbl = $sh.Table
                for ($r = 1; $r -le $tbl.Rows.Count; $r++) {
                    $cells = @()
                    for ($c = 1; $c -le $tbl.Columns.Count; $c++) {
                        $ct = $tbl.Cell($r, $c).Shape.TextFrame.TextRange.Text
                        if ($ct) { $cells += $ct.Trim() }
                    }
                    $lines += (($cells -join " | "))
                }
            }
        } catch {}
    }
}

foreach ($f in $files) {
    $pres = $app.Presentations.Open($f.FullName, $true, $false)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $sb = New-Object System.Text.StringBuilder
    $nSlides = $pres.Slides.Count
    for ($i = 1; $i -le $nSlides; $i++) {
        $slide = $pres.Slides.Item($i)
        $lines = @()
        Walk-Shapes $slide.Shapes $lines
        [void]$sb.AppendLine("===SLIDE $i===")
        foreach ($ln in $lines) {
            [void]$sb.AppendLine($ln)
        }
        # notes
        try {
            $noteShape = $slide.NotesPage.Shapes | Where-Object { $_.HasTextFrame -and $_.TextFrame.TextRange.Text.Trim() } | Select-Object -First 1
            if ($noteShape) {
                [void]$sb.AppendLine("[NOTES] " + $noteShape.TextFrame.TextRange.Text.Trim())
            }
        } catch {}
    }
    $outFile = Join-Path $OutDir ($name + ".txt")
    [System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.Encoding]::UTF8)
    Write-Output ("Wrote: " + $outFile)
    $pres.Close()
}
$app.Quit()
