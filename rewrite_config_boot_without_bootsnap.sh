#!/bin/bash

set -e

flag="without_bootsnap"
enable_bootsnap=0

# optionally backup original. Actually we can always get it from git
cp ./config/boot.rb ./config/boot.rb.original

# Override require to get required file list
cp ./config/boot.rb.profile_require_${flag} ./config/boot.rb

# run a minimal runner to profile
export ENABLE_BOOTSNAP=${enable_bootsnap}; rails runner "puts 'hello running profile'" > all_required_files_with_debug_info_${flag}.txt

# remove redundant information, get the pure list of required files
grep -v hello all_required_files_with_debug_info_${flag}.txt | awk '{print $4}' | uniq > all_required_files_${flag}.txt

# Generate the single big file to require
ruby ./generate.rb all_required_files_${flag}.txt single_file_to_require_tmp_${flag}.rb

# There are `require_relative` in the file. Since relative path changed, we need to replace them with `require <absolute_path>`
ruby ./replace_require_relative.rb single_file_to_require_tmp_${flag}.rb single_file_to_require_${flag}.rb

# use the single require file
cp ./config/boot.rb.single_require_${flag} ./config/boot.rb

#run the runner again
export ENABLE_BOOTSNAP=${enable_bootsnap}; rails runner "puts 'hello from single required file'"
