# Summary
Returns relevant information about the latest membership change time and modification dates of relevant MECM deployment collections.  

Data is returned sorted such that the collection with the most recent membership change time is listed first.  

This is useful to quickly determine whether any deployment targeting (i.e. deployment collection memberships) have changed recently.  

# Usage
1. Download `Get-CMOrgModelLatestDeploymentChanges.psm1` to the appropriate subdirectory of your PowerShell [modules directory](https://github.com/engrit-illinois/how-to-install-a-custom-powershell-module).
2. Run it: `Get-CMOrgModelLatestDeploymentChanges`

# Parameters

### -Query
Optional string.  
Specifies a wildcard query that the named of collection must match in order to be returned.  
Default value is `UIUC-ENGR-*Deploy*`.  

### -Latest
Optional integer.  
Specifies how many collections to return from the "top" of the list.  
Default is `10`.  
Since the data is sorted by latest member change time, the default is to return the 10 collections with the most recent member change time.  

### -Quiet
Optional switch.  
Suppresses console output.  

### -SiteCode
Optional string.  
The site code of the MECM site to connect to.  
Default is `MP0`.  

### -Provider
Optional string.  
The SMS provider machine name.  
Default is `sccmcas.ad.uillinois.edu`.  

### -CMPSModulePath
Optional string.  
The path to the ConfigurationManager Powershell module installed on the local machine (as part of the admin console).  
Default is `$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1`.  

# Notes
- By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.