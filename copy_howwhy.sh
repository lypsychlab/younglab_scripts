#!/bin/bash

rootdir=/home/younglw/lab

for i in {1..29}
do
	printf -v j "%02d" $i
	cp -Rv $rootdir/HOWWHY/YOU_HOWWHY_$j/dicom $rootdir/HOWWHY_Runwise/YOU_HOWWHY_$j
	# cd $rootdir/HOWWHY_Runwise/YOU_HOWWHY_$j
	# mkdir dicom
	# mv *.IMA ./dicom/
done
