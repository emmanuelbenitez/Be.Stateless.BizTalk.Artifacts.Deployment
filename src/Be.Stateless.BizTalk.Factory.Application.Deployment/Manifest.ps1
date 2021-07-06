#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

[Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingCmdletAliases', '', Justification = 'Not ambiguous in the scope of a manifest.')]
[CmdletBinding()]
[OutputType([hashtable])]
param(
   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $BizTalkAdministratorGroup = "$($env:COMPUTERNAME)\BizTalk Server Administrators",

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $BizTalkApplicationUserGroup = "$($env:COMPUTERNAME)\BizTalk Application Users",

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $BizTalkIsolatedHostUserGroup = "$($env:COMPUTERNAME)\BizTalk Isolated Host Users",

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $ManagementServer = $env:COMPUTERNAME,

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $ProcessingServer = $env:COMPUTERNAME
)

Set-StrictMode -Version Latest

$sqlScriptVariables = @{
   BizTalkApplicationUserGroup     = $BizTalkApplicationUserGroup
   BizTalkIsolatedHostUserGroup    = $BizTalkIsolatedHostUserGroup
   BizTalkServerAdministratorGroup = $BizTalkAdministratorGroup
}

ApplicationManifest -Name BizTalk.Factory -Description 'BizTalk.Factory System Application.' -Build {
   Component -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Pipeline.Components)
   Pipeline -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Pipelines)
   Schema -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Schemas)
   SqlDatabase -Path $PSScriptRoot\sql\scripts -Name BizTalkFactoryMgmtDb -Server $ManagementServer `
      -EnlistInBizTalkBackupJob -ManagementServer $ManagementServer `
      -Variables $sqlScriptVariables
   SqlDatabase -Path $PSScriptRoot\sql\scripts -Name BizTalkFactoryTransientStateDb -Server $ProcessingServer `
      -EnlistInBizTalkBackupJob -ManagementServer $ManagementServer `
      -Variables $sqlScriptVariables
   SsoConfigStore -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Factory.Settings) `
      -AdministratorGroups $BizTalkAdministratorGroup `
      -UserGroups $BizTalkApplicationUserGroup, $BizTalkIsolatedHostUserGroup
}
