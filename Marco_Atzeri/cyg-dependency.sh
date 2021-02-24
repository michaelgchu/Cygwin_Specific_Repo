#!/bin/bash
#Copyright (c) 2021, Marco Atzeri
#All rights reserved.

#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#3. All advertising materials mentioning features or use of this software must display the following acknowledgement: This product includes software developed by Marco Atzeri.
#4. Neither the name of the Marco Atzeri nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY MARCO ATZERI ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MARCO ATZERI BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ $# -ne 1 ]
then
    echo "Usage : " $0 "file_name"
    echo "Find package dependency from dll dependency"
    exit 1
fi 

a=1
# mypath=$(echo $PATH | tr ":" " ")
mypath="/usr/bin /usr/lib/lapack"
windir=$(cygpath -u ${WINDIR})"/System32"

for i in  $(objdump -x $1 |grep "DLL Name:" |sed -e "s/\tDLL Name: //g"| tr "\r" " " ) 
do
  if [ $i = "KERNEL32.dll" ]
  then
            echo -n $i 
            echo -n  "  =>  "
	    echo " Windows System"
  else
    fullname=$(find ${mypath}  -maxdepth 1 -name $i)	
    if [ -z "${fullname}" ]
    then
	fullname=$(find ${windir} -maxdepth 1 -iname $i)
	if [ -z "${fullname}" ]
	then
            echo -n $i 
	    echo "  =>  NOT on PATH, Unknown"
        else
            echo -n $i 
            echo -n  "  =>  "
	    echo " Windows System"
        fi
    else
        echo -n $fullname 
        echo -n  "  =>  "
        package=$(cygcheck -f $fullname )
	if [ -z "$package" ]
	then
	    echo "NOT on ANY Package (system one?)"
	else
	    echo $package
	fi 
    fi
  fi
done


