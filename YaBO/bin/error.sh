#!/bin/bash
/usr/bin/htop ;
B=$?
if [ $B = 0 ] ;
    
then echo 'Zero' ;
elif [ $B != 0 ] ;
then echo 'Oh, shit.' ;
fi;

echo $B
