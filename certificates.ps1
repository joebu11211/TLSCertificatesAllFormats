# Check if keytool and openssl are available
if (-not (Test-Path -Path "keytool.exe")) {
    Write-Host "Error: 'keytool' is not found. Make sure you have the Java JDK installed and 'keytool' is in your PATH."
    exit 1
}

if (-not (Test-Path -Path "openssl.exe")) {
    Write-Host "Error: 'openssl' is not found. Make sure you have OpenSSL installed and 'openssl' is in your PATH."
    exit 1
}

# Input Variables
$KEY = $args[0]  # Path to Key File
$CERT = $args[1]  # Path to Server Certificate
$CHAIN = $args[2]  # Path to Intermediate/Root Certificate
$APPName = $args[3]  # Name of application or output files
$STOREPASS = $args[4]  # Password for keystores
$RSAPASS = $args[5]  # RSA Passwords

# Formatting Variables
$PKCS12 = $APPName + ".pfx"
$PKCS12RSA = $APPName + "_RSA.pfx"
$JKS = $APPName + ".jks"
$JKSRSA = $APPName + "_RSA.jks"
$RSAKEY = $KEY + "_RSA.key"
$TEXTOUT = $APPName + ".txt"
$ZIP = $APPName + ".zip"

# Actions
Write-Host "First Arguments: " $KEY
Write-Host "$KEY is the RSA Key without a password"
Write-Host "$CERT is the SSL Certificate for the server"
Write-Host "$CHAIN is the Certificate Chain to the CA"
Write-Host "Creating PFX file without RSA Password"
"$KEY is the RSA Key without a password", "$CERT is the SSL Certificate for the server", "$CHAIN is the Certificate Chain to the CA", "Creating PFX file without RSA Password" | Out-File -FilePath $TEXTOUT

# Create PFX
openssl pkcs12 -export -out ".\$PKCS12" -inkey $KEY -in $CERT -certfile $CHAIN -passout "pass:$STOREPASS"
Write-Host "$PKCS12 created with $STOREPASS as the password"
Write-Host "Creating RSA With Password $RSAPASS"
"$PKCS12 created with $STOREPASS as the password", "Creating RSA With Password $RSAPASS" | Out-File -FilePath $TEXTOUT -Append

# Create PFX with RSA
openssl rsa -aes256 -in $KEY -out ".\$RSAKEY" -passout "pass:$RSAPASS"
Write-Host "Creating PFX file with RSA Password"
"Creating PFX file with RSA Password" | Out-File -FilePath $TEXTOUT -Append
openssl pkcs12 -export -out ".\$PKCS12RSA" -inkey ".\$RSAKEY" -passin "pass:$RSAPASS" -in $CERT -certfile $CHAIN -passout "pass:$RSAPASS"
Write-Host "Created PFX $PKCS12RSA with RSA Pass $RSAPASS and PFX Password of $RSAPASS"
"Created PFX $PKCS12RSA with RSA Pass $RSAPASS and PFX Password of $STOREPASS" | Out-File -FilePath $TEXTOUT -Append
Write-Host "Creating JKS file without RSA Password for Tomcat"
"Creating JKS file without RSA Password for Tomcat" | Out-File -FilePath $TEXTOUT -Append

# Create Java Keystore - JKS
keytool -importkeystore -srckeystore ".\$PKCS12" -destkeystore ".\$JKS" -srcstoretype pkcs12 -srcstorepass $STOREPASS -deststorepass $STOREPASS
keytool -changealias -keystore ".\$JKS" -storepass $STOREPASS -alias 1 -destalias tomcat
Write-Host "Created JKS $PKCS12 with password $STOREPASS"
"Created JKS $PKCS12 with password $STOREPASS" | Out-File -FilePath $TEXTOUT -Append
Write-Host "Creating JKS file with RSA Password"
"Creating JKS file with RSA Password" | Out-File -FilePath $TEXTOUT -Append

# Create Java Keystore with RSA - JKS
keytool -importkeystore -srckeystore ".\$PKCS12RSA" -destkeystore ".\$JKSRSA" -srcstoretype pkcs12 -srckeypass $RSAPASS -srcstorepass $RSAPASS -deststorepass $RSAPASS -alias 1
keytool -changealias -keystore ".\$JKSRSA" -storepass $RSAPASS -alias 1 -destalias weblogic
Write-Host "Created JKS $JKSRSA with password $RSAPASS and RSA Pass of $RSAPASS"
"Created JKS $JKSRSA with password $RSAPASS and RSA Pass of $RSAPASS" | Out-File -FilePath $TEXTOUT -Append
Compress-Archive -Path $KEY, $CERT, $CHAIN, ".\$PKCS12", ".\$PKCS12RSA", ".\$JKS", ".\$JKSRSA", ".\$RSAKEY", ".\$TEXTOUT" -DestinationPath $ZIP
Start-Sleep -Seconds 10
