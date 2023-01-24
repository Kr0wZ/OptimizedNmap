#!/bin/bash

ip="${1}"
portL=""

#First scan to detecte the top 3500 ports. Why the top 3500? -> https://nmap.org/book/performance-port-selection.html
#You can also replace this option with -p- to be sure to scan and find all the open TCP ports
echo "Scanning open TCP ports"

#You may adapt the --min-rate value depending on you.
nmap --top-ports 3500 --min-rate 5000 $ip > firstScan

while read line
do
	if [[ ${line:0:1} =~ [0-9] ]]
	then
		portL="${portL}${line%%/*},"
	fi
done < firstScan
echo $portL

#Second scan to scan with default and version scans only the open ports
echo "Scanning protocols and versions on open TCP ports"
nmap -p $portL -sC -sV --min-rate 5000 $ip

rm firstScan


portL=""
#Third scan to detecte all the UDP open ports
#--version-intensity -> https://nmap.org/book/scan-methods-udp-scan.html#scan-methods-udp-optimizing
echo "Scanning open UDP ports"
nmap -sU --min-rate 500 --version-intensity 0 $ip > secondScan

while read line
do
	if [[ ${line:0:1} =~ [0-9] ]]
	then
		portL="${portL}${line%%/*},"
	fi
done < secondScan
echo $portL

#Fourth scan to scan with default scans only the open ports
echo "Scanning protocols and versions on open UDP ports"
nmap -p $portL -sU -sC -sV --min-rate 500 $ip

rm secondScan
