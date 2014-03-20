passed=0

echo
echo 'Running tests'
echo '----------------------------------------'
echo

for i in [0-9]*.in
do
    name=`basename $i .in`
    echo -n "${name}: "

    nawk -f ../awkdown.awk ${name}.in > /tmp/${name}.out

    diff /tmp/${name}.out ${name}.ref && echo "OK!"
    if [ $? = 0 ]
    then
	passed=`expr $passed + 1`
    else
	echo "Test $i FAILED!"
    fi

    rm /tmp/${name}.out

done

echo
echo '----------------------------------------'
echo "$passed tests passed!"
echo
