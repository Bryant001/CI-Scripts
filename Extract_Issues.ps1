 # PowerShell script to output issues from SCA Agent scan to an XML file.
 # Extract the "Issues" section
iex ((New-Object System.Net.WebClient).DownloadString('https://download.srcclr.com/ci.ps1'))
$data = $(srcclr scan "C:\Users\jbryant\OneDrive - Veracode\Documents\Code\verademo\app" | Out-String)
$start = $data.IndexOf("Issues")
if ($start -ge 0) {
    $issues = $data.Substring($start)
    $lines = $issues -split "`n"

    # Create an XML document
    $xml = New-Object System.Xml.XmlDocument
    $root = $xml.CreateElement("Issues")
    $xml.AppendChild($root) | Out-Null

    # Process each line in the "Issues" section
    foreach ($line in $lines) {
        if ($line -match "^\d{9}") {
            $columns = $line -split "\s{2,}"
            $issue = $xml.CreateElement("Issue")

            $issueID = $xml.CreateElement("IssueID")
            $issueID.InnerText = $columns[0].Trim()
            $issue.AppendChild($issueID) | Out-Null

            $issueType = $xml.CreateElement("IssueType")
            $issueType.InnerText = $columns[1].Trim()
            $issue.AppendChild($issueType) | Out-Null

            $severity = $xml.CreateElement("Severity")
            $severity.InnerText = $columns[2].Trim()
            $issue.AppendChild($severity) | Out-Null

            $description = $xml.CreateElement("Description")
            $description.InnerText = $columns[3].Trim()
            $issue.AppendChild($description) | Out-Null

            $library = $xml.CreateElement("Library")
            $library.InnerText = $columns[4].Trim()
            $issue.AppendChild($library) | Out-Null

            $root.AppendChild($issue) | Out-Null
        }
    }

    # Save the XML document to a file
    $xml.Save("C:\Users\jbryant\OneDrive - Veracode\Documents\Code\srcclr_practice\Issues.xml")
    Write-Output "Issues section has been exported to Issues.xml"
} else {
    Write-Output "The 'Issues' section was not found in the provided data."
}
