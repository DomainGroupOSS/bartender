@{
  ModuleVersion = '6.1.6'
  RootModule = 'bartender.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('get-btScriptText','publish-btModule','clear-btRepository','get-btChangeDetails','get-btDefaultSettings','get-btFolderItems','get-btGitDetails','get-btInstalledModule','get-btRepository','new-btProject','save-btDefaultSettings','save-btRepository','start-btbuild','start-btTestPhase','update-btFileStructure','update-btProject')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    builtBy = 'Adrian.Andersson'
    moduleRevision = '6.1.5.14'
    builtOn = '2019-03-07T19:10:19'
    PSData = @{
      LicenseUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/LICENSE'
      Tags = @('Domain','Devops')
      ProjectUri = 'https://github.com/DomainGroupOSS/bartender'
    }
    bartenderCopyright = '2019 Domain Group'
    pester = @{
      time = '00:02:25.9049009'
      codecoverage = '73 %'
      passed = '100 %'
    }
    bartenderVersion = '6.1.5.13'
    moduleCompiledBy = 'Bartender | A PowerShell Module Mixologist'
  }
  GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'
  Description = 'A PowerShell Module Mixologist'
  Copyright = '2019 Domain Group'
  CompanyName = 'Domain Group'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
