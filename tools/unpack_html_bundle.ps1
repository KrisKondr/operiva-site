param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [Parameter(Mandatory = $true)]
  [string]$Output,
  [Parameter(Mandatory = $true)]
  [string]$AssetDirectory,
  [Parameter(Mandatory = $true)]
  [string]$AssetUrlPrefix
)

$ErrorActionPreference = 'Stop'

function Get-ScriptPayload([string]$Html, [string]$Type) {
  $pattern = '(?s)<script type="' + [regex]::Escape($Type) + '">\s*(.*?)\s*</script>'
  $match = [regex]::Match($Html, $pattern)
  if (-not $match.Success) {
    throw "Bundle payload '$Type' was not found."
  }
  return $match.Groups[1].Value
}

function Get-Extension([string]$Mime) {
  switch ($Mime.ToLowerInvariant()) {
    'text/javascript' { return '.js' }
    'application/javascript' { return '.js' }
    'font/woff2' { return '.woff2' }
    'image/png' { return '.png' }
    'image/jpeg' { return '.jpg' }
    'image/svg+xml' { return '.svg' }
    'application/wasm' { return '.wasm' }
    default { return '.bin' }
  }
}

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$raw = [IO.File]::ReadAllText($sourcePath)
$template = Get-ScriptPayload $raw '__bundler/template' | ConvertFrom-Json
$manifest = Get-ScriptPayload $raw '__bundler/manifest' | ConvertFrom-Json
$externalResources = Get-ScriptPayload $raw '__bundler/ext_resources' | ConvertFrom-Json

[IO.Directory]::CreateDirectory($AssetDirectory) | Out-Null
$assetUrls = @{}

foreach ($property in $manifest.PSObject.Properties) {
  $uuid = $property.Name
  $entry = $property.Value
  $extension = Get-Extension $entry.mime
  $filename = $uuid + $extension
  $destination = Join-Path $AssetDirectory $filename
  $bytes = [Convert]::FromBase64String($entry.data)

  if ($entry.compressed) {
    $input = [IO.MemoryStream]::new($bytes)
    $gzip = [IO.Compression.GZipStream]::new($input, [IO.Compression.CompressionMode]::Decompress)
    $outputStream = [IO.MemoryStream]::new()
    $gzip.CopyTo($outputStream)
    $gzip.Dispose()
    $input.Dispose()
    $bytes = $outputStream.ToArray()
    $outputStream.Dispose()
  }

  [IO.File]::WriteAllBytes($destination, $bytes)
  $url = $AssetUrlPrefix.TrimEnd('/') + '/' + $filename
  $assetUrls[$uuid] = $url
  $template = $template.Replace($uuid, $url)
}

$resourceMap = [ordered]@{}
foreach ($resource in $externalResources) {
  if ($assetUrls.ContainsKey($resource.uuid)) {
    $resourceMap[$resource.id] = $assetUrls[$resource.uuid]
  }
}

$resourceJson = $resourceMap | ConvertTo-Json -Compress
$resourceScript = '<script>window.__resources = ' + $resourceJson + ';</script>'
$template = [regex]::Replace(
  $template,
  '(?i)<head[^>]*>',
  { param($match) $match.Value + "`r`n" + $resourceScript },
  1
)

$outputDirectory = Split-Path -Parent $Output
if ($outputDirectory) {
  [IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}
[IO.File]::WriteAllText($Output, $template, [Text.UTF8Encoding]::new($false))

Write-Output "Created $Output"
Write-Output "Extracted $($assetUrls.Count) assets to $AssetDirectory"
