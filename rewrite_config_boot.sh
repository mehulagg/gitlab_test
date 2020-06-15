#!/bin/bash


# optionally backup original. Actually we can always get it from git
cp ./config/boot.rb ./config/boot.rb.original

# Override require to get required file list
cp ./config/boot.rb.profile_require ./config/boot.rb

# run a minimal runner to profile
export ENABLE_BOOTSNAP=1; rails runner "puts 'hello'" > all_required_files_w_bootsnap_with_debug_info.txt

# remove redundant information, get the pure list of required files
grep -v hello all_required_files_w_bootsnap_with_debug_info.txt | awk '{print $4}' | uniq > all_required_files_w_bootsnap.txt

# Generate the single big file to require
ruby ./generate.rb all_required_files_w_bootsnap.txt single_file_to_require_tmp.rb

# There are `require_relative` in the file. Since relative path changed, we need to replace them with `require <absolute_path>`
ruby ./replace_require_relative.rb single_file_to_require_tmp.rb single_file_to_require.rb

# use the single require file
cp ./config/boot.rb.single_require ./config/boot.rb

#run the runner again
export ENABLE_BOOTSNAP=1; rails runner "puts 'hello'"
