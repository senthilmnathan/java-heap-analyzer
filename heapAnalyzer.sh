#!/bin/bash
set -x
dumpFile=$1
emailID=$2
DATE=`date +"%m_%d_%y_%T" | tr ':' '_'`
fileName=`echo ${dumpFile} | awk -F/ '{print $NF}' | cut -d '.' -f1`
###Environment Declaration###
TOOL_HOME="/apps/tools/jeeDumpAnalyzer/"
MAT_HOME="${TOOL_HOME}/eclipseMAT/"
REPORT_HOME="${TOOL_HOME}/reports/"
DUMP_HOME="${TOOL_HOME}/dumpStore/"
ARCHIVE_HOME="${TOOL_HOME}/archive"
mkdir -p ${REPORT_HOME}/${DATE}
mkdir -p ${ARCHIVE_HOME}/${DATE}
#Parsing The Heap Dump File
cd ${MAT_HOME}
sh ${MAT_HOME}/ParseHeapDump.sh ${dumpFile}
if [ $? -ne 0 ];
then
        echo -e "Something Went Wrong with Parsing the heap dump file, ${fileName}\nReview The Logs\nTerminating Execution" | mailx -s "Heap Analysis Report - Failure" ${emailID}
        echo -e "Review The Logs"
        echo -e "Terminating Execution"
        exit 0
fi
cd ${TOOL_HOME}
${MAT_HOME}/jre/bin/java -Xms15360m -Xmx15360m -DhprofStrictnessWarning=true -Dosgi.bundles=org.eclipse.mat.dtfj@4:start,org.eclipse.equinox.common@2:start,org.eclipse.update.configurator@3:start,org.eclipse.core.runtime@start -jar ${MAT_HOME}/plugins/org.eclipse.equinox.launcher_*.jar -consoleLog -application org.eclipse.mat.api.parse ${dumpFile} org.eclipse.mat.api:overview
if [ $? -ne 0 ];
then
        echo -e "Something Went Wrong with running Overview API for the dump file, ${dumpFile}\nReview The Logs\nTerminating Execution" | mailx -s "Heap Analysis Report - Failure" ${emailID}
        echo -e "Review The Logs"
        echo -e "Terminating Execution"
        exit 0
fi
${MAT_HOME}/jre/bin/java -Xms4096m -Xmx15360m -DhprofStrictnessWarning=true -Dosgi.bundles=org.eclipse.mat.dtfj@4:start,org.eclipse.equinox.common@2:start,org.eclipse.update.configurator@3:start,org.eclipse.core.runtime@start -jar ${MAT_HOME}/plugins/org.eclipse.equinox.launcher_*.jar -consoleLog -application org.eclipse.mat.api.parse ${dumpFile} org.eclipse.mat.api:top_components
if [ $? -ne 0 ];
then
        echo -e "Something Went Wrong with running Top Components API for the dump file, ${dumpFile}\nReview The Logs\nTerminating Execution" | mailx -s "Heap Analysis Report - Failure" ${emailID}
        echo -e "Review The Logs"
        echo -e "Terminating Execution"
        exit 0
fi
${MAT_HOME}/jre/bin/java -Xms4096m -Xmx15360m -DhprofStrictnessWarning=true -Dosgi.bundles=org.eclipse.mat.dtfj@4:start,org.eclipse.equinox.common@2:start,org.eclipse.update.configurator@3:start,org.eclipse.core.runtime@start -jar ${MAT_HOME}/plugins/org.eclipse.equinox.launcher_*.jar -consoleLog -application org.eclipse.mat.api.parse ${dumpFile} org.eclipse.mat.api:suspects
if [ $? -ne 0 ];
then
        echo -e "Something Went Wrong with running Suspects API for the dump file, ${dumpFile}\nReview The Logs\nTerminating Execution" | mailx -s "Heap Analysis Report - Failure" ${emailID}
        echo -e "Review The Logs"
        echo -e "Terminating Execution"
        exit 0
fi
mv -f ${DUMP_HOME}/*.zip ${REPORT_HOME}/${DATE}
echo -e "The analysis of ${fileName} is complete\n\nThe 3 reports are attached thusly\n\nRegards\njeeDumpAnalyzer" | mailx -s "Heap Analysis Report" -a ${REPORT_HOME}/${DATE}/${fileName}_System_Overview.zip -a ${REPORT_HOME}/${DATE}/${fileName}_Leak_Suspects.zip -a ${REPORT_HOME}/${DATE}/${fileName}_Top_Components.zip ${emailID}
###Housekeeping
rm -Rf ${DUMP_HOME}/*.index
rm -f ${DUMP_HOME}/*.threads
mv -f ${dumpFile} ${ARCHIVE_HOME}/${DATE}/

