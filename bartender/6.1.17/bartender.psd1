@{
  ModuleVersion = '6.1.17'
  RootModule = 'bartender.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('get-btScriptText','publish-btModule','clear-btRepository','get-btChangeDetails','get-btDefaultSettings','get-btFolderItems','get-btGitDetails','get-btInstalledModule','get-btRepository','new-btProject','save-btDefaultSettings','save-btRepository','start-btbuild','start-btTestPhase','update-btFileStructure','update-btProject')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    builtBy = 'Adrian.Andersson'
    moduleRevision = '6.1.16.2'
    builtOn = '2019-03-11T22:56:17'
    PSData = @{
      LicenseUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/LICENSE'
      Tags = @('Domain','Devops')
      ProjectUri = 'https://github.com/DomainGroupOSS/bartender'
      IconUri = 'https://github.com/DomainGroupOSS/bartender/icon.png'
    }
    bartenderCopyright = '2019 Domain Group'
    pester = @{
      time = '00:03:10.8568591'
      codecoverage = 75
      passed = '100 %'
    }
    bartenderVersion = '6.1.16.1'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
  }
  RequiredModules = @(@{
    ModuleName = 'Pester'
    GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'
    RequiredVersion = '4.6.0'
  },@{
    ModuleName = 'Configuration'
    GUID = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'
    RequiredVersion = '1.3.1'
  },@{
    ModuleName = 'platyPS'
    GUID = '0bdcabef-a4b7-4a6d-bf7e-d879817ebbff'
    RequiredVersion = '0.12.0'
  })
  GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'
  Description = 'A Framework for making PowerShell Modules'
  Copyright = '2019 Domain Group'
  CompanyName = 'Domain Group'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
