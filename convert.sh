read i
if [ "$i" != "timesheet" ]; then
    echo "only can convert timesheet files"
    exit 1
fi
while read i; do
    echo "`echo $i | cut -c1-19`,`echo $i | cut -c21-39`,\"`echo $i | cut -c41-`\""
done

