#Requires -Version 5

using namespace System.Management.Automation;



class CredentialBuilder
{
	
	hidden [Hashtable] $internalCredential
	
	CredentialBuilder()
	{
		$this.internalCredential = [Hashtable]::new()
	}
	
	
	[CredentialBuilder] setUser( [String] $UserName )
	{
		$this.internalCredential.UserName = $UserName
		return $this
	}
	
	
	[CredentialBuilder] setSecurePassword( [Security.SecureString] $Password )
	{
		$this.internalCredential.Password = $Password
		return $this
	}
	
	
	[CredentialBuilder] setPasswordFromUserInput()
	{
		$cred = Get-Credential -Message "Enter login and password" -UserName $this.internalCredential.UserName
		$this.setUser( $cred.UserName ).setSecurePassword( $cred.Password )
		return $this
	}

	
	
	[PSCredential] Build()
	{
		return [PSCredential]::new( $this.internalCredential.UserName, $this.internalCredential.Password )
	}

}


#
#
#
#
#

function Get-CredentialBuilderClass()
{
	return [CredentialBuilder]::new()
}

Export-ModuleMember -Function Get-CredentialBuilderClass