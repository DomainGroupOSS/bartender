
@{
  ScriptsToProcess = @()
  Description = 'A Framework for making PowerShell Modules'
  Author = 'Adrian.Andersson'
  GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'
  CompanyName = 'Domain Group'
  Copyright = '2020 Domain Group'
  PrivateData = @{
    PSData = @{
      ProjectUri = 'https://github.com/DomainGroupOSS/bartender'
      LicenseUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/LICENSE'
      IconUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/icon.png'
      Tags = @('Domain','Devops')
      ReleaseNotes = 'Updated PlatyPS And Pester versions; Added back in the CodeCoverage for pester;Fixed some Pester/modulepath bugs'
    }
    bartenderVersion = '6.1.22'
    pester = @{
      time = '00:02:18.6081402'
      passed = '100 %'
      codecoverage = 77
    }
    builtBy = 'Adrian.Andersson'
    bartenderCopyright = '2019 Domain Group'
    builtOn = '2020-05-26T11:51:04'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    moduleRevision = '6.1.22.9'
  }
  ModuleVersion = '6.2.0'
  RequiredModules = @(@{
    RequiredVersion = '4.10.1'
    GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'
    ModuleName = 'Pester'
  },@{
    RequiredVersion = '1.3.1'
    GUID = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'
    ModuleName = 'Configuration'
  },@{
    RequiredVersion = '0.14.0'
    GUID = '0bdcabef-a4b7-4a6d-bf7e-d879817ebbff'
    ModuleName = 'platyPS'
  })
  CmdletsToExport = @()
  FunctionsToExport = @('get-btScriptText','publish-btModule','clear-btRepository','get-btChangeDetails','get-btDefaultSettings','get-btFolderItems','get-btGitDetails','get-btInstalledModule','get-btRepository','new-btProject','save-btDefaultSettings','save-btRepository','start-btbuild','start-btTestPhase','update-btFileStructure','update-btProject')
  AliasesToExport = @()
  PowerShellVersion = '5.0.0.0'
  RootModule = 'bartender.psm1'
}
