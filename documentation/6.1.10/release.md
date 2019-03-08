# bartender - Release 6.1.10
| Version | Code Coverage | Bartender Version| Code Based Help Coverage |
|-------------------|-------------------|-------------------|-------------------|
|![releasebadge]|![pesterbadge]|![btbadge]|![helpcoveragebadge]|
## Overview
```

Name                           Value                                                                                   
----                           -----                                                                                   
Company                        Domain Group                                                                            
Author(s)                      Adrian.Andersson                                                                        
BuildDate                      2019-03-08T17:30:41                                                                     
BuildUser                      Adrian.Andersson                                                                        



```

---
## Changes Summary
```

Name                           Value                                                                                   
----                           -----                                                                                   
totalFiles                     25                                                                                      
newFiles                       0                                                                                       
modifiedFiles                  8                                                                                       
totalFunctions                 22                                                                                      
newFunctions                   0                                                                                       
modifiedFunctions              8                                                                                       
privateFunctions               6                                                                                       
publicFunctions                16                                                                                      
commentBasedHelpCoverage       100                                                                                     



```

---
## Files Summary


### Modified Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-btChangeDetails|.\functions\get-btChangeDetails.ps1|.ps1|9.565|
|get-btGitDetails|.\functions\get-btGitDetails.ps1|.ps1|3.142|
|new-btproject|.\functions\new-btproject.ps1|.ps1|17.828|
|save-btDefaultSettings|.\functions\save-btDefaultSettings.ps1|.ps1|7.165|
|start-btbuild|.\functions\start-btbuild.ps1|.ps1|46.826|
|update-btProject|.\functions\update-btProject.ps1|.ps1|21.812|
|get-btDocumentation|.\private\get-btDocumentation.ps1|.ps1|7.049|
|get-btReleaseMarkdown|.\private\get-btReleaseMarkdown.ps1|.ps1|10.76|


### Unchanged Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|clear-btRepository|.\functions\clear-btRepository.ps1|.ps1|3.119|
|get-btDefaultSettings|.\functions\get-btDefaultSettings.ps1|.ps1|2.42|
|get-btFolderItems|.\functions\get-btFolderItems.ps1|.ps1|11.263|
|get-btInstalledModule|.\functions\get-btInstalledModule.ps1|.ps1|3.699|
|get-btRepository|.\functions\get-btRepository.ps1|.ps1|3.55|
|get-btScriptText|.\functions\get-btScriptText.ps1|.ps1|6.499|
|publish-btmodule|.\functions\publish-btmodule.ps1|.ps1|8.041|
|save-btRepository|.\functions\save-btRepository.ps1|.ps1|5.198|
|start-btTestPhase|.\functions\start-btTestPhase.ps1|.ps1|9.684|
|update-btFileStructure|.\functions\update-btFileStructure.ps1|.ps1|6.113|
|baseModuleTest|.\pester\baseModuleTest.ps1|.ps1|1.359|
|functionTests|.\pester\functionTests.ps1|.ps1|32.503|
|functionTests.ps1|.\pester\functionTests.ps1.bkp|.bkp|23.729|
|add-btBasicTests|.\private\add-btBasicTests.ps1|.ps1|4.517|
|add-btFilesAndFolders|.\private\add-btFilesAndFolders.ps1|.ps1|6.624|
|get-btScriptFunctions|.\private\get-btScriptFunctions.ps1|.ps1|1.938|
|start-btRevisionCleanup|.\private\start-btRevisionCleanup.ps1|.ps1|4.288|



---
## Functions Summary


### Unmodified Functions
|function|type|mdLink|filename|
|-|-|-|-|
|get-btScriptText|Public|[link](../6.1.10/functions/get-btScriptText.md)|.\get-btScriptText.ps1|
|publish-btModule|Public|[link](../6.1.10/functions/publish-btModule.md)|.\publish-btmodule.ps1|
|clear-btRepository|Public|[link](../6.1.10/functions/clear-btRepository.md)|.\clear-btRepository.ps1|
|get-btDefaultSettings|Public|[link](../6.1.10/functions/get-btDefaultSettings.md)|.\get-btDefaultSettings.ps1|
|get-btFolderItems|Public|[link](../6.1.10/functions/get-btFolderItems.md)|.\get-btFolderItems.ps1|
|get-btInstalledModule|Public|[link](../6.1.10/functions/get-btInstalledModule.md)|.\get-btInstalledModule.ps1|
|get-btRepository|Public|[link](../6.1.10/functions/get-btRepository.md)|.\get-btRepository.ps1|
|save-btRepository|Public|[link](../6.1.10/functions/save-btRepository.md)|.\save-btRepository.ps1|
|start-btTestPhase|Public|[link](../6.1.10/functions/start-btTestPhase.md)|.\start-btTestPhase.ps1|
|update-btFileStructure|Public|[link](../6.1.10/functions/update-btFileStructure.md)|.\update-btFileStructure.ps1|
|add-btBasicTests|Private||.\add-btBasicTests.ps1|
|add-btFilesAndFolders|Private||.\add-btFilesAndFolders.ps1|
|get-btScriptFunctions|Private||.\get-btScriptFunctions.ps1|
|start-btRevisionCleanup|Private||.\start-btRevisionCleanup.ps1|

### Modified Functions
|function|type|mdLink|filename|
|-|-|-|-|
|get-btChangeDetails|Public|[link](../6.1.10/functions/get-btChangeDetails.md)|.\get-btChangeDetails.ps1|
|get-btGitDetails|Public|[link](../6.1.10/functions/get-btGitDetails.md)|.\get-btGitDetails.ps1|
|new-btProject|Public|[link](../6.1.10/functions/new-btProject.md)|.\new-btproject.ps1|
|save-btDefaultSettings|Public|[link](../6.1.10/functions/save-btDefaultSettings.md)|.\save-btDefaultSettings.ps1|
|start-btbuild|Public|[link](../6.1.10/functions/start-btbuild.md)|.\start-btbuild.ps1|
|update-btProject|Public|[link](../6.1.10/functions/update-btProject.md)|.\update-btProject.ps1|
|get-btDocumentation|Private||.\get-btDocumentation.ps1|
|get-btReleaseMarkdown|Private||.\get-btReleaseMarkdown.ps1|

---
## Required Modules
|moduleName|requiredVersion|
|-|-|
|Pester|4.6.0|
|Configuration|1.3.1|
|platyPS|0.12.0|


---
## Pester Details
```

Name                           Value                                                                                   
----                           -----                                                                                   
time                           00:02:31.7635405                                                                        
codecoverage                   74                                                                                      
passed                         100 %                                                                                   



```

---
## Git Details
```

Name                           Value                                                                                   
----                           -----                                                                                   
branch                         master                                                                                  
commit                         e6883bc                                                                                 
origin                         https://github.com/DomainGroupOSS/bartender                                             



```

[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=74&color=yellowgreen
[btbadge]: https://img.shields.io/static/v1.svg?label=bartenderVer&message=6.1.9.2&color=blueviolet
[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=6.1.10&color=blue
[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=commentBasedHelpCoverage&message=100&color=brightgreen
