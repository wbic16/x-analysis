param(
  [string] $file
)
if (-not (Test-Path $file)) {
  Write-Error "Usage: extract.ps1 <file>"
  exit(1)
}

# See phext.io for a full list - this is just the first 3 dimensions of phext!
$SCROLL_BREAK = [char]0x17
$SCROLL_BREAK = [char]0x18
$SCROLL_BREAK = [char]0x19

Write-Host "Processing $file..."
$data = Get-Content -raw $file
$data = ($data -replace "^window.YTD.tweets.part0 = ","") |ConvertFrom-Json

Write-Host "Records: $($data.Length)"

class tweet {
  [string] $created
  [string] $text

  [string] phext($id) {
    return "$($this.text) ($($this.created)) [$id]\x17";
  }
}

$phext = @()
$bytes = 0
$tweets = @{}
$last_month = ""
$last_year = ""
$scrolls = 1
$sections = 1
$chapters = 1
$years = @{}

foreach ($record in $data) {
  $id = $record.tweet.id
  $next = [tweet]::new()
  $next.text = $record.tweet.full_text
  $next.created = $record.tweet.created_at
  $tweets[$id] = $next
  
  $month = $next.created
  $month = $next.created -replace "^[^ ]* ","" -replace " .*$",""
  $year = $next.created -replace ".* (\d+)$","`$1"

  if (-not $years.ContainsKey($year)) {
    $years[$year] = @{}
  }
  $chapter = $years[$year]
  if (-not $chapter.ContainsKey($month)) {
    $chapter[$month] = @()
  }
  $chapter[$month] += $next.phext($id)
  $chapter[$month] += $SCROLL_BREAK
  ++$scrolls

  $bytes += $next.text.Length
}

$tweets |ConvertTo-Json |Out-File review.json
Write-Host "Streamlined $($tweets.Count) tweets with $bytes bytes of content into review.json."

$phext = @()
$sections = 1
$chapters = 1
foreach ($year in $years.Keys |Sort-Object) {
  foreach ($month in $years[$year].Keys |Sort-Object) {
    $phext += "" + $years[$year][$month] + $SECTION_BREAK
    ++$sections
  }
  $phext += $CHAPTER_BREAK
  ++$chapters
}

$phext |Out-File review.phext
Write-Host "Summarized a phext with $scrolls scrolls, $sections sections, and $chapters chapters into review.phext."