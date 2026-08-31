require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

desc "Build H3 C library"
task :build do
  Dir.chdir("ext/h3") do
    sh "make"
  end
end

desc "Remove compiled H3 library"
task :clean do
  Dir.chdir("ext/h3") do
    sh "make clean"
  end
end

task spec: :build

desc "Recompile the H3 C library"
task rebuild: %i[clean build]

task default: :spec
