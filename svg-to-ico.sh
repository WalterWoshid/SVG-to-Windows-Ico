#!/bin/bash

# Stop on error
set -o errexit -o pipefail -o noclobber -o nounset

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
  echo -e "${GREEN}SVG to (Windows)-ICO - by WalterWoshid${NC}"
  echo
  echo -e "${YELLOW}Usage:${NC}"
  echo -e "  svg-to-ico.sh [options] input [output]"
  echo
  echo -e "${YELLOW}Arguments:${NC}"
  echo -e "  ${GREEN}input${NC}   Path to the svg file or directory"
  echo -e "  ${GREEN}output${NC}  Output path"
  echo -e "          If not given, use the same path as the input file"
  echo
  echo -e "${YELLOW}Options:${NC}"
  echo -e "  ${GREEN}-p, --padding${NC}  Padding around the icon in pixels"
  echo -e "  ${GREEN}-t, --tasks${NC}    Number of tasks to run in parallel"
  echo -e "                 Default: 10"
  echo -e "                 0 for unlimited"
  echo -e "  ${GREEN}-h, --help${NC}     Show help"
}

suggest_help() {
  echo -e "${YELLOW}Try 'svg-to-ico.sh --help' for more information.${NC}"
  exit 1
}



# Values
input=""
output=""
padding=""
tasks=10

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p=*|--padding=*)
      padding="${1#*=}"
      shift
      ;;
    -p|--padding)
      padding="$2"
      shift 2
      ;;
    -t=*|--tasks=*)
      tasks="${1#*=}"
      shift
      ;;
    -t|--tasks)
      tasks="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*) # unsupported options
      echo -e "${RED}Error:${NC} Unsupported option $1" >&2
      suggest_help
      ;;
    -*) # unsupported flags
      echo -e "${RED}Error:${NC} Unsupported flag $1" >&2
      suggest_help
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Set positional arguments in their proper place
for arg in "${POSITIONAL_ARGS[@]}"; do
  if [ -z "$input" ]; then
    input="$arg"
  elif [ -z "$output" ]; then
    output="$arg"
  else
    echo -e "${RED}Too many arguments given${NC}"
    suggest_help
    exit 1
  fi
done



# Validate arguments
input_is_directory=false

# Check if input is given
if [ -z "$input" ]; then
  usage
  exit 0
fi

# Check if input is a file or directory
if [ -f "$input" ]; then
  input_is_directory=false
elif [ -d "$input" ]; then
  input_is_directory=true
else
  echo -e "${RED}Input is not a valid file or directory${NC}"
  suggest_help
  exit 1
fi

# If output is not given, use the same path as the input file
if [ -z "$output" ]; then
  output="$input"
else
  # If input is file and output has no extension, add .ico
  if [ "$input_is_directory" = false ] && [[ "$output" != *.* ]]; then
    output="$output.ico"
  elif [ "$input_is_directory" = true ] && [[ "$output" = *.* ]]; then
    # If input is directory and output has an extension, show error
    echo -e "${RED}Output must be a directory when input is a directory${NC}"
    suggest_help
    exit 1
  elif [[ "$output" == *.* ]] && [[ "$output" != *.ico ]]; then
    # If output has extension and is not .ico, show error
    echo -e "${RED}Output must be a directory or have extension .ico${NC}"
    suggest_help
    exit 1
  fi
fi

