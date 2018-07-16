#Requires -Version 5
#Requires -RunAsAdministrator

using namespace System.Management.Automation;



if (-not (Get-Module -Name CredentialManager -ListAvailable))
{
	Install-Module -Name CredentialManager -Scope AllUsers -Force -Confirm:$false
}
Import-Module -Name CredentialManager


enum Persistence
{
	Session
	LocalMachine
	Enterprise
}




