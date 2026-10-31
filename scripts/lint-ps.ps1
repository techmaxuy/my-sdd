$evt  = [Console]::In.ReadToEnd() | ConvertFrom-Json
$file = $evt.tool_input.file_path
if (-not $file -or $file -notmatch '\.(ps1|psm1)$') { exit 0 }
if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) { exit 0 }
$issues = Invoke-ScriptAnalyzer -Path $file -Severity Error,Warning
if ($issues) {
  $issues | ForEach-Object { "[$($_.Severity)] $($_.RuleName) L$($_.Line): $($_.Message)" } | Out-String | Write-Error
  exit 2
}
exit 0