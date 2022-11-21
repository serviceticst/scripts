STATUS="$(systemctl is-active wnbtlscli.service)"
if [ "${STATUS}" = "active" ]; then
    echo "1"
else 
    echo "0"  
    exit 1  
fi