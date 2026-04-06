$ErrorActionPreference = "Stop"

$symbolsDir = Join-Path $PSScriptRoot "..\\build\\release-symbols"
New-Item -ItemType Directory -Force -Path $symbolsDir | Out-Null

flutter build appbundle `
  --release `
  --obfuscate `
  --split-debug-info="$symbolsDir"
