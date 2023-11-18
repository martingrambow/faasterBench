if [ -z "$1" ] 
then 
    java -jar wrapper.jar 
else 
    java -jar wrapper.jar -f $1 -s $2 
fi
