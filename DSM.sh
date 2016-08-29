#!/bin/bash

Version="0.1.0"
Percent=90

read -d '' HelpMessage << EOF
Diffie, Shapiro, and Martin (DSM) Tool v$Version
================================================
Using your RSA SSH keypair is 'good enough' security for all persons who are not
paranoid about major governments using quantum computers to find their nud3z.

Usage:
------
--help (-h): Display this message

./DSM enc <File> <key bit length> [public PEM]
./DSM dec <File> [private PEM]

EOF

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
   echo ""
   echo "$HelpMessage"
   exit
fi

if [[ "$1" == "--version" ]];then
   echo ""
   echo "Version: $Version"
   echo "md5 (less last line): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
   exit
fi

if [ $# -lt "2" ]; then
   echo "[ERROR] look at command. This tool needs at least 2 args!"
else
   PassedKeyLen=$3
   if [[ "$1" == "enc" ]]; then
      keyStrength=$(($PassedKeyLen*$Percent/100))
      echo "Encrypting $2 with a keystrength of $keyStrength"
      split -b $keyStrength $2 --additional-suffix=_DSMENC_$2
      count=1
      for DSMFiles in `ls | grep "_DSMENC_"`; do
         echo "Encrpyting $DSMFiles as $count.DSM"
         if [[ "$4" == "" ]]; then
            cat $DSMFiles | openssl rsautl -encrypt -inkey ~/.ssh/id_rsa.pub.pem -pubin -out $count.DSM
         else
            cat $DSMFiles | openssl rsautl -encrypt -inkey $4 -pubin -out $count.DSM
         fi
         count=$((count+1))
         rm $DSMFiles
      done
   elif [[ "$1" == "dec" ]]; then
      if [ -f $2 ]; then
         NewFile=$2_DSM_Didnt_replace
      else
         NewFile=$2
      fi
      count=1
      for DSMFiles in `ls -1v *.DSM`; do
         echo "Decrypting $DSMFiles in $NewFile"
         if [[ "$3" == "" ]]; then
            openssl rsautl -decrypt -inkey ~/.ssh/id_rsa.pem -in $DSMFiles >> $NewFile
         else
            openssl rsautl -decrypt -inkey $3 -in $DSMFiles >> $NewFile
         fi
         count=$((count+1))
         #rm $DSMFiles -- dangerous!
      done
   fi
   echo ""
   echo "Well I hope it did something..."

fi

### Current File MD5 (less this line): 3d2635d2402af7f64f0838967bfc5f6b
