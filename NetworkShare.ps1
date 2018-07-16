#Requires -Version 5
#Requires -RunAsAdministrator


using module './CredentialBuilder.psm1'
using namespace System.Management.Automation;



enum Persistence
{
	Session
	LocalMachine
	Enterprise
}



class NetworkShareBuilder
{

	hidden [CredentialBuilder] $credBuilder
	hidden [PSCredential] $Credential
	
	hidden [HashTable] $networkShare
	
	[String] $Path
	[Persistence] $Persist = [Persistence]::Session
	
	
	NetworkShareBuilder()
	{
		$this.credBuilder = [CredentialBuilder]::new()
		$this.networkShare = [Hashtable]::new()
	}
	
	
#	
	
	
	[void] buildCredential()
	{
		$this.Credential = $this.credBuilder.setUser('BEBEE\mao').setEnteredPassword().Build()
	}
	
	
	[NetworkShareBuilder] setNetworkPath( [String] $Path )
	{
		$this.networkShare.Path  = $Path
		return $this
	}
	

	[NetworkShareBuilder] setPersistence( [Persistence] $Persist )
	{
		$this.networkShare.Persist = $Persist
		return $this
	}
	
	
	[NetworkShareBuilder] setNetworkPath()
	{
	
		return $this
	}
	
	
	[NetworkShareBuilder] setNetworkPath()
	{
	
		return $this
	}
	
	
	hidden static [PSCredential] newCredentials([String] $UserName) 
	{
		return [PSCredential]::new( 
			[PSCustomObject] @{ UserName = $UserName } 
		)
	}
	
	
	hidden static [Boolean] isCredentialComplete([PSCredential] $Credentials)
	{
		return -not (
			$Credentials.Equals( [PsCredential]::Empty ) -or
			[String]::IsNullOrWhiteSpace( $Credentials.UserName ) -or
			$Credentials.Password -eq $null
		)
	}
	
	
	
	# Constructor (basic)
	NetworkShare ([String] $Path)
	{
		$this.Path = $Path
	}
	
	
	NetworkShare ([String] $Path, [Persistence] $Persist)
	{
		$this.Path = $Path
		$this.Persist = $Persist
	}
	

	NetworkShare ([String] $Path, [Persistence] $Persist, [String] $UserName)
	{
		$this.Path = $Path
		$this.Persist = $Persist
		$this.Credentials = [NetworkShare]::newCredentials( $UserName )
	}


	NetworkShare ([String] $Path, [PsCredential] $Credentials)
	{
		$this.Path = $Path
		$this.Credentials = $Credentials
	}
	
	
	# Constructor with fully provided credentials
	NetworkShare ([String] $Path, [Persistence] $Persist, [PsCredential] $Credentials)
	{
		$this.Path = $Path
		$this.Persist = $Persist
		$this.Credentials = $Credentials
	}
	
	
	
	#
	# Usage:
	#    $creds = 	[NetworkShare]::new('\\server\share'), 
	#				[NetworkShare]::new('\\server\Downloads', 'DOMAIN\operator')
	#    $creds | ForEach-Object { $_.ensureCredentials() }
	#
	[void] requestCredentials()
	{
		if ( [NetworkShare]::isCredentialComplete($this.Credentials) ) {
			return
		}
	
		if ( [String]::IsNullOrWhiteSpace($this.Credentials.UserName) ) {
			$this.setCredentials( Get-Credential -Message "$($this.Path) :: Enter user name and password" )
		} 
		else
		{
			$this.setCredentials( Get-Credential -UserName $this.Credentials.UserName -Message '$($this.Path) :: Please enter the password' )
		}
	}
	
	
	[void] setCredentials([PSCredential] $Credentials)
	{
		$this.Credentials = $Credentials
	}
	
	
	
	[void] saveCredential( [String] $Persist )
	{
		try
		{ 
			[void]( New-StoredCredential -Target $this.Path -Persist $Persist -Credentials $this.Credential )
		}
		catch
		{
			Write-Host ("Cannot save credentials for `n  target:{0} `n  user:{1}" -f $this.Path, $this.Credential.UserName)
		}
	}
	
}



<#
@{ host='dns323'; 	user='mao' },
@{ host='qnap210'; 	user='mao' },
@{ host='rt66'; 	user='admin' } |
		ForEach-Object {
			Get-Credential -UserName $_.host\$_.user -Message "Enter password for the following resource" |
				New-StoredCredential -Target \\$_.host -Persist Enterprise
		}
	
New-psDrive -Name Private -psProvider FileSystem -Scope Global -Root '\\qnap210\Public' -credential (Get-StoredCredential -target '\\qnap210\Public')
New-psDrive -Name Torrent -psProvider FileSystem -Scope Global -Root '\\dns323\Install' -credential (Get-StoredCredential -target '\\dns323\Install')
New-psDrive -Name Install -psProvider FileSystem -Scope Global -Root '\\dns323\Install' -credential (Get-StoredCredential -target '\\dns323\Install')


New-Item -ItemType SymbolicLink -path c:/mnt/Torrents -value '\\dns323\torrent'
New-Item -ItemType SymbolicLink -path c:/mnt/Install -value '\\dns323\Install'
New-Item -ItemType SymbolicLink -path c:/mnt/Qnap -value '\\qnap210\Public'

#>