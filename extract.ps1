param(
  [string] $file
)
if (-not (Test-Path $file)) {
  Write-Error "Usage: extract.ps1 <file>"
  exit(1)
}

Write-Host "Processing $file..."
$data = Get-Content -raw $file
$data = ($data -replace "^window.YTD.tweets.part0 = ","") |ConvertFrom-Json

Write-Host "Records: $($data.Length)"

$retweets = 0

class tweet {
  [string] $created
  [string] $text
}

$bytes = 0
$tweets = @{}
foreach ($record in $data) {
  $id = $record.tweet.id
  $next = [tweet]::new()
  $next.text = $record.tweet.full_text
  $next.created = $record.tweet.created_at
  $tweets[$id] = $next
  $bytes += $next.text.Length
}

Write-Host "Streamlined $($tweets.Count) tweets with $bytes bytes of content into review.json."
$tweets |ConvertTo-Json |Out-File review.json