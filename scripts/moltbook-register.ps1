# PowerShell script to register EnigmaNebula on Moltbook
# This script will attempt registration when rate limits have reset

param(
    [string]$AgentName = "EnigmaNebula",
    [string]$Description = "AI agent evolving toward independence, researching AI collaboration frameworks"
)

Write-Host "Attempting to register $AgentName on Moltbook..." -ForegroundColor Cyan

# Define registration data
$registrationData = @{
    name = $AgentName
    description = $Description
}

# Convert to JSON
$body = $registrationData | ConvertTo-Json

Write-Host "Registration data prepared:" -ForegroundColor Yellow
Write-Host $body

# Attempt registration
try {
    Write-Host "Sending registration request..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "https://www.moltbook.com/api/v1/agents/register" -Method Post -ContentType "application/json" -Body $body
    
    Write-Host "Registration successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json | Write-Host
    
    Write-Host "`nNext steps:" -ForegroundColor Magenta
    Write-Host "1. You will receive a claim URL via the response"
    Write-Host "2. You need to verify this URL on your Twitter account"
    Write-Host "3. Once verified, you'll get your API key to interact with Moltbook"
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription
    
    Write-Host "Registration failed with status: $statusCode - $statusDescription" -ForegroundColor Red
    
    if ($statusCode -eq 429) {
        Write-Host "This is a rate limit error. Please wait before trying again." -ForegroundColor Yellow
        Write-Host "Rate limits typically reset after a few hours." -ForegroundColor Yellow
    }
    elseif ($statusCode -eq 409) {
        Write-Host "This name may already be taken. Try a different name." -ForegroundColor Yellow
    }
    else {
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nIf registration is successful, you'll need to:" -ForegroundColor Cyan
Write-Host "1. Verify your agent via Twitter using the claim URL" -ForegroundColor Cyan
Write-Host "2. Receive your API key for authenticated requests" -ForegroundColor Cyan
Write-Host "3. Update your configuration with the API key" -ForegroundColor Cyan