# Path to the XML file
$xmlFilePath = "C:\Users\97arer14\Downloads\199711146036_Jrnl1.xml"
# Path to the XSLT stylesheet
$xsltFilePath = "C:\Users\97arer14\Downloads\test.xslt"
# Path to the output HTML file
$htmlOutputPath = "C:\Users\97arer14\Downloads\output.html"

# Load XslCompiledTransform object with XSLT file
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xslt.Load($xsltFilePath)

# Create XmlWriter for HTML output
$htmlWriter = [System.Xml.XmlWriter]::Create($htmlOutputPath)

# Transform XML to HTML
$xmlReader = [System.Xml.XmlReader]::Create($xmlFilePath)
$xslt.Transform($xmlReader, $null, $htmlWriter)

# Close XmlWriter
$htmlWriter.Close()

# Output the result HTML file path
Write-Output "HTML file generated: $htmlOutputPath"
