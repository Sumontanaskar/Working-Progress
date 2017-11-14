#!/bin/bash
#cp lastFile.html lastLastFile.html
url="https://www.theiphonewiki.com/wiki/Models"
Email="sumonta@***.com"
curl -o lastFile.html $url 
log=$(diff -c lastFile.html lastLastFile.html)
if [ -z $log ] ; then
        echo "String null"
	echo $log
else
	echo "Difference found"
	mail -s "Website Difference found" $Email<<< $log
        echo "Email sent."
fi
