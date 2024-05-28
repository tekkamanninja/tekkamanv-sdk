#!/bin/sh
#
#	Invoke git send-email for me properly for the Linaro ACPI work
#


. /home/tekkamanninja/development/tekkamanv_sdk/etc/sdk_env.conf

. $SDK_CONFIG_DIR/git-send-email.conf

if [ "$1" == "" ]
then
	echo "usage: $0 <patch-dir> ..."
	exit 1
fi

git send-email	\
	--annotate \
	--thread \
	--compose \
	--suppress-from \
	--no-chain-reply-to \
	${TO_LIST} \
	${CC_LIST} \
	${BCC_LIST} \
	--from=${FROM_LIST} \
	--envelope-sender=${SENDER_LIST} \
	--smtp-server=${SMPT_SERVER} \
	--smtp-server-port=${SMPT_SERVER_PORT} \
	${SMPT_USER} \
	${SMPT_ENCRYPTION} \
	${TEST_OPTION} \
	${OPTIONS} \
	$@
#	--from=${FROM_LIST} \	
#	--smtp-user= \
#	--smtp-debug \
#	--in-reply-to==${REPLY_TO} \
