#!/bin/bash
#==============================================================================
#TITLE:            mysql_backup.sh
#DESCRIPTION:      Script para automatizar las copias de seguridad diarias de MySQL del servidor
#AUTHOR:           Rafael Villafuerte
#DATE:             2023-11-29
#VERSION:          0.1
#USAGE:            ./mysql_backup.sh
#IMPORTANTE:       El servidor debe tener instalado PV Pipe Viewer para poder visualizar progressbar en mysqldump
#CRON:
  # Ej. para cron job, copias diarias a las  @ 9:15 am
  # min  hr mday month wday command
  # 15   9  *    *     *    /[path]/scripts/mysql_backup.sh

#RESTAURAR EL BACKUP
#$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]

#==============================================================================
# CONFIGURACION
#==============================================================================

# DIRECTORIO DONDE SE ALMACENARAN LOS BACKUP
BACKUP_DIR=/home/perudalia/public_html/backups

# MYSQL Parametros
MYSQL_UNAME=root
MYSQL_PWORD=

# No haga copias de seguridad de bases de datos con estos nombres 
# Example: comienza con mysql (^mysql) o termina con _schema (_schema$)
IGNORE_DB="(^mysql|_schema$|^sys)"

# incluir binarios mysql y mysqldump para el usuario cron bash
PATH=$PATH:/usr/local/mysql/bin

# Número de días para mantener las copias de seguridad
KEEP_BACKUPS_FOR=30 #dias

#==============================================================================
# METODOS // FUNCIONES
#==============================================================================

# YYYY-MM-DD
TIMESTAMP=$(date +%F)

function delete_old_backups()
{
  echo "Borrando $BACKUP_DIR/*.sql.gz con antiguedad de $KEEP_BACKUPS_FOR dias"
  find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME" 
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD" 
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r'; 
  printf ' %0.s' {0..100} 
  printf '\r'; 
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$TIMESTAMP.$database.sql.gz" 
    output+="$database => $backup_file\n"
    #echo_status "...respaldando $count de $total bases de datos: $database"
    echo "...respaldando $count de $total bases de datos: $database"
    db_size=$(mysql $(mysql_login) --silent --skip-column-names -e "SELECT ROUND(SUM(data_length) / 1024 / 1024, 0) FROM information_schema.TABLES WHERE table_schema='$database';")
    $(mysqldump $(mysql_login) --routines --triggers $database | pv --progress -W -s "$db_size"m | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function hr(){
  printf '=%.0s' {1..100}
  printf "\n"
}

#==============================================================================
# EJECUTAR SCRIPT BASH
#==============================================================================
delete_old_backups
hr
backup_databases
hr
printf "Todo respaldado!\n\n"
