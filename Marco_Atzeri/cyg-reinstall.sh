#!/bin/bash
#Copyright (c) 2021, 2023 Marco Atzeri
#All rights reserved.

#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#3. All advertising materials mentioning features or use of this software must display the following acknowledgement: This product includes software developed by Marco Atzeri.
#4. Neither the name of the Marco Atzeri nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY MARCO ATZERI ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MARCO ATZERI BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Create a batch file to reinstall using setup-{ARCH}.exe
# all packages or the ones reported as incomplete
# or install from a list or remove from a list

# If you hit the length limit of command line in bash or CMD
#
# https://devblogs.microsoft.com/oldnewthing/20031210-00/?p=41553
# https://learn.microsoft.com/en-us/troubleshoot/windows-client/shell-experience/command-line-string-limitation
#
# the best way is to split the installation in multiples chunks

print_error=1

if [ $# -eq 1 ]
  then
    if [ $1 == "-I" ]
    then
      lista=$(mktemp)
      cygcheck -c | grep "Incomplete" > $lista
      print_error=0
    fi
    if [ $1 == "-A" ]
    then
      lista=$(mktemp)
      cygcheck -cd | sed -e "1,2d" > $lista
      print_error=0
    fi
fi

if [ $# -eq 2 ]
  then
    if [ $1 == "-f" -o $1 == "-r" ]
    then
      lista=$2
      print_error=0
    fi
fi

# error message if options are incorrect.
if [ $print_error -eq 1 ]
then
        echo -n "Usage : " $(basename $0)
        echo " [ -A | -I | -f filelist | -r filelist ]"
        echo "  create cyg-reinstall-{ARC}.bat from"
        echo "  options"
        echo "    -A  :  install All packages as reported by cygcheck"
        echo "    -I  :  install Incomplete packages as reported by cygcheck"
        echo "    -f  :  install packages in filelist (one per row)"
        echo "    -r  :  remove packages in filelist (one per row)"
        exit 1
fi

if [ $(arch) == "x86_64" ]
then
  A="x86_64"
else
  A="x86"
fi

# writing header
echo -n -e "setup-${A}.exe  " > cyg-reinstall-${A}.bat

# option  -x remove and  -P install
# for re-install packages we need both
if [ $1 == "-I" -o $1 == "-r" ]
then
  awk 'BEGIN{printf(" -x ")} NR==1{printf $1}{printf ",%s", $1}' ${lista} >> cyg-reinstall-${A}.bat
fi

if [ $1 == "-I" -o $1 == "-A" -o $1 == "-f" ]
then
  awk 'BEGIN{printf(" -P ")} NR==1{printf $1}{printf ",%s", $1} END { printf "\r\n pause "}' ${lista} >> cyg-reinstall-${A}.bat
fi

# execution permission for the script
chmod +x cyg-reinstall-${A}.bat

