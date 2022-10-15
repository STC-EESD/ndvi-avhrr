#!/bin/bash

##################################################
currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
  dataDIR=${parentDIR}/000-data

if [ ! -d ${outputDIR} ]; then
        mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

##################################################
cd ${outputDIR}
sleep 2
myShellScript=./code/wget-ndvi-avhrr.sh
stdoutFile=stdout.sh.`basename ${myShellScript} .sh`
stderrFile=stderr.sh.`basename ${myShellScript} .sh`
myShellScript > ${stdoutFile} 2> ${stderrFile}
