#!/bin/sh
#
# $Id$

LDAP_URI="ldaps://ldap.glencoesoftware.com:389"
BIND_DN="cn=foo"
BIND_DN_PASS="blah"
BASE="dc=glencoesoftware,dc=com"
export LDAPTLS_REQCERT=never

set -x
ldapsearch -a always -LLL -Z -H ${LDAP_URI} -o ldif-wrap=no -D "${BIND_DN}" -b "${BASE}" -w\'${BIND_DN_PASS}\' "$@"
