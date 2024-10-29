function Connect-ToMECM {
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[string]$SiteCode,
		[string]$Provider,
		[string]$CMPSModulePath
	)

	log "Preparing connection to MECM..."
	$initParams = @{}
	if($null -eq (Get-Module ConfigurationManager)) {
		# The ConfigurationManager Powershell module switched filepaths at some point around CB 18##
		# So you may need to modify this to match your local environment
		Import-Module $CMPSModulePath @initParams -Scope Global
	}
	if(($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue))) {
		New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $Provider @initParams
	}
	Set-Location "$($SiteCode):\" @initParams
	log "Done prepping connection to MECM." -Verbose
}

function log {
	param(
		[string]$Msg,
		[int]$L,
		[switch]$Verbose,
		[string]$FC
	)
	
	if(-not $Quiet) {
		for($i = 0; $i -lt $L; $i += 1) {
			$Msg = "    $Msg"
		}
		
		if($Verbose) {
			Write-Verbose $Msg
		}
		else {
			$params = @{
				Object = $Msg
			}
			if($FC) { $params.ForegroundColor = $FC }
			
			Write-Host @params
		}
	}
}

function Get-Data {
	log "Getting all collection data. This may take a minute..."
	Get-CMDeviceCollection -Name $Prefix
}

function Select-Data($data) {
	log "Selecting and sorting relevant data..."
	$data = $data | Select Name,LastMemberChangeTime,LastRefreshTime,LastChangeTime,FullEvaluationMemberChanges,MemberCount,CollectionRules | Sort -Descending LastMemberChangeTime
	if($Latest -ge 1) {
		$data = $data | Select -First $Latest
	}
	$data
}

function Print-Data($data) {
	log "Printing relevant collection data (latest $Latest)..."
	Print-Latest $data
	if(-not $Quiet) {
		$data | Format-Table | Out-Host
	}
}

function Print-Latest($data) {
	$latest = $data | Select -First 1
	log "Latest membership change time is:" -L 1
	$latestTime = $latest.LastMemberChangeTime
	$latestName = $latest.Name
	log "Name: $latestName" -L 2 -FC "yellow"
	log "Membership changed: $latestTime" -L 2 -FC "yellow"
}

function Get-CMOrgModelLatestDeploymentChanges {

	[CmdletBinding()]
	param(
		[string]$Prefix = "UIUC-ENGR-*Deploy*",
		[string]$SiteCode = "MP0",
		[string]$Provider = "sccmcas.ad.uillinois.edu",
		[string]$CMPSModulePath = "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1",
		[int]$Latest = 10,
		[switch]$PassThru,
		[switch]$Quiet
	)

	begin {
		$myPWD = $PWD.Path
		Connect-ToMECM -SiteCode $SiteCode -Provider $Provider -CMPSModulePath $CMPSModulePath
	}

	process {
		$data = Get-Data
		$data = Select-Data $data
		Print-Data $data
		if($PassThru) {
			$data
		}
	}

	end {
		Set-Location $myPWD
		log "EOF" -Verbose
	}
}

Export-ModuleMember Get-CMOrgModelLatestDeploymentChanges