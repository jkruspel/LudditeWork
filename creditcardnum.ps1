# A program to ask for a credit card number and validate what type it is.
#
# Two questions for the program:
# Q1: Is this something my program can validate?
# Q2: If yes, what type of card is it?
#
# Card requirements:
# American Express: 15 digits and starts with 34 or 37
# MasterCard: 16 digits and starts with 51, 52, 53, 54, or 55
# Visa: 13 or 16 digits and starts with 4
#
# Luhn's algorithm:
# Start at the second-to-last digit and move left every other digit.
# Multiply each selected digit by 2.
# Add the individual digits of those products.
# Starting at the last digit, add the remaining alternating digits.
# Add both sums together.
# If the total is divisible by 10, the number passes Luhn's checksum.


# Ask the user for a number greater than 0.
do
{
    $card_number = [long](Read-Host "Enter a number you believe is a credit card")
}
while ($card_number -le 0)


# Determine the length of the card number.
$length = 0
$card_number_copy = $card_number

while ($card_number_copy -gt 0)
{
    $card_number_copy = [math]::Floor($card_number_copy / 10)
    $length++
}


# Start Luhn checksum algorithm.

# Make a copy so the original card number is preserved.
$card_number_copy2 = $card_number

# Remove the last digit so the second-to-last digit is now on the right.
$card_number_copy2 = [math]::Floor($card_number_copy2 / 10)

# Store the sum of the digits that are doubled.
$doubled_sum = 0

while ($card_number_copy2 -gt 0)
{
    $digit = ($card_number_copy2 % 10) * 2

    # If multiplying by 2 created a two-digit number,
    # add those two digits together.
    if ($digit -gt 9)
    {
        $digit = [math]::Floor($digit / 10) + ($digit % 10)
    }

    $doubled_sum += $digit

    # Move two digits to the left.
    $card_number_copy2 = [math]::Floor($card_number_copy2 / 100)
}


# Make another copy so the original card number is preserved.
$card_number_copy3 = $card_number

# Store the sum of the digits that are not doubled.
$regular_sum = 0

while ($card_number_copy3 -gt 0)
{
    $digit = $card_number_copy3 % 10

    $regular_sum += $digit

    # Move two digits to the left.
    $card_number_copy3 = [math]::Floor($card_number_copy3 / 100)
}


# Combine the two sums.
$total = $doubled_sum + $regular_sum


# Check if the sum is divisible by 10.
if ($total % 10 -ne 0)
{
    Write-Host "INVALID"
    exit
}


# Extract the first two digits from the original number.
$first_two_digits = $card_number

while ($first_two_digits -ge 100)
{
    $first_two_digits = [math]::Floor($first_two_digits / 10)
}


# Extract the first digit from the first two digits.
$first_digit = [math]::Floor($first_two_digits / 10)


# Identify the card type using the card length and starting digits.

# Visa cards start with 4 and have either 13 or 16 digits.
if (($length -eq 13 -or $length -eq 16) -and $first_digit -eq 4)
{
    Write-Host "VISA"
}

# American Express cards have 15 digits and start with 34 or 37.
elseif ($length -eq 15 -and ($first_two_digits -eq 34 -or $first_two_digits -eq 37))
{
    Write-Host "AMEX"
}

# MasterCard cards have 16 digits and start with 51, 52, 53, 54, or 55.
elseif ($length -eq 16 -and (
    $first_two_digits -eq 51 -or
    $first_two_digits -eq 52 -or
    $first_two_digits -eq 53 -or
    $first_two_digits -eq 54 -or
    $first_two_digits -eq 55))
{
    Write-Host "MASTERCARD"
}

# The number passed Luhn's checksum but does not match a supported card format.
else
{
    Write-Host "INVALID"
}