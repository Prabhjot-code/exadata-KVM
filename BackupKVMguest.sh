## Method 2: Back up Individual User Domains

ScriptStarttime=$(date +%s)
printf "This script is going to remove the directory /EXAVMIMAGES/Backup.
If that is not acceptable, exit the script by typing n, manually 
remove /EXAVMIMAGES/Backup and come back to rerun the script. Otherwise, 
press y to continue  :"
read proceed 

if [[ ${proceed} == "n" ]] || [[  ${proceed} == "N" ]]
then
  exit 0
fi 

rm -rf /EXAVMIMAGES/Backup 

printf "Enter the name of the user domains to be backed up :"
read userDomainName

##  Create the Backup Directory 

mkdirStartTime=$(date +%s)
find /EXAVMIMAGES/GuestImages/${userDomainName} -type d|grep -v 
'lost+found'|awk '{print "mkdir -p /EXAVMIMAGES/Backup"$1}'|sh
mkdirEndTime=$(date +%s)
mkdirTime=$(expr ${mkdirEndTime} - ${mkdirStartTime})
echo "Backup Directory creation time :" ${mkdirTime}" seconds" 

##  Pause the user domain
PauseStartTime=$(date +%s)
virsh suspend ${userDomainName}
PauseEndTime=$(date +%s)
PauseTime=$(expr ${PauseEndTime} - ${PauseStartTime})
echo "PauseTime for guest - ${userDomainName} :" ${PauseTime}" seconds" 

## Create xfsdump for all the files in /EXAVMIMAGES/GuestImages/${userDomainName}
relinkStartTime=$(date +%s)
find /EXAVMIMAGES/GuestImages/${userDomainName} -type f|awk '{print "/sbin/xfsdump -l 0 -f",
$0,"/EXAVMIMAGES/Backup"$0}'|sh
relinkEndTime=$(date +%s)
reflinkTime=$(expr ${relinkEndTime} - ${relinkStartTime})
echo "xfdump creation time for guest - ${userDomainName} :" ${reflinkTime}" seconds" 

## Unpause the user domain
unPauseStartTime=$(date +%s)
virsh resume ${userDomainName}
unPauseEndTime=$(date +%s)
unPauseTime=$(expr ${unPauseEndTime} - ${unPauseStartTime})
echo "unPauseTime for guest - ${userDomainName} :" ${unPauseTime}" seconds"
done 

ScriptEndtime=$(date +%s) 
ScriptRunTime=$(expr ${ScriptEndtime} - ${ScriptStarttime}) 
echo ScriptRunTime ${ScriptRunTime}" seconds”
