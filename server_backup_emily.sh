#!/bin/sh

dest=wasserem@pleiades.bc.edu:/home/younglw/server_backup

for src_dir in /younglab/ /mnt/englewood
do
rsync -rq -R $src_dir $dest
done

#r: recursive (for directories)
#q: quiet (suppress output)


#add to crontab: 0 17 * * 5 /younglab/scripts/server_backup_emily.sh
