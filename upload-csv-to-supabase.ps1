# Upload CSV to Supabase
$csvPath = "c:\download\correctted csv for lovable\hebrew_ready_assets\BIBLE_KNOWLEDGE ACUPUNCTURE POINTS BOOK^MPOINTS CATACORIES.csv"

$supabaseUrl = "https://iqfglrwjemogoycbzltt.supabase.co"
$supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8"

$headers = @{
    "Authorization" = "Bearer $supabaseKey"
    "apikey" = $supabaseKey
    "Content-Type" = "application/json"
    "Prefer" = "return=minimal"
}

# Import CSV
$csv = Import-Csv -Path $csvPath

Write-Host "Loading $($csv.Count) rows from CSV..." -ForegroundColor Cyan

# Upload in batches (500 rows at a time to avoid timeout)
$batchSize = 500
$totalUploaded = 0

for ($i = 0; $i -lt $csv.Count; $i += $batchSize) {
    $batch = $csv[$i..([Math]::Min($i + $batchSize - 1, $csv.Count - 1))]
    
    # Convert to array if single item
    if ($batch -isnot [array]) {
        $batch = @($batch)
    }
    
    # Convert to JSON with required fields
    $jsonArray = @()
    $batch | ForEach-Object {
        $jsonArray += @{
            content_en = $_.content_en
            content_he = $_.content_he
            source = $_.source
        }
    }
    $jsonData = ConvertTo-Json -InputObject $jsonArray
    
    $uri = "$supabaseUrl/rest/v1/dr_roni_bible"
    
    try {
        $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $jsonData -ErrorAction Stop
        $totalUploaded += $batch.Count
        Write-Host "✓ Uploaded rows $($i + 1) - $($i + $batch.Count) (Total: $totalUploaded)" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error uploading batch at row $i : $($_.Exception.Message)" -ForegroundColor Red
        Write-Host $_.Exception.Response.Content
        break
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

Write-Host "Upload complete! Total rows uploaded: $totalUploaded" -ForegroundColor Green
