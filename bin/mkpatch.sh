#!/bin/sh
#
. /home/tekkamanninja/development/tekkamanv_sdk/etc/sdk_env.conf

OUTPUT_DIR=${SDK_PATCH_DIR}/$(basename `pwd`)

if [ "$#" -lt "1" ] ; then
	echo "usage: $(basename $0) <patch-number> [check-point] [patch-version] [patch-output-dir] "
	echo "example: $0 2 linux.git/master 2 ../linux_patch "
	exit 1
fi

if [ -z $2 ] ; then
	CHECKPOINT="HEAD"
else
	CHECKPOINT="$2"
fi

if [ -z ${3} ] ; then
	REVISION=""
else
	REVISION=" v${3}"
fi

if [ -n "$4" ] ; then
	OUTPUT_DIR=$4
else
	OUTPUT_DIR=${OUTPUT_DIR}_`git log -1 --oneline ${CHECKPOINT} | awk '{print $1}'`_`git log -${1} --oneline ${CHECKPOINT} | awk '{print $1}'| tail -1`
fi

if [ -n "$REVISION" ] ; then
	OUTPUT_DIR=${OUTPUT_DIR}_v${3}
fi

if [ ${1}x != "1x" ]; then
	NEED_COVER=--cover-letter
fi

sdk_welcome_info \
"N=${1}" \
"CHECKPOINT=${CHECKPOINT}" \
"REVISION=${REVISION}" \
"OUTPUT_DIR=${OUTPUT_DIR}"

if [ -d $OUTPUT_DIR ]; then
	BACKUP_SUBFIX=`date +%Y%m%d%H%M%S`_backup
	mv $OUTPUT_DIR ${OUTPUT_DIR}_$BACKUP_SUBFIX
	echo -e '\E[37;31m'"\033[1mWARNING:\033[0m backup previous pachset to"
	echo ${OUTPUT_DIR}_$BACKUP_SUBFIX
fi

echo  "**********Commit List**********"
git log -${1} --oneline ${CHECKPOINT}
echo  "*******************************"

git format-patch --quiet --subject-prefix="PATCH${REVISION}" $NEED_COVER --stat -${1} -o ${OUTPUT_DIR} ${CHECKPOINT}

echo  "**********File List**********"
ls -1 ${OUTPUT_DIR}

echo  "********************Checking patches' format********************"
./scripts/checkpatch.pl --strict ${OUTPUT_DIR}/*

echo  "********************Get Maintainers's email********************"
./scripts/get_maintainer.pl ${OUTPUT_DIR}/*
