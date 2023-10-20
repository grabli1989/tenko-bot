#!/bin/bash

clear

DOMAINS=''

for domain in `cat /etc/hosts | tr " " "\n" | grep -o '[A-Za-z0-9_\.-]*.loc'`
 do
  DOMAINS="${DOMAINS} ${domain}"
done

if [ -z "$1" ]
  then
    echo 'Укажите директорию для хранения сертификатов'
    exit
fi

mkdir -p $1

WORKDIR=$PWD

if command -v apt &> /dev/null
  then
      CERTUTIL_INSTALL='apt install libnss3-tools'
elif command -v yum &> /dev/null
  then
      CERTUTIL_INSTALL='yum install nss-tools'
elif command -v yum &> /dev/null
  then
      CERTUTIL_INSTALL='zypper install mozilla-nss-tools'
else
  echo 'Unsupported OS'
  exit;
fi

if [ -d '/etc/pki/ca-trust/source/anchors/' ]; \
  then \
    SYSTEM_TRUST_COMMAND='update-ca-trust extract'; \

elif [ -d '/usr/local/share/ca-certificates/' ]; \
  then \
    SYSTEM_TRUST_COMMAND='update-ca-certificates'; \

elif [ -d '/etc/ca-certificates/trust-source/anchors/' ]; \
  then \
    SYSTEM_TRUST_COMMAND='trust extract-compat'; \

elif [ -d '/usr/share/pki/trust/anchors' ]; \
  then \
    SYSTEM_TRUST_COMMAND='update-ca-certificates'; \

else \
  echo 'Unsupported OS'; \
  exit;
fi

$CERTUTIL_INSTALL

if ! command -v mkcert &> /dev/null
  then
      cd /usr/local/bin
      wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64
      chmod +x ./mkcert
fi

mkcert -uninstall \
  && mkcert -install \
  && mkcert -key-file $1/key.pem -cert-file $1/cert.pem localhost $DOMAINS

$SYSTEM_TRUST_COMMAND
exit
