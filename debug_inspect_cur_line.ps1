Add-Type -AssemblyName System.Drawing

$cur = [System.Drawing.Bitmap]::FromFile("C:\Users\CORE i7\.gemini\antigravity\brain\02f32bd2-18d1-4ceb-a44b-30d096678914\.user_uploaded\media_1793441720341_35b8af94.jpg")

# Search for the white/grey vertical line
for ($y = 200; $y -lt 650; $y += 20) {
    for ($x = 100; $x -lt 400; $x++) {
        $c = $cur.GetPixel($x, $y)
        # Check if white/grey line (R > 200, G > 200, B > 200)
        if ($c.R -gt 210 -and $c.G -gt 210 -and $c.B -gt 210) {
            # Check if surrounded by dark saree
            $left = $cur.GetPixel($x - 10, $y)
            $right = $cur.GetPixel($x + 10, $y)
            $isLeftSaree = ($left.G -gt 30 -and $left.R -lt 150)
            $isRightSaree = ($right.G -gt 30 -and $right.R -lt 150)
            if ($isLeftSaree -and $isRightSaree) {
                Write-Host "In media_1793441720341: White line at X=$x, Y=$y! Color: [$($c.R),$($c.G),$($c.B)]"
            }
        }
    }
}
$cur.Dispose()

