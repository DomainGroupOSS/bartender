@{
  ModuleVersion = '6.1.5'
  RootModule = 'bartender.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('get-btScriptText','publish-btModule','clear-btRepository','get-btChangeDetails','get-btDefaultSettings','get-btFolderItems','get-btGitDetails','get-btInstalledModule','get-btRepository','new-btProject','save-btDefaultSettings','save-btRepository','start-btbuild','start-btTestPhase','update-btFileStructure','update-btProject')
  CmdletsToExport = @()
  PowerShellVersion = '5.0.0.0'
  PrivateData = @{
    builtBy = 'Adrian.Andersson'
    moduleRevision = '6.1.4.3'
    builtOn = '2019-03-07T16:56:00'
    PSData = @{
      Tags = @('Domain','Devops')
    }
    bartenderCopyright = '2019 Domain Group'
    pester = @{
      time = '00:02:25.2395409'
      codecoverage = '66 %'
      passed = '100 %'
    }
    bartenderVersion = '6.1.4.2'
    moduleCompiledBy = 'Bartender | A PowerShell Module Mixologist'
  }
  RequiredModules = @(@{
    ModuleName = 'Pester'
    GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'
    RequiredVersion = '4.6.0'
  },@{
    ModuleName = 'platyPS'
    GUID = '0bdcabef-a4b7-4a6d-bf7e-d879817ebbff'
    RequiredVersion = '0.12.0'
  },@{
    ModuleName = 'Configuration'
    GUID = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'
    RequiredVersion = '1.3.1'
  })
  GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'
  Description = 'A PowerShell Module Mixologist'
  Copyright = '2019 Domain Group'
  CompanyName = 'Domain Group'
  Author = 'Adrian.Andersson'
  ScriptsToProcess = @()
}
