write-verbose 'Creating test file'
$testPath = "$($scriptVars.moduleOutputFolder)\test.txt"
write-verbose "TestPath: $testpath"
'some text'|out-file $testpath -Force