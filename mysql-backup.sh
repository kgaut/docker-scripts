
if [ "$1" != "" ];
then
  DB_TO_SAVE="$1"
else
  DB_TO_SAVE=""
fi

Mysql_User="root"
Mysql_Paswd="mysql"
Mysql_host="localhost"
# Emplacemment des different prog utilisé, laisser tel quel si vous n'avez rien bidouillé
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

#SI à 1 alors suppression des bases plus vielles que x jours
CLEANUP=0
CLEANUP_OLDER_THAN=30

#Rep ou on fout le sql
DEST_mysql="/var/db"

#Date du jour
NOW="$(date +"%Y-%m-%d_%H-%M-%S")"

# Databases a ne pas sauvegarder separer par des espaces
IGGY="CMS test phpmyadmin information_schema mysql performance_schema"

# On initialise les variables
FILE=""
DBS=""

#on cree le rep
[ ! -d $DEST_mysql ] && mkdir -p $DEST_mysql || :

#On limite l'acces au root uniquemment
#$CHOWN 0.0 -R $DEST_mysql
#$CHMOD 0600 $DEST_mysql

# On liste les bases de donnees
DBS="$($MYSQL -u $Mysql_User -h $Mysql_host -p$Mysql_Paswd -Bse 'show databases')"

for db in $DBS
do
    sitefolder="$db"
    skipdb=-1
    if [ "$DB_TO_SAVE" != "" ];
    then
        for i in $DB_TO_SAVE
        do
            [ "$db" != "$i" ] && skipdb=1 || :
        done
    fi
    if [ "$IGGY" != "" ];
    then
        for i in $IGGY
        do
            [ "$db" == "$i" ] && skipdb=1 || :
        done
    fi

    if [ "$skipdb" == "-1" ] ; then
        mkdir -p "$DEST_mysql/"
        if [ "$CLEANUP" == 1 ]; then
            find "$DEST_mysql/" -type f -mtime +"$CLEANUP_OLDER_THAN" -delete
        fi
        FILE="$DEST_mysql/$NOW-$db-$HOSTNAME.gz"
        # On boucle, et on dump toutes les bases et on les compresse
        $MYSQLDUMP -u $Mysql_User -h $Mysql_host -p$Mysql_Paswd $db --routines | $GZIP -9 > "$FILE"
        echo "Base de donnée : $db sauvegardée dans $FILE"
    fi
done

chown 1000:1000 $DEST_mysql -R

