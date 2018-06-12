#!/bin/bash

get_abs_filename() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"    
}
 
      
configuration_writer() {
            inputFile=$1
            configFile=$2
 
            echo "#!/bin/bash" > "$configFile"

            regex='^([^#]+)=("?.+"?)$'
            while read -r; do
                if [[ $REPLY =~ $regex ]]; then
                    varname=${BASH_REMATCH[1]}
                    varvalue=${BASH_REMATCH[2]}
                    echo "$varname=$varvalue" >> "$configFile"
                fi
             done < "$inputFile"
}  


config_NAS() {
        
	# Configurable variables
    NAS_HOSTNAME=$3
    NAS_USER_ACCOUNT=$1
    USER_PASSWORD=$2
    CUSTOMER_DIR=$4

    if [[ ${BASH_REMATCH[4]} == "" ]]; then
            echo "No customer folder specified. Will use default folder."
        CUSTOMER_DIR="Default"
    fi

	CONFIG_TEXT_PATH=$(get_abs_filename "./$CUSTOMER_DIR/config.txt")
	CONFIGURATION_FILE=$(get_abs_filename "./$CUSTOMER_DIR/$NAS_HOSTNAME.configuration.sh")
    configuration_writer "$CONFIG_TEXT_PATH" "$CONFIGURATION_FILE"
        
	source "$CONFIGURATION_FILE"

    REGISTRATION_DATABASES="./$CUSTOMER_DIR/license_db_folder"
	echo $REGISTRATION_DATABASES
	DATABASE_TO_COPY="empty"
	echo $DATABASE_TO_COPY

	INSTALL_SCRIPTS_DIR="install_package"
    # Composed and static variables
    NAS_SSH_URL="$NAS_USER_ACCOUNT@$NAS_HOSTNAME"
    VOLUME_PATH="/share/CACHEDEV1_DATA"
    INSTALL_SCRIPT_FILE="$INSTALL_SCRIPTS_DIR/install_functions.sh"
    TEMP_CONFIG_FILE="$INSTALL_SCRIPTS_DIR/$NAS_HOSTNAME.configuration.sh"
    CONFIG_FILE="$INSTALL_SCRIPTS_DIR/configuration.sh"


	F_INDEX=$(( RANDOM % 12 ))
    echo "Delaying script by random interval of "$F_INDEX
    sleep $F_INDEX
    if [[ $USE_REGISTRATION_DATABASES == "TRUE" ]]; then

        if [[ -d $REGISTRATION_DATABASES && "$(ls -A $REGISTRATION_DATABASES/*.db)" ]]; then 
            DB_FILE=$(ls -d $REGISTRATION_DATABASES/*.db | head -1)
            echo "Using "$DB_FILE
            mv $DB_FILE $DB_FILE.$F_INDEX
            DATABASE_TO_COPY=$DB_FILE.$F_INDEX
        elif [[ -d $REGISTRATION_DATABASES && "$(ls -A $REGISTRATION_DATABASES/*.json)" ]]; then 
            DB_FILE=$(ls -d $REGISTRATION_DATABASES/*.json | head -1)
            echo "Using "$DB_FILE
            mv $DB_FILE $DB_FILE.$F_INDEX
            DATABASE_TO_COPY=$DB_FILE.$F_INDEX
            echo "Using "$DATABASE_TO_COPY
        else
            echo "No files in the directory"
        fi
    fi


    echo "Check to see whether we should proceed with provisioning"
    #  Proceed if you have a valid license file or if profile explicitly says it doesn't need a license 

	if [[  $DATABASE_TO_COPY != "empty" || $USE_REGISTRATION_DATABASES == "FALSE" ]]; then

        echo "Copying files to target nas"

        rm -rf "$CUSTOMER_DIR/Registration.db"
        rm "$CUSTOMER_DIR/Registration.json"

        #check if the system is a QNAP.  Otherwise assume it is a UBUNTU system
        QNAP=$(ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL " if [[ -f /mnt/HDA_ROOT/.conf ]]; then echo TRUE;else echo FALSE; fi;" )
        if [[ $QNAP == "TRUE"  ]]; then 

            OS_FOLDER=$(get_abs_filename "./install_package/QNAP")
            echo $OS_FOLDERex

            # Setup up access to use qcli commands
            echo "Providing qcli credentials to target NAS".
            RESPONSE=$(ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli -l user=${NAS_USER_ACCOUNT} pw=${USER_PASSWORD} saveauthsid=yes;")
            
            #if failed to login to system, then leave.
            re='Authentication fail'
            if [[  $RESPONSE =~ re ]]; then 
                echo 'Authentication failed.  Exiting with code 1'
                exit 1 
            fi

            ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli -network -n;"

            # if there is n existing datavolume, create the volume according to specifics

            if [[ ! $(ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -i" | grep 'DataVol1') ]]; then

                re='^4\.2\.[2-9]|4\.3\.[0-3]'
                if [[ $(ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "/sbin/getcfg System Version")  =~ $re  ]]; then
                    echo "Remote system running firmware 4.3.3 or earlier"
                    if [[ $RAID_TYPE == "JBOD" ]]; then
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002 raidLevel=JBOD writeCache=yes SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120"
                    elif [[ $RAID_TYPE == "RAID1" ]]; then #RAID 1
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002 raidLevel=1 writeCache=yes SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120; echo 'idle' > /sys/block/md1/md/sync_action"
                    else #RAID 10
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002,00000003,00000004 raidLevel=10 writeCache=yes SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120; echo 'idle' > /sys/block/md1/md/sync_action"
                    fi
                else	

                    echo "Remote system running firmware 4.3.4 or later"
                    if [[ $RAID_TYPE == "JBOD" ]]; then
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002 raidLevel=JBOD SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120"
                    elif [[ $RAID_TYPE == "RAID1" ]]; then #RAID 1
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002 raidLevel=1 SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120; echo 'idle' > /sys/block/md1/md/sync_action"
                    else #RAID 10
                        ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -c  lv_type=3 diskID=00000001,00000002,00000003,00000004 raidLevel=10 SSDCache=no Alias=DataVol1 encrypt=no Threshold=${VOLUME1THRESHOLD}; sleep 120; echo 'idle' > /sys/block/md1/md/sync_action"
                    fi
                fi
            fi
                
            #Wait until the datavolume is ready
            while [[ ! $(ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "qcli_volume -i" | grep 'Ready  DataVol1') ]]; do echo '.'; sleep 10; done

            #Volume path will depend on how many times the system tried to create raid volumes
            VOLUME_PATH=$(ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "df | grep \ \/share\/CACHEDEV\[1-9]_DATA$ | sed -r  's/(^.*)(\/share\/CACHEDEV[1-9]_DATA$)/\2/'")
                
            # create symbolic link to actual datavolume in use
            if [[ ! $VOLUME_PATH == "/share/CACHEDEV1_DATA" ]]; then
                    ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "ln -s $VOLUME_PATH/ /share/CACHEDEV1_DATA"
            fi

        else 
            OS_FOLDER=$(get_abs_filename "./install_package/UBUNTU")
            echo $OS_FOLDER
        fi 

        # Determine architecture type
        ARCHITECTURE=$(ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "uname -m")
        if [[ $ARCHITECTURE =~ .*"_64"*. ]]; then
            ARCH=x64
            SPOTMONITOR=$(echo $(ls $OS_FOLDER/HD_Station*.qpkg))
            JRE=$(ls $OS_FOLDER/$ARCH/JRE*.qpkg)
            UTILS=$(ls $OS_FOLDER/$ARCH/utils*)
        elif [[ $ARCHITECTURE == "arm"* ]]; then
            ARCH=armv7l
            SPOTMONITOR=""
            JRE=$(ls $OS_FOLDER/$ARCH/JRE*.qpkg)
            UTILS=""
        else
            ARCH=x86
            SPOTMONITOR=$(ls $OS_FOLDER/HD_Station*.qpkg)
            JRE=$(ls $OS_FOLDER/$ARCH/JRE*.qpkg)
            UTILS=$(ls $OS_FOLDER/$ARCH/utils*)        
        fi
            CONNECT=$(ls $OS_FOLDER/solink*qpkg.run)
        #copy contents of install directory
        rsync -va --progress --delete -e "ssh -o StrictHostKeyChecking=no" --exclude='.DS_Store' --exclude='UBUNTU' --exclude='QNAP' $INSTALL_SCRIPTS_DIR $NAS_SSH_URL:$VOLUME_PATH


        if [[ -f $SPOTMONITOR ]]; then
            echo "Copying $SPOTMONITOR to target NAS"
            scp $SPOTMONITOR "$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR"
            ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "cd $VOLUME_PATH/$INSTALL_SCRIPTS_DIR; ln -snf \$(ls HD_Station*.qpkg) HD_Station.qpkg"
        fi

        if [[ -f $JRE ]]; then
            echo "Copying $JRE to target NAS"
            scp $JRE "$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR"
            ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "cd $VOLUME_PATH/$INSTALL_SCRIPTS_DIR; ln -snf \$(ls JRE*.qpkg) JRE.qpkg"
        fi

        if [[ -f $CONNECT ]]; then
            echo "Copying $CONNECT to target NAS"
            scp $CONNECT "$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR"
            ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "cd $VOLUME_PATH/$INSTALL_SCRIPTS_DIR; ln -snf \$(ls solink*qpkg.run) SolinkConnect.qpkg"
        fi

        if [[ -f $UTILS ]]; then
            echo "Copying utilities to target NAS"
            scp $UTILS "$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR"
        fi

        # copy customer specific configuration files from their directory to the target NAS installation scripts directory
        rsync -va --progress --delete -e "ssh -o StrictHostKeyChecking=no" --exclude='*.configuration.sh' --exclude='config.txt' --exclude='license_db_folder' $CUSTOMER_DIR/* $NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR
 
 
        if [[ $USE_REGISTRATION_DATABASES ]]; then
            if [[ $DATABASE_TO_COPY == *.json.$F_INDEX ]]; then
                TARGET_DB="Registration.json"
            else
                TARGET_DB="Registration.db"
            fi
            echo 'Copying Callhome Registration data '$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR/$TARGET_DB
            scp $DATABASE_TO_COPY "$NAS_SSH_URL:$VOLUME_PATH/$INSTALL_SCRIPTS_DIR/$TARGET_DB"
            rm $DATABASE_TO_COPY
        fi

        scp $CONFIGURATION_FILE $NAS_SSH_URL:$VOLUME_PATH/$CONFIG_FILE
        rm $CONFIGURATION_FILE
        ssh  -o StrictHostKeyChecking=no -o ServerAliveInterval=10  $NAS_SSH_URL "chmod +x $VOLUME_PATH/$INSTALL_SCRIPT_FILE; $VOLUME_PATH/$INSTALL_SCRIPT_FILE $VOLUME_PATH/$CONFIG_FILE" 
        
        # create the symlinks in the target NAS install_package directory

	else
	    echo "*** FAILED ***  Exited script due to incomplete configuration"
	    exit 1
	fi
}


 
echo "Getting authorization to remotely access NAS(es)"

while read -r; do
    if [[ $REPLY =~ ^(.+)\,(.+)\,(.+)\,(.*)$ ]]; then
        varuser="${BASH_REMATCH[1]}"
        varpassword="${BASH_REMATCH[2]}"
        varipaddress="${BASH_REMATCH[3]}"

        # Composed and static variables
        NAS_SSH_URL="$varuser@$varipaddress"

        ssh-keygen -H -F $varipaddress -t rsa -f ~/.ssh/id_rsa -P ""
        rc=$?; if [[ $rc=0 ]]; then ssh-keygen -R $varipaddress; fi
        cat ~/.ssh/id_rsa.pub | ssh $NAS_SSH_URL "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

        echo "Next entry"
    fi
done < $1  

echo "Starting to launch configuration processes..."

while read -r; do
    if [[ $REPLY =~ ^(.+)\,(.+)\,(.+)\,(.*)$ ]]; then
        varuser="${BASH_REMATCH[1]}"
        varpassword="${BASH_REMATCH[2]}"
        varipaddress="${BASH_REMATCH[3]}"
        varcustomerpath="${BASH_REMATCH[4]}"

        echo $varuser $varpassword $varipaddress $varcustomerpath

        echo "Configuring NAS at address "$varipaddress
        config_NAS $varuser $varpassword $varipaddress $varcustomerpath &>./logs/$varipaddress.txt &
        #config_NAS $varuser $varpassword $varipaddress $varcustomerpath 

    fi

done < $1  

