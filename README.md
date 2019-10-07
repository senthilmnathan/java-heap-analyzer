# java-heap-analyzer

# Introduction
Analyzing a java heap dump file is one of the most resource intensive operations performed by middleware administrators. While there are several open source and proprietary solutions available for this purpose, choosing the right tool as well as the analysis approach is essential in successful problem determination. In several cases, a typical heap dump file size may go as high as 20 GB which invariably require an enterprise class environment to analyze them.

# Available Tools
There are various tools available in the market today which have a varied set of benefits and drawbacks. Some of these tools are listed below.

|Tool|Features|Advantages|Disadvantages|
|----|--------|----------|-------------
|Java Heap Analysis Tool (JHAT)| <ul><li>Part of Oracle HotSpot JDK</li><li>Open Source</li><li>Supports multiple versions of JDK</li></ul> | <ul><li>Simple and easy to use</li><li>Command line controls</li><li>Low overhead</li></ul> | <ul><li>No GUI</li><li>Report is more verbose and complex</li><li>Inflexible</li></ul> |
|Java VisualVM|<ul><li>Part of Oracle HotSpot JDK</li><li>Open Source</li><li>Supports multiple versions of JDK</li></ul>|<ul><li>Supports GUI</li><li>Supports Windows and Linux</li><li>Simplified Output</li></ul>|<ul><li>Requires user Interaction</li><li>Does not support automated analysis and reporting</li><li>Requires X Windows Support in Linux</li></ul>|
|Eclipse MAT|<ul><li>Open Source</li><li>Supports various flavours of Java</li><li>Part of Eclipse Foundation</li></ul>|<ul><li>Supports both automated and UI analysis</li><li>Elegant and simplified report generation</li><li>Supports enterprise class heap file analysis</li></ul>|<ul><li>No Support for the tool</li><li>No unified tool available for scheduling and reporting</li></ul>|

After comparing the features of the above mentioned tools, Eclipse Memory Analyzer (MAT) was choosen for use in ICON. In order to overcome some of the limitations of the tool, a custom scheduler was developed to offer a fully automated and simplified heap dump analysis tool.

# Automated Heap Dump Analysis and Reporting
The basic architecture and functioning is explained in brief here.
- 3 Eclipse MAT APIs are executed from a linux BASH shell script to parse and analyze the heap dump file
- Once the analysis is completed, the 3 reports generated are emailed to the Middleware group email ID
- The only user interaction required is for the administrator to copy the heap dump file in a specific folder 
- The analysis can be optionally scheduled to run in crontab
![Tool Architecture](https://github.com/senthilmnathan/java-heap-analyzer/blob/master/architecture.png)

# Tool Contents
## jeeDumpAnalyzer.sh
This is the primary script which is scheduled in crontab. It performs various sanity checks and if any new dump files are found in /apps/tools/jeeDumpAnalyzer/dumpStore invokes the heapAnalyzer.sh script in background

## heapAnalyzer.sh
This script uses the eclipse MAT tools to both parse the large heap dump file and analyze them later. it invokes three APIs of MAT to generate the System Overview Report, Top Components Report and Leak Suspects Report

## reports
The reports are stashed in this folder and stored in unique date specific folders

## archive
Once a given heap dump file in dumpStore directory is successfully analyzed, it is archived to this location

## eclipseMAT
This is the core of the analyzer tool. The bundle is downloaded from eclipse and packaged with the latest JAVA 1.8 JDK which is in eclipseMAT/jre

## dumpStore
As stated earlier, this is the location where administrator should copy the heap dump file

## jeeDumpAnalyzer.log
The run time steps of heapAnalyzer.sh script is saved in this file. Any errors or failures can be troubleshooted using this file.

## jeeDumpAnalyzer.err
Any run time errors in executing the jeeDumpAnalyzer.sh file will be saved here.

## Steps for Dump File Analysis
- Copy the heap dump file to dumpStore
- If email is configured the report will be delivered to the designated email ID
- The report can also be found in reports directory

## Enhancements
- Developers proficient in Java programming can create a JSP based interface which can encapsulate the entire complexity of tool interation
- This can also be integrated with ticket based systems like ServiceNow using API calls
