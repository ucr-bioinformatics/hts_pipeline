#!/bin/bash

#####################################################
# Simple script to send outgoing email via sendmail #
#####################################################

MAIL_TPL=$1

/usr/sbin/sendmail -vt < $MAIL_TPL

