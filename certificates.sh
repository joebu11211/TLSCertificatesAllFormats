#!/bin/bash
KEY=$1
CERT=$2
CHAIN=$3
APPName=$4
STOREPASS=$5
RSAPASS=$6
PKCS12=${APPName}.pfx
PKCS12RSA=${APPName}_RSA.pfx
JKS=${APPName}.jks
JKSRSA=${APPName}_RSA.jks
RSAKEY=${KEY}_RSA.key
TEXTOUT=${APPName}.txt
ZIP=${APPName}.zip
echo "First Arguments: " $1 $KEY
echo "$KEY is the RSA Key without a password"
echo "$CERT is the SSL Certificate for the server"
echo "$CHAIN is the Certificate Chain to the CA"
echo "Creating PFX file without RSA Password"
echo "First Arguments: " $1 $KEY >> $TEXTOUT
echo "$KEY is the RSA Key without a password" >> $TEXTOUT
echo "$CERT is the SSL Certificate for the server" >> $TEXTOUT
echo "$CHAIN is the Certificate Chain to the CA" >> $TEXTOUT
echo "Creating PFX file without RSA Password" >> $TEXTOUT
openssl pkcs12 -export -out ./$PKCS12 -inkey $KEY -in $CERT -certfile $CHAIN -passout pass:$STOREPASS
echo "$PKCS12 created with $STOREPASS as the password"
echo "Creating RSA With Password $RSAPASS"
echo "$PKCS12 created with $STOREPASS as the password" >> $TEXTOUT
echo "Creating RSA With Password $RSAPASS"  >> $TEXTOUT
openssl rsa -aes256 -in $KEY -out ./$RSAKEY -passout pass:$RSAPASS
echo "Creating PFX file with RSA Password"
echo "Creating PFX file with RSA Password" >> $TEXTOUT
openssl pkcs12 -export -out ./$PKCS12RSA -inkey $RSAKEY -passin pass:$RSAPASS -in $CERT -certfile $CHAIN -passout pass:$RSAPASS
echo "Created PFX $PKCS12RSA with RSA Pass $RSAPASS and PFX Password of $RSAPASS"
echo "Creating JKS file without RSA Password for Tomcat"
echo "Created PFX $PKCS12RSA with RSA Pass $RSAPASS and PFX Password of $STOREPASS" >> $TEXTOUT
echo "Creating JKS file without RSA Password for Tomcat" >> $TEXTOUT
keytool -importkeystore -srckeystore $PKCS12 -destkeystore ./$JKS -srcstoretype pkcs12 -srcstorepass $STOREPASS -deststorepass $STOREPASS
keytool -changealias -keystore $JKS -storepass $STOREPASS -alias 1 -destalias tomcat
echo "Created JKS $PKCS12 with password $STOREPASS"
echo "Creating JKS file with RSA Password"
echo "Created JKS $PKCS12 with password $STOREPASS" >> $TEXTOUT
echo "Creating JKS file with RSA Password" >> $TEXTOUT
keytool -importkeystore -srckeystore $PKCS12RSA -destkeystore $JKSRSA -srcstoretype pkcs12 -srckeypass $RSAPASS -srcstorepass $RSAPASS -deststorepass $RSAPASS -alias 1
keytool -changealias -keystore $JKSRSA -storepass $RSAPASS -alias 1 -destalias weblogic
echo "Created JKS $JKSRSA with password $RSAPASS and RSA Pass of $RSAPASS"
echo "Created JKS $JKSRSA with password $RSAPASS and RSA Pass of $RSAPASS" >> $TEXTOUT
zip $ZIP $KEY $CERT $CHAIN $PKCS12 $PKCS12RSA $JKS $JKSRSA $RSAKEY $TEXTOUT
sleep 10