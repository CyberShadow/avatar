#!/bin/bash
set -eu

heimdall flash \
		 --pit ~/data/backup/phone/rsync/note4.pit \
		 --8 out.img \
		 --verbose
