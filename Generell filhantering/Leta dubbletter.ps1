# Function to calculate checksum of a file
function Get-FileChecksum {
    param(
        [string]$filePath
    )

    $stream = New-Object System.IO.FileStream($filePath, [System.IO.FileMode]::Open)
    $hash = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256").ComputeHash($stream)
    $stream.Close()
    $checksum = [System.BitConverter]::ToString($hash) -replace '-'
    return $checksum
}

# Function to find duplicate files in a folder and its subfolders
function Find-DuplicateFiles {
    param(
        [string]$folderPath
    )

    $files = Get-ChildItem -Path $folderPath -Recurse -File

    $fileChecksums = @{}
    $duplicateFiles = @()

    foreach ($file in $files) {
        $checksum = Get-FileChecksum -filePath $file.FullName

        if ($fileChecksums.ContainsKey($checksum)) {
            $firstPath = $fileChecksums[$checksum]
            $secondPath = $file.FullName

            # Only add the duplicate if the second path is not the same as the first one
            if ($firstPath -ne $secondPath) {
                $duplicateFiles += [PSCustomObject]@{
                    FileName = $file.Name
                    FirstPath = $firstPath
                    SecondPath = $secondPath
                }
            }
        } else {
            $fileChecksums[$checksum] = $file.FullName
        }
    }

    return $duplicateFiles
}

# Specify the folder path to search for duplicates
$folderPath = "C:\Users\97arer14\Desktop\Kopia av Åke Södermans"

# Find duplicate files
$duplicates = Find-DuplicateFiles -folderPath $folderPath

# Output duplicate files
# Output duplicate files to a file
$duplicates | ForEach-Object {
    "$($_.FileName)`t$($_.FirstPath)`t$($_.SecondPath)"
} | out-file C:\users\97arer14\Documents\arvid.txt
