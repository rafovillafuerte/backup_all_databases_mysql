# backup_all_databases_mysql
Script bash para generar copias de respaldo de todas las bases de datos MYSQL del servidor.

# Cron Job:
Crear copias de seguridad diarias a las 9:15 am usando CRON JOB

 min  hr mday month wday command
 
 15   9  *    *     *    /[path]/scripts/public_html_backup.sh
 
# Restaurar desde Backup
$ cd /home/<user name>
$ tar -xvf < [backupfile.tar.gz] 


