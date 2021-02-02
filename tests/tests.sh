#!/bin/sh

AWK=`which gawk || which nawk || which awk`
DIFF=$(which gdiff || which diff)

NORMAL="tput sgr0"
RED="tput setaf 1"
GREEN="tput setaf 2"

passed=0
failed=0

echo
echo 'Running tests'
echo '----------------------------------------'
echo
echo " -- running tests with: ${AWK}"
echo

cd tests

TMPDIR=$(mktemp -d)

for i in [0-9]*.in
do
	name=`basename $i .in`
	outfile="$TMPDIR/${name}.out"
	infile="${name}.in"
	reffile="${name}.ref"

	${AWK} -f ../awkdown "$infile" > "$outfile"

	${DIFF} -q "$reffile" "$outfile" 2>/dev/null 1>&2
	if [ $? = 0 ]
	then
		echo "$($GREEN)${name} OK$($NORMAL)"
		passed=$(expr $passed + 1)
	else
		echo "\n$($RED)${name} FAILED!$($NORMAL)"
		echo "Expected in green, actual output in red"
		${DIFF} --color "$outfile" "$reffile"
		echo "\n"
		failed=$(expr $failed + 1)
	fi

done

echo
echo '----------------------------------------'
echo "$passed tests passed, $failed failed\n\n"
