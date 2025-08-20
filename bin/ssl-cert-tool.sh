#!/bin/sh
#
# $Id$
#!/bin/bash

for x in $*; do
	ext="${x##*.}"
	echo -n "${x}: "
	case "${ext}" in
		crt|pem)
			openssl x509 -nouout -modulus -in ${x} | openssl md5
			;;
		key)
			openssl rsa -noout -modulus -in ${x} | openssl md5
			;;
		*)
			echo "Unknown certificate format"
			exit 1
			;;
	esac
done

