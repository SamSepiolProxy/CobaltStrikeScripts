#!/bin/bash
# Global Variables
runuser=$(whoami)
tempdir=$(pwd)
# Echo Title
clear
echo '=========================================================================='
echo ' HTTPS C2 Setup Script'
echo '=========================================================================='

echo -n "Enter your DNS (A) record for domain [ENTER]: "
read domain
echo

echo -n "Enter your common password to be used [ENTER]: "
read password
echo

echo -n "Enter your CobaltStrike server location [ENTER]: "
read cobaltStrike
echo

echo -n "Enter your Certificate path [ENTER]: "
read certificatepath
echo

domainPkcs="$domain.p12"
domainStore="$domain.store"
cobaltStrikeProfilePath="$cobaltStrike/Profile"


# Environment Checks
func_check_env(){
  # Check Sudo Dependency going to need that!
  if [ $(id -u) -ne '0' ]; then
    echo
    echo ' [ERROR]: This Setup Script Requires root privileges!'
    echo '          Please run this setup script again with sudo or run as login as root.'
    echo
    exit 1
  fi
}

func_check_tools(){
  # Check Sudo Dependency going to need that!
  if [ $(which keytool) ]; then
    echo '[Success] java keytool is installed'
  else 
    echo
    echo ' [ERROR]: keytool does not seem to be installed'
    echo
    exit 1
  fi
  if [ $(which openssl) ]; then
    echo '[Success] openssl keytool is installed'
  else 
    echo
    echo ' [ERROR]: openssl does not seem to be installed'
    echo
    exit 1
  fi
}

func_build_pkcs(){
  cd /tmp
  echo '[Starting] Building PKCS12 .p12 cert.'
  openssl pkcs12 -export -in $certificatepath/fullchain.pem -inkey $certificatepath/privkey.pem -out $domainPkcs -name $domain -passout pass:$password
  echo '[Success] Built $domainPkcs PKCS12 cert.'
  echo '[Starting] Building Java keystore via keytool.'
  keytool -importkeystore -deststorepass $password -destkeypass $password -destkeystore $domainStore -srckeystore $domainPkcs -srcstoretype PKCS12 -srcstorepass $password -alias $domain
  echo '[Success] Java keystore $domainStore built.'
  mkdir $cobaltStrikeProfilePath
  cp $domainStore $cobaltStrikeProfilePath
  echo '[Success] Moved Java keystore to CS profile Folder.'
}

# Menu Case Statement
case $1 in
  *)
  func_check_env
  func_check_tools
  func_build_pkcs
  ;;
esac