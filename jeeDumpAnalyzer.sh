#!/bin/bash
#set -x
####Environment Instantiation
TOOL_HOME="/apps/tools/jeeDumpAnalyzer/"
MAT_HOME="${TOOL_HOME}/eclipseMAT/"
REPORT_HOME="${TOOL_HOME}/reports/"
DUMP_HOME="${TOOL_HOME}/dumpStore/"

if [ ! -f ${MAT_HOME}/MemoryAnalyzer ];
then
        echo -e "The Memory Analyzer Home is invalid"
        echo -e "Terminating Execution"
        exit 0
fi

#Checking running instance of engine
if [ `ps -ef | grep heapAnalyzer.sh | grep -v grep | wc -l` -ne 0 ];
then
        echo -e "An instance of the engine is already running"
        echo -e "Terminating Execution"
        exit 0
fi
if [[ `ls -ltr ${DUMP_HOME}/*.hprof | wc -l` -ne 0 ]];
then
        for dumpFile in ${DUMP_HOME}/*.hprof
        do
                echo ${dumpFile}
                if [[ `file ${dumpFile} | awk -F ': ' '{print $NF}'` != 'data' ]];
                then
                        echo -e "The File Provided is of Invalid File Type"
                        echo -e "Terminating Execution"
                        exit 0
                fi
                nohup sh /apps/tools/jeeDumpAnalyzer/heapAnalyzer.sh ${dumpFile} senthil.nathanm@yahoo.com &
        done
fi
exit 0

