#!/bin/bash

if [ "$1" != "" ];
then
  DB_TO_IMPORT="$1"
else
  while [ -z "$DB_TO_IMPORT" ]
  do
          echo "Nom du fichier dump à importer"
          read DB_TO_IMPORT
  done
fi

if [ "$2" != "" ];
then
  DB_TARGET="$2"
else
  while [ -z "$DB_TARGET" ]
  do
          echo "Nom de la base de données"
          read DB_TARGET
  done
fi


echo "IMPORT DU DUMP"
zcat /var/db/${DB_TO_IMPORT} | mysql -uroot -pmysql ${DB_TARGET}
