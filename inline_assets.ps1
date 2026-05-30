$rootDir = Get-Location
$htmlPath = Join-Path $rootDir "sakshi\index.html"
$outputPath = Join-Path $rootDir "sakshi\single-file.html"

if (-not (Test-Path $htmlPath)) {
    Write-Error "Could not find index.html at $htmlPath"
    exit 1
}

$html = Get-Content $htmlPath -Raw

# Function to inline CSS
$html = [regex]::Replace($html, '<link\s+[^>]*?rel=[''"]stylesheet[''"][^>]*?href=[''"](/[^''"]+?)(\?.*?)?[''"][^>]*?>', {
    param($match)
    $href = $match.Groups[1].Value
    $fullPath = Join-Path $rootDir $href.Replace('/', '\').TrimStart('\')
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        # Simple path adjustment for inlined CSS
        # If CSS was at /a/b/c.css and had url('d.png'), it's now at /sakshi/single-file.html
        # So it needs to be url('../a/b/d.png')
        $cssDir = [System.IO.Path]::GetDirectoryName($href).Replace('\', '/')
        if (-not $cssDir.EndsWith('/')) { $cssDir += '/' }
        
        # Adjust relative URLs in CSS
        $content = [regex]::Replace($content, 'url\([''"]?(?!data:|http:|https:|/)([^''")]+?)[''"]?\)', {
            param($m)
            $relPath = $m.Groups[1].Value
            $newPath = "../" + $cssDir.TrimStart('/') + $relPath
            return "url('$newPath')"
        })
        
        return "<style id='inlined-$href'>`n$content`n</style>"
    }
    return $match.Value
})

# Function to inline JS
$html = [regex]::Replace($html, '<script\s+[^>]*?src=[''"](/[^''"]+?)(\?.*?)?[''"][^>]*?></script>', {
    param($match)
    $src = $match.Groups[1].Value
    $fullPath = Join-Path $rootDir $src.Replace('/', '\').TrimStart('\')
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        return "<script id='inlined-$src'>`n$content`n</script>"
    }
    return $match.Value
})

# Update all remaining root-relative paths to relative paths
# e.g. /wp-content/ -> ../wp-content/
$html = $html.Replace('src="/wp-content/', 'src="../wp-content/')
$html = $html.Replace('href="/wp-content/', 'href="../wp-content/')
$html = $html.Replace('src="/wp-includes/', 'src="../wp-includes/')
$html = $html.Replace('href="/wp-includes/', 'href="../wp-includes/')
$html = $html.Replace('url(''/wp-content/', 'url(''../wp-content/')
$html = $html.Replace('url("/wp-content/', 'url("../wp-content/')

Set-Content $outputPath $html
Write-Host "Successfully created $outputPath"
