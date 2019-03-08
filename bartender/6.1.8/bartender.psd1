@{
  ModuleVersion = '6.1.8'
  RootModule = 'bartender.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('get-btScriptText','publish-btModule','clear-btRepository','get-btChangeDetails','get-btDefaultSettings','get-btFolderItems','get-btGitDetails','get-btInstalledModule','get-btRepository','new-btProject','save-btDefaultSettings','save-btRepository','start-btbuild','start-btTestPhase','update-btFileStructure','update-btProject')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    builtBy = 'Adrian.Andersson'
    moduleRevision = '6.1.7.1'
    builtOn = '2019-03-08T16:31:43'
    PSData = @{
      LicenseUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/LICENSE'
      Tags = @('Domain','Devops')
      ProjectUri = 'https://github.com/DomainGroupOSS/bartender'
    }
    bartenderCopyright = '2019 Domain Group'
    pester = @{
      time = '00:02:28.2417245'
      codecoverage = 74
      passed = '100 %'
    }
    bartenderVersion = '6.1.6.3'
    moduleCompiledBy = 'Bartender | A PowerShell Module Mixologist'
  }
  GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'
  Description = 'A PowerShell Module Mixologist'
  Copyright = '2019 Domain Group'
  CompanyName = 'Domain Group'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
