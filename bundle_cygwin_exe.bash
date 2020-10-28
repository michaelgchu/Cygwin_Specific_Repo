#!/usr/bin/env bash
SCRIPTNAME='Cygwin Executable Bundler'
LAST_UPDATED='2020-10-28'
# Author: Michael Chu, https://github.com/michaelgchu/
# See Usage() function for purpose and calling details
#
# Updates
# =======
# 20201028
# - added -d option to copy dependencies only, and skip copying the executable/library specified.
# 20161012
# - using long argument names when calling commands; cleaned up comments
# 20160425
# - adjustments to coding and documentation
# 20141219
# - Bug fix: filter cygcheck output to include only results from paths containing 'cygwin'
# 20141216
# - Added extra documentation, creation of destination folder
# - Improved coding of the say() function (now using built-in Bash functionality)
# 20141215
# - First version


shopt -s expand_aliases
alias  debugsay='test $DEV_MODE = "yes" && echo '

# -------------------------------
# "Constants", Globals
# -------------------------------

# Whether to suppress standard script messages
Be_Quiet=false

# Whether to copy dependencies only.
Deps_Only=false

DEV_MODE='no'

# Listing of all required tools.  The script will abort if any cannot be found
requiredTools='cygpath cygcheck grep sed sort tr cp which'

# -------------------------------
# Functions
# -------------------------------

Usage()
{
	printTitle
	cat << EOM
Usage: ${0##*/} [options] cygwinCommand folderToWriteTo

Create a bundled "portable" copy of the specified Cygwin executable or library,
for running without a full Cygwin installation.  (Copies the .exe/.dll and all
required Cygwin DLL files into the provided path.)

To use bundled commands in Windows CMD, enter the directory and simply call the
tool by name.  e.g. Assuming you had bundled 'cut' into C:\TEMP\bundle, you
could do this:
	cd \TEMP\bundle
	cut -f2-4 -d, C:\Users\jdoe\mydata.csv

By bundling the Bash executable along with other tools, you can have a limited
Bash environment.  Double-click on the bash.exe file to open a Bash shell
within the standard Windows console window.  Programs/scripts in the same
bundle directory can be accessed using  './'
To be able to work with files easily with the scripts, use cygpath
You can also open a Windows CMD prompt, browse to the bundle directory, and
start up the script like so:
	bash <name of script> [arguments]

OPTIONS
=======
   -h    Show this message
   -q    Quiet: only output the found records and a header
   -d    Dependencies only: don't copy the actual DLL/execuable specified
   -D    DEV/DEBUG mode on
         Use twice to run 'set -x'

EOM
}


say()
{
# Output the provided message only if Be_Quiet = 'no', i.e. if script not called with -q option
# The first argument can be a flag for echo, e.g. -e to do escape sequences, -n to not echo a newline
	test $Be_Quiet = 'no' || return
	if [ "${1:0:1}" = '-' ] ; then
		flag=$1
		shift
	else
		flag=''
	fi
	echo $flag "$*"
}


printTitle()
{
	title="$SCRIPTNAME ($LAST_UPDATED)"
	echo "$title"
	printf "%0.s-" $(seq 1 ${#title})
	echo 
}


# ************************************************************
# Begin Main Line
# ************************************************************

# Process script args/settings
Be_Quiet='no'
while getopts ":hqdD" OPTION
do
	case $OPTION in
		h) Usage; exit 0 ;;
		q) Be_Quiet='yes' ;;
        d) Deps_Only=true ;;
		D) test $DEV_MODE = 'yes' && set -x || DEV_MODE='yes' ;;
		*) echo "Warning: ignoring unrecognized option -$OPTARG" ;;
	esac
done
shift $(($OPTIND-1))

if [ $Be_Quiet = 'no' ] ; then
	printTitle
	copyOpts='--verbose'
else
	copyOpts=''
fi

# Get inputs
exe="$1"
dir="$2"
test -n "$dir" || {
	echo 'Specify the Cygwin binary to package up and the directory to copy all required files to.';
	echo "Run '${0##*/} -h' for more details."
	exit 1;
}

# Test for all required tools/resources
debugsay "[Testing for required command(s): $requiredTools]"
flagCmdsOK='yes'
for cmd in $requiredTools
do
	hash $cmd &>/dev/null || { echo "Error: command '$cmd' not present"; flagCmdsOK=false; }
done
# Abort if anything is missing
test $flagCmdsOK = 'yes' || exit 1

say "Checking inputs ..."
say "  Identifying executable '$exe' ..."
hash "$exe" &>/dev/null || { echo "Error: command '$exe' not present - abort"; exit 1; }
if [ -d "$dir" ] ; then
	say "  Testing permissions on directory '$dir' ..."
	test -w "$dir" || { echo "Error: '$dir' is not writeable - abort"; exit 1; }
else
	test -e "$dir" && { echo "Error: '$dir' exists and is not a directory - abort"; exit 1; }
	say "  Creating directory '$dir' ..."
	mkdir --parents "$dir" || { echo "Error: could not create dir '$dir' - abort"; exit 1; }
fi

say "Identifying the files to copy for Cygwin binary '$exe' ..."
# Explanation:
# - cygcheck: produces the listing of all DLL files required, for each matching executable
# - grep: filters to include only entries with the 'cygwin*' path
# - grep (if deps only): removes specified file from list to copy only dependencies
# - sed: clean up cygcheck output for use in the copy command
#	("Found" appears if a full path isn't provided)
# - sort: remove duplicates
if [ $Deps_Only = false ] ; then
	filelist=$(cygcheck "$exe" | grep --ignore-case '\\cygwin' | sed 's/^Found: //; s/^ *//' | sort --unique)
else
    exefullpath=$(cygpath --absolute --windows "$exe")
    filelist=$(cygcheck "$exe" | grep -vF "$exefullpath" | grep --ignore-case '\\cygwin' | sed 's/^Found: //; s/^ *//' | sort --unique)
fi

say "Copying all the files to the output folder '$dir' ..."
udir=$(cygpath --absolute --unix "$dir")
flagAllOK=true
# The  -r  flag for the read command allows backslashes to pass through
while read -r filename
do
	spath=$(cygpath --absolute --unix "$filename")
	cp --no-clobber $copyOpts "$spath" "$udir"
	test $? -eq 0 || flagAllOK=false
done << EOM
$filelist
EOM

if [ $flagAllOK ] ; then
	echo "Packaging of executable '$exe' successful."
	exit 0
else
	echo "Errors encountered while packaging executable '$exe'."
	exit 1
fi

#EOF
