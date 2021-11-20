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

#Requires -Modules @{ ModuleName = 'BizTalk.Deployment'; ModuleVersion = '1.0.21350.31793'; GUID = '533b5f59-49ce-4f51-a293-cb78f5cf81b5' }

[Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingCmdletAliases', '', Justification = 'Not ambiguous in the scope of a manifest.')]
[CmdletBinding()]
[OutputType([HashTable])]
param(
   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $BizTalkAdministratorGroup = ((Get-BizTalkGroupSettings).BizTalkAdministratorGroup | ConvertTo-SqlLogin),

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string[]]
   $BizTalkHostUserGroups = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique | ConvertTo-SqlLogin),

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $ManagementServer = (Get-BizTalkGroupSettings).MgmtDbServerName,

   [Parameter(Mandatory = $false)]
   [ValidateNotNullOrEmpty()]
   [string]
   $ProcessingServer = (Get-BizTalkGroupSettings).SubscriptionDBServerName
)

Set-StrictMode -Version Latest

ApplicationManifest -Name BizTalk.Factory -Description 'BizTalk.Factory System Application.' -Build {
   Component -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Pipeline.Components)
   Pipeline -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Pipelines)
   Schema -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Schemas)
   SqlDatabase -Path $PSScriptRoot\sql\scripts -Name BizTalkFactoryMgmtDb -Server $ManagementServer `
      -EnlistInBizTalkBackupJob `
      -Variables @{ BizTalkAdministratorGroup = $BizTalkAdministratorGroup ; BizTalkHostUserGroups = $BizTalkHostUserGroups -join ';' }
   SqlDatabase -Path $PSScriptRoot\sql\scripts -Name BizTalkFactoryTransientStateDb -Server $ProcessingServer `
      -EnlistInBizTalkBackupJob `
      -Variables @{ BizTalkAdministratorGroup = $BizTalkAdministratorGroup ; BizTalkHostUserGroups = $BizTalkHostUserGroups -join ';' }
   SsoConfigStore -Path (Get-ResourceItem -Name Be.Stateless.BizTalk.Factory.Settings)
}
