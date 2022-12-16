#!/bin/sh

HOSTNAME=$(hostname | /usr/bin/tr '[a-z]' '[A-Z]')
export PATH=/usr/bin/:$PATH
export EDBHOME=/usr/pgsql-13/bin
export PGDATA=/pg/13/data
export PGDATABASE=postgres
export PGUSER=postgres
export PGPORT=5432
export PGLOCALEDIR=/usr/pgsql-13/share/locale
LOG_DIR="/backup/scripts/logs"
LOG="$LOG_DIR/$HOSTNAME-RFB-$date"

date="$(date +%Y-%m-%d_%H:%M)"
LOG="$LOG_DIR/$HOSTNAME-RFB-$date-Node1.log"
export PATH

SERVER=$(hostname)
echo -e "`date`\n" >> $LOG

echo -e "Please find the below report for RFB\n" >> $LOG
echo "Database Uptime">> $LOG
psql -U postgres -d postgres -c "SELECT current_timestamp - pg_postmaster_start_time();" >> $LOG

echo "Last Database Time Restart">> $LOG
psql -U postgres -d postgres -c "SELECT pg_postmaster_start_time();" >> $LOG

echo "STATUS OF REPLICATION:" >> $LOG
psql -U postgres -d postgres -c "select pid,usesysid,usename,application_name, client_addr,client_port, backend_start,state, sync_state from pg_stat_replication;" >> $LOG

echo "Database Activity Status">> $LOG
psql -U postgres -d postgres -c "SELECT datname, pid, usesysid, usename, application_name, client_addr, client_port, query_start, wait_event_type, wait_event, state FROM pg_stat_activity;" >> $LOG


echo "Number of connections">> $LOG
psql -U postgres -d postgres -c "select sum(numbackends) FROM pg_stat_database;" >> $LOG

echo -e "\nDATABASE SIZE:" >> $LOG
psql -U postgres -d postgres -c "select datname as db, pg_size_pretty(pg_database_size(datname)) as size from pg_database order by pg_database_size(datname) desc;" >> $LOG

echo -e "\nCheck the status of repmanager:" >> $LOG
systemctl status repmgr13 >> $LOG

echo -e "\nCheck postgres is ready for connections:" >> $LOG
pg_isready >> $LOG

echo -e "\nCheck PostgreSQL Service:" >> $LOG
systemctl status postgresql-13 >> $LOG


echo -e "\nCheck repmanager position in the Cluster:" >> $LOG
/usr/pgsql-13/bin/repmgr cluster show >> $LOG
#repmgr -f /etc/repmgr/13/repmgr.conf cluster show >> $LOG



echo -e "\nFile System Utilization:" >> $LOG
df -h >> $LOG

echo -e "\nMemory Utilization in GB:" >> $LOG
free -g >> $LOG

echo -e "\nCPU Utilization:" >> $LOG
top -b -n 1 -d 1 |head -n 20 >> $LOG


msg=`cat $LOG`

#echo -e "$msg" | mail -a $LOG -s " PostgreSQL -  Production Database Health Check $HOSTNAME " $MAILTO

echo -e "$msg" | mail -a $LOG -s " PostgreSQL -  Production Database Health Check " $MAILTO

------This is my addition line1 $

------This is Class2 change and more work is coming
