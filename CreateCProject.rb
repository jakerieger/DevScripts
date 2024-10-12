if (ARGV.length < 3)
  abort("No arguments provided. Run --help for usage information.")
end

projectName = ARGV[0] # "MyCLibrary"
projectLang = ARGV[1] # "C", "CPP"
projectType = ARGV[2] # "StaticLib", "SharedLib", "App"

# Remove spaces from project name
projectName.gsub(" ", "")

if projectLang != "C" && projectLang != "CXX"
  abort("Invalid language argument provided. Options are 'C' or 'CXX'.")
end

if projectType != "StaticLib" && projectType != "SharedLib" && projectType != "App"
  abort("Invalid project type provided. Options are 'StaticLib', 'SharedLib', or 'App'.")
end

# Create project directories
cwd = File.absolute_path(Dir.pwd)

# Create root
projectDir = File.join(cwd, projectName)

if File.exist?(projectDir)
  print("Project directory already exists. Overwrite? (y/n): ")
  response = $stdin.gets.chomp
  if response.downcase.eql? "n"
    exit
  else
    require 'fileutils'
    FileUtils.rm_rf(projectDir)
  end
end

Dir.mkdir(projectDir)

# Create project dirs
vendorDir = File.join(projectDir, "Vendor")
sourceDir = File.join(projectDir, "Source")
buildDir = File.join(projectDir, "build")
libIncludeDir = ""

Dir.mkdir(vendorDir)
Dir.mkdir(sourceDir)
Dir.mkdir(buildDir)

if projectType != "App"
  includeDir = File.join(projectDir, "Include")
  Dir.mkdir(includeDir)
  libIncludeDir = File.join(includeDir, projectName)
  Dir.mkdir(libIncludeDir)
end

cmakeListsTemplate = "cmake_minimum_required(VERSION 3.14) # Change this if necessary
project(#{projectName} LANGUAGES #{projectLang})

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(SRCDIR ${CMAKE_CURRENT_SOURCE_DIR}/Source)
set(INCDIR ${CMAKE_CURRENT_SOURCE_DIR}/Include) # This may not be used if project is not a library
set(VENDORDIR ${CMAKE_CURRENT_SOURCE_DIR}/Vendor)
"

# Create CMakeLists.txt
File.write(File.join(projectDir, "CMakeLists.txt"), cmakeListsTemplate)

if projectType == "App"
  if projectLang == "CXX"
    mainCpp = "#include <iostream>

int main() {
  std::cout << \"Hello, World!\" << std::endl;
  return 0;
}
    "
    File.write(File.join(sourceDir, "main.cpp"), mainCpp)
  else
    mainC = "#include <stdio.h>

int main(void) {
  printf(\"Hello, World!\\n\");
  return 0;
}
    "
    File.write(File.join(sourceDir, "main.c"), mainC)
  end
else
  headerName = "#{projectName}.h"
  header = "#pragma once

namespace #{projectName} {}
  "
  File.write(File.join(libIncludeDir, headerName), header)
end