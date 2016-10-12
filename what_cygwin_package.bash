#/usr/bin/env bash
SCRIPTNAME='Cygwin Tool Package Finder'
LAST_UPDATED='2016-09-19'
# Author: Michael Chu, https://github.com/michaelgchu/
#
# Determine what package a particular tool may be found in
# Final call looks like this:
#	cygcheck --package-query '/\(colordiff\|wdiff\).exe'

if [ -z "$1" -o "$1" = '-h' ] ; then
	echo "Provide the name(s) of the tools you want to search for."
	echo "e.g. ${0##*/} diff colordiff wdiff"
	exit 0
fi

tools=$(sed --regexp-extended 's/ +/\\|/g' <<< $*)

cygcheck --package-query '/\('"$tools"'\).exe'

#EOF
