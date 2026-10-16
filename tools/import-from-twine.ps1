# Sorts a Twine "Build > Export As Twee" file back into the src/*.twee files.
# Run it with import-from-twine.cmd. tools/import-from-twine.sh does the same on macOS.
#
# - Passages are matched by name. A changed passage is replaced in the file it already lives in.
# - Passages whose text and tags are unchanged are left exactly as they are (Twine-only position moves are ignored).
# - The stylesheet and script passages are matched by their tag, whatever Twine calls them.
# - StoryData is never changed.
# - New passages go to src/new-passages.twee. Passages missing from the export are removed.
# - src is backed up to .backup/ first, then the game is rebuilt.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$utf8 = New-Object System.Text.UTF8Encoding $false

function Wait-Key {
    Write-Host ''
    Write-Host 'Press any key to close this window.'
    try { [void][System.Console]::ReadKey($true) } catch { [void](Read-Host) }
}

function Read-Lines([string]$path) {
    $text = [System.IO.File]::ReadAllText($path, $utf8)
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    return ,($text.Replace("`r`n", "`n").Replace("`r", "`n").Split("`n"))
}

# Parses a ":: Name [tags] {metadata}" line. Returns $null if the line is not a passage header.
function Parse-Header([string]$line) {
    if (-not $line.StartsWith('::')) { return $null }
    $rest = $line.Substring(2)
    $name = New-Object System.Text.StringBuilder
    $i = 0
    while ($i -lt $rest.Length) {
        $c = $rest[$i]
        if ($c -eq '\' -and $i + 1 -lt $rest.Length) { [void]$name.Append($rest[$i + 1]); $i += 2; continue }
        if ($c -eq '[' -or $c -eq '{') { break }
        [void]$name.Append($c); $i++
    }
    $tags = ''
    $after = $rest.Substring($i)
    if ($after.StartsWith('[')) {
        $end = $after.IndexOf(']')
        if ($end -gt 0) { $tags = (($after.Substring(1, $end - 1).Trim() -split '\s+') | Where-Object { $_ }) -join ' ' }
    }
    return @{ Name = $name.ToString().Trim(); Tags = $tags }
}

# Splits lines into a preamble and passage blocks. Each block keeps its trailing empty lines as Gap,
# so unchanged passages are written back byte for byte.
function Parse-Twee([string[]]$lines) {
    $pre = New-Object System.Collections.ArrayList
    $blocks = New-Object System.Collections.ArrayList
    $cur = $null
    foreach ($line in $lines) {
        $h = Parse-Header $line
        if ($h) {
            $cur = @{ Header = $line; Name = $h.Name; Tags = $h.Tags; Body = (New-Object System.Collections.ArrayList); Gap = 0 }
            [void]$blocks.Add($cur)
        } elseif ($cur) { [void]$cur.Body.Add($line) }
        else { [void]$pre.Add($line) }
    }
    foreach ($b in $blocks) {
        while ($b.Body.Count -gt 0 -and $b.Body[$b.Body.Count - 1] -eq '') { $b.Body.RemoveAt($b.Body.Count - 1); $b.Gap++ }
    }
    return @{ Pre = $pre; Blocks = $blocks }
}

function Has-Tag($block, [string]$tag) { return (' ' + $block.Tags + ' ').Contains(' ' + $tag + ' ') }

function Special-Key($block) {
    if ($block.Name -eq 'StoryData') { return 'StoryData' }
    if (Has-Tag $block 'stylesheet') { return '#stylesheet' }
    if (Has-Tag $block 'script') { return '#script' }
    return $block.Name
}

function Write-Twee([string]$path, $doc) {
    $out = New-Object System.Collections.ArrayList
    foreach ($l in $doc.Pre) { [void]$out.Add($l) }
    foreach ($b in $doc.Blocks) {
        [void]$out.Add($b.Header)
        foreach ($l in $b.Body) { [void]$out.Add($l) }
        for ($k = 0; $k -lt $b.Gap; $k++) { [void]$out.Add('') }
    }
    [System.IO.File]::WriteAllText((Join-Path $root $path), ($out -join "`n"), $utf8)
}

try {
    # 1. Find the newest exported .twee file.
    $candidates = @(Get-ChildItem -Path $root -Filter *.twee -File)
    if (Test-Path (Join-Path $root 'twine-export')) { $candidates += @(Get-ChildItem -Path (Join-Path $root 'twine-export') -Filter *.twee -File) }
    if ($candidates.Count -eq 0) {
        Write-Host 'No Twine export found.'
        Write-Host ''
        Write-Host 'In Twine, open the story and choose Build > Export As Twee.'
        Write-Host "Save the file into this folder ($root), then double-click import-from-twine again."
        Wait-Key; exit 1
    }
    $export = $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "Importing $($export.Name)"
    Write-Host ''

    # 2. Read the export and the current src files.
    $exp = Parse-Twee (Read-Lines $export.FullName)
    $exported = @{}
    $exportOrder = New-Object System.Collections.ArrayList
    foreach ($b in $exp.Blocks) {
        $key = Special-Key $b
        if ($key -eq 'StoryData') { continue }
        if (-not $exported.ContainsKey($key)) {
            $exported[$key] = $b; [void]$exportOrder.Add($key)
        } elseif ($key.StartsWith('#')) {
            # Twine has one stylesheet and one script, but join them if there are more.
            $first = $exported[$key]
            [void]$first.Body.Add(''); foreach ($l in $b.Body) { [void]$first.Body.Add($l) }
        } else {
            Write-Host "Warning: the export has two passages named '$key'. Using the last one."
            $exported[$key] = $b
        }
    }

    $srcFiles = @(Get-ChildItem -Path (Join-Path $root 'src') -Filter *.twee -File -Recurse | Sort-Object FullName)
    $docs = [ordered]@{}
    $where = @{}
    $total = 0
    foreach ($f in $srcFiles) {
        $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
        $doc = Parse-Twee (Read-Lines $f.FullName)
        $docs[$rel] = $doc
        foreach ($b in $doc.Blocks) {
            $key = Special-Key $b
            if ($where.ContainsKey($key)) { Write-Host "Warning: '$key' is in both $($where[$key]) and $rel. Only the first is updated."; continue }
            $where[$key] = $rel; $total++
        }
    }

    # 3. Work out what changed.
    $updated = New-Object System.Collections.ArrayList
    $added = New-Object System.Collections.ArrayList
    $removed = New-Object System.Collections.ArrayList
    $changedFiles = @{}
    foreach ($rel in @($docs.Keys)) {
        $doc = $docs[$rel]
        $keep = New-Object System.Collections.ArrayList
        foreach ($b in $doc.Blocks) {
            $key = Special-Key $b
            if ($where[$key] -ne $rel) { [void]$keep.Add($b); continue }
            if (-not $exported.ContainsKey($key)) {
                # StoryData, StoryTitle, the stylesheet and the script are never removed.
                if ($key -eq 'StoryData' -or $key -eq 'StoryTitle' -or $key.StartsWith('#')) { [void]$keep.Add($b); continue }
                [void]$removed.Add("$key ($rel)")
                if ($keep.Count -gt 0) { $keep[$keep.Count - 1].Gap = $b.Gap }
                $changedFiles[$rel] = $true
                continue
            }
            $e = $exported[$key]
            if ((($e.Body -join "`n") -ne ($b.Body -join "`n")) -or ($e.Tags -ne $b.Tags -and -not $key.StartsWith('#'))) {
                if (-not $key.StartsWith('#')) { $b.Header = $e.Header; $b.Tags = $e.Tags }
                $b.Body = $e.Body
                [void]$updated.Add("$($b.Name) ($rel)")
                $changedFiles[$rel] = $true
            }
            [void]$keep.Add($b)
        }
        $doc.Blocks = $keep
    }

    $newRel = 'src/new-passages.twee'
    foreach ($key in $exportOrder) {
        if ($where.ContainsKey($key) -or $key.StartsWith('#')) { continue }
        if (-not $docs.Contains($newRel)) { $docs[$newRel] = @{ Pre = (New-Object System.Collections.ArrayList); Blocks = (New-Object System.Collections.ArrayList) } }
        $doc = $docs[$newRel]
        if ($doc.Blocks.Count -gt 0 -and $doc.Blocks[$doc.Blocks.Count - 1].Gap -lt 2) { $doc.Blocks[$doc.Blocks.Count - 1].Gap = 2 }
        $b = $exported[$key]; $b.Gap = 1
        [void]$doc.Blocks.Add($b)
        [void]$added.Add($key)
        $changedFiles[$newRel] = $true
    }

    # Guard against importing the wrong story.
    if ($removed.Count -gt 5 -and $removed.Count * 4 -gt $total) {
        Write-Host "Stopped: this would remove $($removed.Count) of $total passages, so the export is probably a different or older story."
        Write-Host 'Nothing was changed. Check that you exported the right story from Twine.'
        Wait-Key; exit 1
    }

    if ($changedFiles.Count -eq 0) {
        Write-Host 'No changes: the export matches the files in src.'
    } else {
        # 4. Back up src, then write the changed files.
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = Join-Path $root ".backup/src-$stamp"
        New-Item -ItemType Directory -Force (Join-Path $root '.backup') | Out-Null
        Copy-Item -Recurse (Join-Path $root 'src') $backup
        foreach ($rel in $changedFiles.Keys) { Write-Twee $rel $docs[$rel] }
        Write-Host "Backup of the old src folder: .backup/src-$stamp"
    }

    # 5. Move the export out of the way so it isn't imported twice.
    New-Item -ItemType Directory -Force (Join-Path $root '.backup') | Out-Null
    Move-Item $export.FullName (Join-Path $root (".backup/" + [IO.Path]::GetFileNameWithoutExtension($export.Name) + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.twee'))

    # 6. Rebuild so mistakes show up now.
    Write-Host ''
    Write-Host 'Building the game...'
    & "$root\build.cmd"
    $buildOk = ($LASTEXITCODE -eq 0)

    Write-Host ''
    Write-Host '----------------------------------------'
    Write-Host "$($updated.Count) passages updated"
    foreach ($n in $updated) { Write-Host "    $n" }
    Write-Host "$($added.Count) new passages added to $newRel"
    foreach ($n in $added) { Write-Host "    $n" }
    Write-Host "$($removed.Count) passages removed (they are not in the Twine export)"
    foreach ($n in $removed) { Write-Host "    $n" }
    Write-Host ''
    if ($buildOk) {
        Write-Host 'The game built without errors.'
        if ($changedFiles.Count -gt 0) { Write-Host 'Now commit in GitHub Desktop.' }
    } else {
        Write-Host 'The game did NOT build. The message above names the file and line to fix.'
        Write-Host 'Your old files are in the .backup folder if you need them.'
    }
    Wait-Key
    if ($buildOk) { exit 0 } else { exit 1 }
}
catch {
    Write-Host ''
    Write-Host "Something went wrong: $($_.Exception.Message)"
    Write-Host 'Nothing after this point was changed. Ask for help in the team chat.'
    Wait-Key; exit 1
}
