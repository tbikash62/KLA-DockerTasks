# Function to calculate the nth Fibonacci number
function Get-Fibonacci {
    param (
        [int]$n
    )

    $a = 0
    $b = 1
    for ($i = 0; $i -lt $n; $i++) {
        Write-Host $a
        $temp = $a
        $a = $b
        $b = $temp + $b
        Start-Sleep -Seconds 0.5
    }
    return $a
}

# Check if an argument is passed, otherwise, print Fibonacci numbers continuously
if ($args.Count -eq 0) {
    $a = 0
    $b = 1
    while ($true) {
        Write-Host $a
        $temp = $a
        $a = $b
        $b = $temp + $b
        Start-Sleep -Seconds 0.5
    }
} else {
    # If argument is passed, print the nth Fibonacci number
    try {
        $n = [int]$args[0]
        Write-Host (Get-Fibonacci -n $n)
    } catch {
        Write-Host "Please provide a valid integer as an argument."
    }
}