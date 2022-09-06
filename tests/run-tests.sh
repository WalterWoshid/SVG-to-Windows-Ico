#!/bin/bash

# Stop on error
set -e

# Colors
RED='\033[0;31m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
NC='\033[0m'

# Symbols
CHECKMARK='\xE2\x9C\x94'
CIRCLE='\xE2\x9A\xA0'

cleanup_icons() {
  # Remove all .ico files recursively
  find . -name "*.ico" -type f -delete

  # Remove dest directory
  rm -rf dest
}

failed_tests=0

fail_grep() {
  test_name="$1"
  output="$2"
  expected_grep="$3"

  echo -e "${BG_RED}Test failed${NC} - $test_name"
  echo
  echo -e "${RED}Expected output to contain:${NC}"
  echo "$expected_grep"
  echo
  echo -e "${RED}Actual output:${NC}"
  # Remove color codes
  echo "$output" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
  echo

  failed_tests=$((failed_tests + 1))
}

fail_file() {
  test_name="$1"
  missing_file="$2"
  expected_files="$3"
  actual_files="$4"

  echo -e "${BG_RED}Test failed${NC} - $test_name"
  echo
  echo -e "${RED}Expected output files:${NC}"
  echo "$expected_files"
  echo
  echo -e "${RED}Actual output files:${NC}"
  echo "$actual_files"
  echo
  echo -e "${RED}Missing file:${NC}"
  echo "$missing_file"
  echo

  failed_tests=$((failed_tests + 1))
}

success() {
  test_name="$1"

  echo -e "${BG_GREEN}Test passed${NC} - $test_name"
  echo
}

test_file() {
  cleanup_icons

  test_name="$1"
  test_command="$2"
  expected_files="$3"

  # Run test
  eval "'$script_path' $test_command" > /dev/null 2>&1

  # Check if files exist
  for file in $expected_files; do
    if [ ! -f "$file" ]; then
      # actual_files = all .ico files without without ./ prefix and in same line
      actual_files=$(find "$script_dir" -name "*.ico" -type f | sed -r "s/^\.\///g" | tr '\n' ' ')
      fail_file "$test_name" "$file" "$expected_files" "$actual_files"
      return
    fi
  done

  success "$test_name"
}

test_grep() {
  cleanup_icons

  # Disable errexit for this function
  set +e

  test_name="$1"
  test_command="$2"
  test_result="$(eval "'$script_path' $test_command" 2>&1)"
  expected_grep="$3"

  if [[ "$test_result" =~ $expected_grep ]]; then
    success "$test_name"
  else
    fail_grep "$test_name" "$test_result" "$expected_grep"
  fi
}

finally() {
  cleanup_icons

  # Print summary
  if [ "$failed_tests" -gt 0 ]; then
    echo -e "${RED}${CIRCLE} $failed_tests test(s) failed${NC}"
    exit 1
  else
    echo -e "${CHECKMARK}  All tests passed"
  fi
}



script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$script_dir"
script_path="$script_dir/../svg-to-ico.sh"

test_grep "Usage --help"     "--help"                 "Usage:"
test_grep "Usage -h"         "-h"                     "Usage:"
test_grep "Usage no args"    ""                       "Usage:"
test_grep "Invalid file"     "invalid-file.svg"       "Input is not a valid file or directory"
test_grep "Invalid dir"      "invalid-dir"            "Input is not a valid file or directory"
test_grep "Invalid output"   "folder im-a-file.ico"   "Output must be a directory when input is a directory"
test_grep "Invalid padding"  "folder -p im-a-string"  "Padding option must be a number"
test_grep "Invalid tasks"    "folder -t im-a-string"  "Tasks option must be a number"
test_grep "Invalid flag"     "folder -x"              "Unsupported flag"
test_grep "Invalid option"   "folder --invalid"       "Unsupported option"

test_file "Single file"         "test.svg"           "test.ico"
test_file "Single file out"     "test.svg dest.ico"  "dest.ico"
test_file "Single file in dir"  "folder/test.svg"    "folder/test.ico"

test_file "Directory"         "folder"                 "folder/subfolder/test.ico folder/test.ico"
test_file "Subdirectory"      "folder/subfolder"       "folder/subfolder/test.ico"
test_file "Directory out"     "folder dest"            "dest/subfolder/test.ico dest/test.ico"
test_file "Subdirectory out"  "folder/subfolder dest"  "dest/test.ico"

test_file "Directory padding"   "folder -p 10"  "folder/subfolder/test.ico folder/test.ico"
test_file "Directory tasks"     "folder -t 1"   "folder/subfolder/test.ico folder/test.ico"
test_file "Directory parallel"  "folder -t 0"   "folder/subfolder/test.ico folder/test.ico"

finally