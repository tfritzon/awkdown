AWK=`which gawk || which nawk || which awk`

passed=0

echo
echo 'Running tests'
echo '----------------------------------------'
echo
echo " -- running tests with: ${AWK}"
echo

for i in [0-9]*.in
do
    name=`basename $i .in`
    printf "%s: " ${name}

    ${AWK} -f ../awkdown ${name}.in > /tmp/${name}.out

    diff /tmp/${name}.out ${name}.ref && echo "OK!"
    if [ $? = 0 ]
    then
	passed=`expr $passed + 1`
        rm /tmp/${name}.out
    else
	echo "Test $i FAILED!"
    fi

done

echo
echo '----------------------------------------'
echo "$passed tests passed!"
echo
