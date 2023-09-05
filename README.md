# TLSCertificatesAllFormats
Bash shell script to turn a passwordless key file in pem format, a Intermediate/Root certificate, and a server certificate into multiple formats ready for use with Tomcat, Weblogic, IIS, Salesforce, Java, etc.

# Formats Provided
1. PEM
2. PFX
3. JKS
4. JKS with RSA

# Prerequisites
1. Java installed with Keytool application available by calling keytool
2. OpenSSL

# Usage Example
./certificates.sh $Key $ServerCertifciate $IntermediateRootCertifciate $AppName $StorePass $RSAPASS

$Key = path to key file

$ServerCertificate = path to PEM server certficate (stand alone so only one cert in the file)

$IntermediateRootCertificate = path to PEM intermediate/root certificate where all needed certificates would reside

$AppName = Name of the application this is for or what you want the file to be saved as

$StorePass = Password for the Java keystore

$RSAPass = Password for the RSA portion of the Java keystore (needed for weblogic)
