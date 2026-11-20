# LYFTA Workout Export
# Gets my latest workout from the LYFTA API and creates a Markdown file
# that can be provided to Copilot as workout context.

Write-Host "LYFTA Workout Export"
Write-Host "Starting..."

# Read the bearer token from a local file.
# lyfta-token.txt must be excluded from Git through .gitignore.
$token = (Get-Content ".\lyfta-token.txt" -Raw).Trim()

# Build the authorization header required by LYFTA.
$headers = @{
    Authorization = "Bearer $token"
}


# Call the LYFTA workouts API and store the returned data in $response.
$response = Invoke-RestMethod -Uri "https://my.lyfta.app/api/v1/workouts" -Method Get -Headers $headers

# LYFTA returns multiple workouts.
# Sort them by workout date, newest first, and select the latest workout.
$latestWorkout = $response.workouts |
    Sort-Object workout_perform_date -Descending |
    Select-Object -First 1

# Start building the Markdown document.
# $lines is an array where each item becomes one line in the output file.
$lines = @()

# Add overall workout information.
$lines += "# Latest LYFTA Workout"
$lines += ""
$lines += "Workout: $($latestWorkout.title)"
$lines += "Date: $($latestWorkout.workout_perform_date)"
$lines += "Bodyweight: $($latestWorkout.body_weight) $($latestWorkout.weight_unit)"
$lines += "Total Volume: $([Math]::Round($latestWorkout.total_volume, 2)) $($latestWorkout.weight_unit)"
$lines += "Duration: $($latestWorkout.workout_duration)"
$lines += ""

# Go through every exercise in the latest workout.
foreach ($exercise in $latestWorkout.exercises) {

    # Add the exercise name as a Markdown heading.
    # LYFTA's API spells this property "excercise_name", so that spelling
    # needs to be preserved here.
    $lines += "## $($exercise.excercise_name)"

    # Go through every set recorded for the current exercise.
    foreach ($set in $exercise.sets) {

        # Remove unnecessary trailing decimals while preserving fractional
        # weights when they actually exist, such as 27.5 lb.
        $weight = [Math]::Round($set.weight, 2)

        # Add the set in a readable format for Copilot.
        $lines += "- $weight $($latestWorkout.weight_unit) x $($set.reps) reps"
    }

    # Add a blank line between exercises.
    $lines += ""
}

# Write the completed Markdown document to the local project folder.
# workout-context.md is excluded from Git through .gitignore because it
# contains generated workout data rather than source code.
$lines | Set-Content -Path ".\workout-context.md"

Write-Host "Created workout-context.md"
