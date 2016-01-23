param( 
    [string] $CsvPath = 'C:\github\doerodney\NCAAB-D1M-2015-2016',

    [string] $Path = 'C:\github\doerodney\NCAAB-D1M-2015-2016\dataframe.csv'
)

$resultList = Get-ChildItem -Path $CsvPath -Include Results*.csv -Recurse | Sort-Object LastWriteTime

if (@($resultList).Count -gt 0) {
    # Get the header from the first file as the overall header.
    Get-Content -Path $resultList[0] | Select-Object -First 1 | Set-Content -Path $Path

    $resultList | ForEach-Object {
        Get-Content -Path $_ | Select-Object -Skip 1 | Add-Content -Path $Path
    }
}
