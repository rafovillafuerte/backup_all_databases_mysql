# backup_all_databases_mysql
Script bash para generar copias de respaldo de todas las bases de datos MYSQL del servidor.

# Cron Job:
Crear copias de seguridad diarias a las 9:15 am usando CRON JOB

min hr mday month wday command

15 9 * * * /[path]/scripts/mysql_backup.sh

#Restaurar desde Backup

$ gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]

ó

$ gunzip [backupfile.sql.gz] 

$ mysql -u [uname] -p[pass] [dbname] < [backupfile.sql]

Nota: Para remover las clausulas DEFINER usar el siguiente comando.

sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i backupfile.sql
