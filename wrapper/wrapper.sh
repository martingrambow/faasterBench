counter=1
count=$1
text=""
write=false
for var in "$@"
do
    echo $var
    if $write ; then
        echo "true"
        text+=" \"$var\""
        write=false
    fi
    if [[ "$var" == "-f" ]]; then
        write=true
        text+=" -f"
    fi
    if [[ "$var" == "-s" ]]; then
        write=true
        text+=" -s"
    fi
    if [[ "$var" == "-a" ]]; then
        echo "Found -a"
        text+=" -a"
        
    fi
    if [[ "$var" == "-i" ]]; then
        write=true
        echo "Found -i"
        text+=" -i"
        
    fi
    counter=$((counter + 1))
    count="$"$counter
done
echo $text
java -jar wrapper.jar $text
