#!/bin/bash       

# Backup database > Store in a location > Pushover notification > Delete file older than 30 days
                                                                                
function push() {                                                               
        curl -s \                                                               
                --form-string "token=TOKEN" \          
                --form-string "user=USER_TOKEN" \           
                --form-string "title=$1" \                                      
                --form-string "message=$2" \                                    
                --form-string "priority=$3" https://api.pushover.net/1/messages.json
}                                                                               
                                                                                
DATABASE=$1                                                                     
DIRECTORY=/root/databases                                                  
                                                                                
mysql -e 'SHOW DATABASES;' | grep -q "${DATABASE}"                              
                                                                                
if [ "$?" -eq 0 ]; then                                                         
        mysql -e 'STOP SLAVE SQL_THREAD;'                                       
        mysqldump "${DATABASE}" | gzip > "${DIRECTORY}"/"$(date +"%Y%m%d")-${DATABASE}".sql.gz
        if [ "${PIPESTATUS[*]}" == "0 0" ]; then                                
                mysql -e 'START SLAVE SQL_THREAD;'                              
                push "Database Backup" "[$1] succeeded" "-2"                    
        else                                                                    
                mysql -e 'START SLAVE SQL_THREAD;'                              
                push "Database Backup" "[$1] failed" "1"                        
        fi                                                                      
else                                                                            
        push "Database Backup" "[$1] does not exist" "1"                        
fi                                                                              
                                                                                
find "${DIRECTORY}" -type f -mtime +30 -exec rm -rf {} +
