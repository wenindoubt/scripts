#!/bin/bash

# Copy s3 database content to local machine > Upload database > Remove content > E-mail users

if [ "$#" -eq 1 ]; then
	aws s3 cp s3://Database/Dumps/"$1" .
	zcat "$1" | mysql database
	rm -f "$1"
	aws sns publish --topic-arn arn:ARN --message "$(date): Database done uploading on $(hostname)"
	echo -e "\nDone Uploading!\n"
elif [ "$#" -eq 0 ]; then
	aws s3 ls s3://Database/Dumps/
fi
