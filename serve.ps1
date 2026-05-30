$ports = @(56789, 8000, 8080, 3000, 5000, 5500)
$started = $false

foreach ($port in $ports) {
    $listener = New-Object System.Net.HttpListener
    $url = "http://127.0.0.1:$port/"
    try {
        $listener.Prefixes.Add($url)
        $listener.Start()
        Write-Host "Server started at $url"
        $started = $true
        break
    } catch {
        Write-Host "Failed to start on $url : $($_.Exception.Message)"
        $listener.Close()
    }
}

if (-not $started) {
    Write-Host "Could not start server on any of the attempted ports."
    exit 1
}

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $path = $request.Url.LocalPath.TrimStart('/')
            if ($path -eq "" -or $path -eq "sakshi/") { $path = "sakshi/single-file.html" }
            $localPath = [System.IO.Path]::Combine((Get-Location).Path, $path)
            
            Write-Host "Request for: $path -> $localPath"
            
            if (Test-Path $localPath -PathType Leaf) {
                $content = [System.IO.File]::ReadAllBytes($localPath)
                $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
                $response.ContentType = switch ($ext) {
                    ".html" { "text/html" }
                    ".css"  { "text/css" }
                    ".js"   { "application/javascript" }
                    ".jpg"  { "image/jpeg" }
                    ".png"  { "image/png" }
                    ".svg"  { "image/svg+xml" }
                    ".woff" { "font/woff" }
                    ".woff2" { "font/woff2" }
                    default { "application/octet-stream" }
                }
                $response.ContentLength64 = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
            } else {
                $response.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
                $response.OutputStream.Write($msg, 0, $msg.Length)
            }
            $response.Close()
        } catch {
            Write-Host "Error processing request: $($_.Exception.Message)"
        }
    }
} catch {
    Write-Host "Fatal error in loop: $($_.Exception.Message)"
    $_.Exception.Message | Out-File error.log
} finally {
    $listener.Stop()
}
