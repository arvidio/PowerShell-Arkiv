$folderPath = "C:\Users\97arer14\Downloads\IP_example_1"
$outputCSVPath = "C:\Users\97arer14\Downloads\File.csv"

# Initialize an empty array to store file information
$fileInfoArray = @()

foreach ($file in Get-ChildItem -Path $folderPath -File -Recurse) {
    $fileName = $file.FullName
    $fileSize = $file.Length
    $hashResult = Get-FileHash -Path $fileName -Algorithm SHA256
    $checksum = $hashResult.Hash.ToLower()

    # Create a hash table with file information
    $fileInfo = @{
        FileName       = $fileName
        FileSize       = $fileSize
        SHA256Checksum = $checksum
    }

    # Add the hash table to the array
    $fileInfoArray += New-Object PSObject -Property $fileInfo
}

# Export the array to a CSV file
$fileInfoArray | Export-Csv -Path $outputCSVPath -NoTypeInformation