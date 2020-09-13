#!/bin/bash

exit

# size of directories in `node_modules`
du -sh ./node_modules/* | sort -nr | grep '\dM.*'


# find and `rm node_modules`
find ./* -type d -name "node_modules"
find ./* -type d -name "*dir*" | xargs rm -dfR

# count files
find ~/_dev/ -type f | wc -l
# by type of file
find . -type f -name "*.txt" | wc -l



# count directories
find . -type d | wc -l


# du
du -hd 1
