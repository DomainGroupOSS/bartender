# bartender - Release 6.2.0
| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|
## Overview
|item|value|
|:-:|:-:|
|Author(s)|Adrian.Andersson|
|Company|Domain Group|
|BuildUser|Adrian.Andersson|
|BuildDate|2020-05-26T11:51:04|



### Release Notes:

Updated PlatyPS And Pester versions; Added back in the CodeCoverage for pester;Fixed some Pester/modulepath bugs




---
## Changes Summary
|item|value|
|:-:|:-:|
|comparisonVersion|6.1.22|
|estimatedChangePercent|0.57 %|
|commentBasedHelpCoverage|100|
|version|6.2.0|



---
## File

### Summary

|item|value|
|:-:|:-:|
|newFiles|0|
|totalFiles|28|
|modifiedFiles|5|
|totalFileSize|252.724609375 kb|

### File List


#### Modified Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|save-btRepository|.\functions\save-btRepository.ps1|.ps1|5|
|start-btbuild|.\functions\start-btbuild.ps1|.ps1|45.6|
|start-btTestPhase|.\functions\start-btTestPhase.ps1|.ps1|10.46|
|baseModuleTest|.\pester\baseModuleTest.ps1|.ps1|2.1|
|functionTests|.\pester\functionTests.ps1|.ps1|35.06|


#### Unchanged Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|clear-btRepository|.\functions\clear-btRepository.ps1|.ps1|3.12|
|get-btChangeDetails|.\functions\get-btChangeDetails.ps1|.ps1|11.9|
|get-btDefaultSettings|.\functions\get-btDefaultSettings.ps1|.ps1|2.42|
|get-btFolderItems|.\functions\get-btFolderItems.ps1|.ps1|11.36|
|get-btGitDetails|.\functions\get-btGitDetails.ps1|.ps1|3.14|
|get-btInstalledModule|.\functions\get-btInstalledModule.ps1|.ps1|3.7|
|get-btRepository|.\functions\get-btRepository.ps1|.ps1|3.55|
|get-btScriptText|.\functions\get-btScriptText.ps1|.ps1|6.5|
|new-btproject|.\functions\new-btproject.ps1|.ps1|17.83|
|publish-btmodule|.\functions\publish-btmodule.ps1|.ps1|8.04|
|save-btDefaultSettings|.\functions\save-btDefaultSettings.ps1|.ps1|7.17|
|update-btFileStructure|.\functions\update-btFileStructure.ps1|.ps1|6.11|
|update-btProject|.\functions\update-btProject.ps1|.ps1|22.28|
|add-btBasicTests|.\private\add-btBasicTests.ps1|.ps1|4.52|
|add-btFilesAndFolders|.\private\add-btFilesAndFolders.ps1|.ps1|7.77|
|get-btDocumentation|.\private\get-btDocumentation.ps1|.ps1|7.28|
|get-btMarkdownFromHashtable|.\private\get-btMarkdownFromHashtable.ps1|.ps1|1.38|
|get-btReleaseMarkdown|.\private\get-btReleaseMarkdown.ps1|.ps1|11.22|
|get-btScriptFunctions|.\private\get-btScriptFunctions.ps1|.ps1|1.94|
|get-btStringComparison|.\private\get-btStringComparison.ps1|.ps1|2.92|
|start-btRevisionCleanup|.\private\start-btRevisionCleanup.ps1|.ps1|4.29|
|update-btMarkdownHeader|.\private\update-btMarkdownHeader.ps1|.ps1|5.25|
|readme|.\resource\readme.md|.md|0.83|





---
## Functions

### Summary

|item|value|
|:-:|:-:|
|totalFunctions|25|
|privateFunctions|9|
|publicFunctions|16|
|modifiedFunctions|3|
|newFunctions|0|

### Function List


#### Modified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|save-btRepository|Public|[link](./functions/save-btRepository.md)|.\save-btRepository.ps1|
|start-btbuild|Public|[link](./functions/start-btbuild.md)|.\start-btbuild.ps1|
|start-btTestPhase|Public|[link](./functions/start-btTestPhase.md)|.\start-btTestPhase.ps1|

#### Unmodified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|get-btScriptText|Public|[link](./functions/get-btScriptText.md)|.\get-btScriptText.ps1|
|publish-btModule|Public|[link](./functions/publish-btModule.md)|.\publish-btmodule.ps1|
|clear-btRepository|Public|[link](./functions/clear-btRepository.md)|.\clear-btRepository.ps1|
|get-btChangeDetails|Public|[link](./functions/get-btChangeDetails.md)|.\get-btChangeDetails.ps1|
|get-btDefaultSettings|Public|[link](./functions/get-btDefaultSettings.md)|.\get-btDefaultSettings.ps1|
|get-btFolderItems|Public|[link](./functions/get-btFolderItems.md)|.\get-btFolderItems.ps1|
|get-btGitDetails|Public|[link](./functions/get-btGitDetails.md)|.\get-btGitDetails.ps1|
|get-btInstalledModule|Public|[link](./functions/get-btInstalledModule.md)|.\get-btInstalledModule.ps1|
|get-btRepository|Public|[link](./functions/get-btRepository.md)|.\get-btRepository.ps1|
|new-btProject|Public|[link](./functions/new-btProject.md)|.\new-btproject.ps1|
|save-btDefaultSettings|Public|[link](./functions/save-btDefaultSettings.md)|.\save-btDefaultSettings.ps1|
|update-btFileStructure|Public|[link](./functions/update-btFileStructure.md)|.\update-btFileStructure.ps1|
|update-btProject|Public|[link](./functions/update-btProject.md)|.\update-btProject.ps1|
|add-btBasicTests|Private||.\add-btBasicTests.ps1|
|add-btFilesAndFolders|Private||.\add-btFilesAndFolders.ps1|
|get-btDocumentation|Private||.\get-btDocumentation.ps1|
|get-btMarkdownFromHashtable|Private||.\get-btMarkdownFromHashtable.ps1|
|get-btReleaseMarkdown|Private||.\get-btReleaseMarkdown.ps1|
|get-btScriptFunctions|Private||.\get-btScriptFunctions.ps1|
|get-btStringComparison|Private||.\get-btStringComparison.ps1|
|start-btRevisionCleanup|Private||.\start-btRevisionCleanup.ps1|
|update-btMarkdownHeader|Private||.\update-btMarkdownHeader.ps1|



---
## Required Modules
|moduleName|requiredVersion|
|-|-|
|Pester|4.10.1|
|Configuration|1.3.1|
|platyPS|0.14.0|




---
## Pester Details
|item|value|
|:-:|:-:|
|time|00:02:18.6081402|
|passed|100 %|
|codecoverage|77|



---
## Git Details
|item|value|
|:-:|:-:|
|origin|https://github.com/DomainGroupOSS/bartender|
|branch|master|
|commit|6d29706|



[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=77&color=green
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.1.22&color=0B2047
[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=6.2.0&color=blue
[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=100&color=brightgreen
