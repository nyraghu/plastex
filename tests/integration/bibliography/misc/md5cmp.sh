#!/bin/sh

### Compare the MD5 hashes of files in two directories.

directory1="$1"
directory2="$2"
shift 2
files="$@"

for file in ${files}; do
    file1="${directory1}"/"${file}"
    file2="${directory2}"/"${file}"
    hash1=$(md5sum "${file1}" | awk '{ print $1 }')
    hash2=$(md5sum "${file2}" | awk '{ print $1 }')
    if [ ${hash1} != ${hash2} ]; then
        printf "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Error: MD5 hash mismatch:
${hash1} ${file1}
${hash2} ${file2}
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"
        exit 1
    fi
done

exit 0

### End of file
