#!/bin/bash

apt install jq
#curl https://api.github.com/users/chrisbensch/starred | jq -r '.[].html_url' | xargs -l git clone
curl 'https://api.github.com/users/chrisbensch/starred?page=1&per_page=100' | jq -r '.[].git_url' > /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=2&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=3&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=4&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=5&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=6&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=7&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=8&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt
curl 'https://api.github.com/users/chrisbensch/starred?page=9&per_page=100' | jq -r '.[].git_url' >> /tmp/starred-gits.txt

#cd /mnt/hgfs/git-stars

#echo " " > /tmp/gits.sh
#echo "cd /mnt/hgfs/git-stars" >> /tmp/gits.sh
#while IFS= read -r line; do echo "git clone --quiet $line"; done < /tmp/starred-gits.txt >> /tmp/#gits.sh
#bash /tmp/gits.sh