# Check if padding is a number
if [ -n "$padding" ] && ! [[ "$padding" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Padding option must be a number${NC}"
  suggest_help
  exit 1
fi

# Check if tasks is a number
if ! [[ "$tasks" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Tasks option must be a number${NC}"
  suggest_help
  exit 1
fi



# When done or interrupted, remove the temporary files
finally() {
  rm -rf "$1"
}

# Error handler
__error_handler__() {
  local error_code="$1"

  echo -e "${RED}Exiting with status ${error_code}${NC}"
  finally "$2"
}



convert_image() {
  # Temporary directory
  temp_dir=$(mktemp -d -t svg-to-ico-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)

  # Trap errors
  trap '__error_handler__ ${?} ${LINENO} "${BASH_COMMAND}" "${temp_dir}"' ERR

  # Some image magic
  for size in 16 24 32 48 64 96 128 256; do
    inkscape -e "$temp_dir/$size.png" -w "$size" -h "$size" "$1" >/dev/null 2>&1
  done

  # Some more image magic
  for size in 16 24 32 48; do
    convert -colors 256 +dither "$temp_dir/$size.png" "png8:$temp_dir/$size-8.png"
    convert -colors 16  +dither "$temp_dir/$size-8.png" "$temp_dir/$size-4.png"
  done

  declare -a paths=("16.png"   "24.png"   "32.png"   "48.png" \
                    "16-8.png" "24-8.png" "32-8.png" "48-8.png" \
                    "16-4.png" "24-4.png" "32-4.png" "48-4.png" \
                    "64.png"   "96.png"   "128.png"   "256.png")

  # Prefix the paths with the temporary directory
  for i in "${!paths[@]}"; do
    paths[$i]="$temp_dir/${paths[$i]}"
  done

  temp_ico="$temp_dir/icon.ico"

  # Convert to ico
  convert "${paths[@]}" "$temp_ico"

  # Remove the last 2 paths from path
  paths=("${paths[@]:0:${#paths[@]}-2}")

  icotool -c -o "$temp_ico" "${paths[@]}" -r "$temp_dir/128.png" -r "$temp_dir/256.png"

  # Padding
  if [ -n "$padding" ]; then
    convert "$temp_ico" -bordercolor transparent -border "$padding" "$temp_ico"
  fi

  # Create output directory if it doesn't exist
  mkdir -p "$(dirname "$2")"

  # Move the ico to the output path
  mv "$temp_ico" "$2"
}



# If input is a file, convert the image
if [ "$input_is_directory" = false ]; then
  echo -e "${YELLOW}Converting $input...${NC}"
  output_clean="${output%.*}"
  convert_image "$input" "$output_clean.ico"
  echo -e "${GREEN}Done! Output: $output_clean.ico${NC}"

  exit 0
else
  # If input is a directory, convert all images in the directory
  files=$(find "$input" -type f -name "*.svg")

  # If no files are found, show error
  if [ -z "$files" ]; then
    echo -e "${RED}No files found in directory ${YELLOW}$input${NC}"
    suggest_help
    exit 1
  fi

  # If tasks is 0, run all tasks in parallel
  count=$(echo "$files" | wc -l)
  echo -e "${YELLOW}Converting $input... (files: $count)${NC}"

  # If more than 25 files, show "This may take a while"
  if [ "$count" -gt 25 ]; then
    echo -e "${YELLOW}This may take a while...${NC}"
  fi

  if [ "$tasks" -eq 0 ]; then
    for file in $files; do
      convert_image "$file" "$output/$(basename "$file" .svg).ico" &&
      echo -e "${GREEN}Converted $file to $output/$(basename "$file" .svg).ico${NC}" &
    done
    wait

    echo -e "${GREEN}Done! Converted ${YELLOW}$(echo "$files" | wc -l)${GREEN} files to ${YELLOW}${output}${NC}"
    exit 0
  else
    # Run all tasks in parallel
    i=0
    for file in $files; do
      file_clean="${file%.*}" &&
      echo -e "${YELLOW}$((i+1)): Converting $file...${NC}" &&
      convert_image "$file" "$output/$file_clean.ico" &

      i=$((i+1))
      if [ $((i % tasks)) -eq 0 ]; then
        wait
      fi

      # If the last task is not finished, wait for it
      if [ $i -eq "$(echo "$files" | wc -l)" ]; then
        wait
      fi
    done

    echo -e "${GREEN}Done! Converted ${YELLOW}$(echo "$files" | wc -l)${GREEN} file(s) to ${YELLOW}${output}${NC}"
    exit 0
  fi
fi
