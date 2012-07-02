#!/bin/bash

###
# jskonoha runtime for gjstest
###

PROGRAM=`basename $0`

while getopts j:k:o:x OPT
do
	case $OPT in
		"j" ) FLG_J="TRUE" ; VALUE_J="$OPTARG" ;;
		"k" ) FLG_K="TRUE" ; VALUE_K="$OPTARG" ;;
		"o" ) FLG_O="TRUE" ; VALUE_O="$OPTARG" ;;
		"x" ) FLG_X="TRUE" ;;
		* ) OPT_ERROR=1; break;;
	esac
done

# set runtime
if [ "$FLG_J" = "TRUE" ]; then
	JSKONOHA=$VALUE_J
else
	OPT_ERROR=1
fi

# set imput file
if [ "$FLG_K" = "TRUE" ]; then
	SCRIPT=$VALUE_K
else
	OPT_ERROR=1
fi

if [ $OPT_ERROR ]; then
	echo "Usage: $PROGRAM [-x] [-o output] -j jskonoha.js -k script.k"
	exit 1
fi

# set type
if [ "$FLG_X" = "TRUE" ]; then
	EXPORT="xml"
else
	EXPORT="html"
fi

# set output
if [ "$FLG_O" = "TRUE" ]; then
	OUTPUT=${VALUE_O}
else
	OUTPUT=${SCRIPT}.${EXPORT}
fi

TMPFILE=`mktemp /tmp/${PROGRAM}.XXXXXX` || exit 1
TESTNAME=`echo $SCRIPT | sed -e 's/.*[^\/]*[\/]\([^\/]*\)$/\1/g' | sed -e 's/\./_/g'`

cat << _EOT_ > $TMPFILE
function ${TESTNAME}_test() {}
registerTestSuite(${TESTNAME}_test);
${TESTNAME}_test.prototype.RunKonohaTest = function() {
	var script = "\\
_EOT_

while read line; do
	echo "${line}" ' \\n \\' | sed -e 's/"/\\"/g' >> $TMPFILE
done <${SCRIPT}

cat << _EOT_ >> $TMPFILE
";
	var ret = konoha.eval(script);
}
_EOT_

echo "gjstest --js_files=${JSKONOHA},${TMPFILE} --${EXPORT}_output_file=${OUTPUT}"
gjstest --js_files=${JSKONOHA},${TMPFILE} --${EXPORT}_output_file=${OUTPUT}
