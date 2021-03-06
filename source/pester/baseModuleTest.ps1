Param(
    $moduleVersion,
    $modulePath,
    $moduleName
)
describe 'Parameters should exist' {
    it "ModuleVersion: '$moduleVersion' should not be null" {
        $moduleVersion|Should Not Be $null
    }

    it "ModulePath: '$modulePath' should not be null" {
        $modulePath|Should not be $null
    }

    it "moduleName: '$moduleName' should not be null" {
        $moduleName|Should not be $null
    }

}

describe 'The module was imported succesfully' {
    $module = get-module -name $moduleName
    it 'Should have imported a single module' {
        ($module | measure-object).count | should -be 1
    }
    it 'Name of the module is correct' {
        $module.Name |Should -be $moduleName
    }
    it 'Should be sourced from the distribution folder' {
        $module.modulebase |Should -Be $modulePath
    }
    it 'Imported module Version should match' {
        $module.version |Should -be $moduleVersion
    }
}
describe 'Check for module Dependancies' {
    $loadedModules = get-module
    $moduleDependencies
}
