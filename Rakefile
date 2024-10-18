# Rakefile
# run 'rake --tasks' to see the list of tasks
require 'rake/testtask'

# Define a task to run all test files in the tests directory
# The test files should end with _test.rb
# The warning option is set to false to suppress warnings
# The test_files variable is set to a FileList object that contains the list of test files
Rake::TestTask.new(:test) do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/*_test.rb'] 
  t.warning = false
end

task default: :test
