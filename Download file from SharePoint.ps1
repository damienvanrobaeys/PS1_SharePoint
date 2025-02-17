# SharePoint info
$Tenant = ""  # tenant name
$ClientID = "" # azure app client id 
$Secret = '' # azure app secret
$SharePoint_SiteID = ""  # sharepoint site id	
$SharePoint_Path = ""  # sharepoint main path
# Somethinhg like "https://systanddeploy.sharepoint.com/sites/Support/Documents%20partages"
$SharePoint_ExportFolder = ""  # folder where to upload file
# Something like "Windows/Logs"
$File_To_Download = ""
# Something like MyFile.csv
$FileName = $File_To_Download.Split("\")[-1]  

<#
To get the ID of a SharePoint site proceed as below:
1. Open your browser
2. Type the following URL: 
https://yoursharepoint.sharepoint.com/sites/yoursite/_api/site/id

In my case it's:
https://systanddeploy.sharepoint.com/sites/Support/_api/site/id
#>

$Body = @{  
	client_id = $ClientID
	client_secret = $Secret
	scope = "https://graph.microsoft.com/.default"   
	grant_type = 'client_credentials'  
}  
	
$Graph_Url = "https://login.microsoftonline.com/$($Tenant).onmicrosoft.com/oauth2/v2.0/token"  
$AuthorizationRequest = Invoke-RestMethod -Uri $Graph_Url -Method "Post" -Body $Body  

$Access_token = $AuthorizationRequest.Access_token  
$Header = @{  
	Authorization = $AuthorizationRequest.access_token  
	"Content-Type"= "application/json"  
	'Content-Range' = "bytes 0-$($fileLength-1)/$fileLength"	
}  

$SharePoint_Graph_URL = "https://graph.microsoft.com/v1.0/sites/$SharePoint_SiteID/drives"  
$BodyJSON = $Body | ConvertTo-Json -Compress  

$Result = Invoke-RestMethod -Uri $SharePoint_Graph_URL -Method 'GET' -Headers $Header -ContentType "application/json"   
$DriveID = $Result.value| Where-Object {$_.webURL -eq $SharePoint_Path } | Select-Object id -ExpandProperty id  
$FileName = $File_To_Download.Split("\")[-1]  
$fileurl = "https://graph.microsoft.com/v1.0/sites/$SharePoint_SiteID/drives/$DriveID/root:/$SharePoint_ExportFolder/$($fileName):/content"
$File_Path = "$env:temp\DiscoveredApps_Windows.csv"

Invoke-RestMethod -Headers $Header -Uri $fileurl -OutFile $File_Path		

