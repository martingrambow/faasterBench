if [ -z "$1" ] 
then 
    java -jar wrapper.jar 
else 
    if [ -z "$3" ]
    then
        java -jar wrapper.jar -f $1 -s $2 
    else
        java -jar wrapper.jar -f $1 -s $2 -a 
        echo "here"
    fi
fi
