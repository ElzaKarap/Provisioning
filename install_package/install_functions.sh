#!/bin/bash

set -euE 
set -o pipefail

#global vars
QPKG_CONF="/etc/config/qpkg.conf"
ULINUX_CONF="/etc/config/uLinux.conf"

SET_CFG="/sbin/setcfg"
GET_CFG="/sbin/getcfg"
RM_CFG="/sbin/rmcfg"

DEFAULT_VOLUME_DIR="/share/CACHEDEV1_DATA"

UTILS="utils.tar"
PUBLIC="/share/CACHEDEV1_DATA/Public"


handle_error() {
  if [[ ! "$2" == "0" ]]; then
    echo "FAILED: line $1, exit code $2"
    exit $2
  else
    echo "EXITED with code $2 at line $1"
  fi
}

trap 'handle_error $LINENO $?' EXIT

# import source vars
if [[ -n "$1" ]]; then
  source "$1"
else
  echo "Missing configuration.sh argument. Usage ./install_functions.sh ./configuration.sh" 
  exit 1
fi

# get the script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


system_config() { 

  echo "begin Updating $ULINUX_CONF"

  $SET_CFG System                 "Web Access Port"             $WEB_ACCESS_PORT              -f "$ULINUX_CONF"
  $SET_CFG System                 "Time Zone"                   "$TIME_ZONE"                  -f "$ULINUX_CONF"
  $SET_CFG System                 "Enable Daylight Saving Time" $ENABLE_DAYLIGHT_SAVING_TIME  -f "$ULINUX_CONF"
  $SET_CFG System                 agree_beta                    0                             -f "$ULINUX_CONF"
  $SET_CFG System                 "Server Name"			$SERVER_NAME                  -f "$ULINUX_CONF"
  $SET_CFG System                 "Auto PowerOn"		TRUE 	                      -f "$ULINUX_CONF"
  $SET_CFG System                 "Enable Live Update"		FALSE 	                      -f "$ULINUX_CONF"
  $SET_CFG SNMP                   "Server Enable"               FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Samba                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Appletalk              Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG WebFS                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG QWEB                   Enable                        0                             -f "$ULINUX_CONF"
  $SET_CFG QPHOTO                 Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG BTDownload             Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG FTP                    Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG "DHCP Server"          Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Printers               Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG MySQL                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG "Network Recycle Bin"  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG PgSQL                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG MUSICSTATION           Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG PHOTOSTATION           Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG VIDEOSTATION           Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG iTune                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG TwonkyMedia            Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG NFS                    Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      Web                           0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      SAMBA                         0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      AFP                           0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      SSH                           0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      FTP                           0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      HTTPS                         0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      UPNP                          0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      QMobile                       0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      CSCO                          0                             -f "$ULINUX_CONF"
  $SET_CFG "Bonjour Service"      Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Qsync                  Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG "UPnP Service"         Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG SDM                    Enabled                       FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Stunnel                Enable                        0                             -f "$ULINUX_CONF"
  $SET_CFG Versioning             Enable                        FALSE                         -f "$ULINUX_CONF"
  $SET_CFG NTP                    "USE NTP Server"              TRUE                          -f "$ULINUX_CONF"
  $SET_CFG NTP                    "NTP Server IP"               "$NTP_SERVER_IP"              -f "$ULINUX_CONF"
  $SET_CFG NTP                    "Enable NTP Server"           FALSE                         -f "$ULINUX_CONF"
  $SET_CFG NTP                    "INTERVAL"                    8                             -f "$ULINUX_CONF"
  $SET_CFG NTP                    "TIMEUNIT"                    HOUR                          -f "$ULINUX_CONF"
  $SET_CFG Misc                   "Buzzer Warning Enable"       FALSE                         -f "$ULINUX_CONF"
  $SET_CFG Misc                   "Buzzer Quiet Enable"         TRUE                          -f "$ULINUX_CONF"
  $SET_CFG Misc                   "Power_Recovery_Mode"         1                             -f "$ULINUX_CONF"
  $SET_CFG Bluetooth              Enable                        FALSE                         -f "$ULINUX_CONF"

  $SET_CFG Network                "DNS type"                    $DNS_TYPE                     -f "$ULINUX_CONF"
  $SET_CFG Network                "Domain Name Server 1"        $DNS1                         -f "$ULINUX_CONF"
  $SET_CFG Network                "Domain Name Server 2"        $DNS2                         -f "$ULINUX_CONF"

  $SET_CFG Network                "Default GW Device"           "$DEFAULT_GATEWAY_DEVICE"     -f "$ULINUX_CONF"
  $SET_CFG Network                "Auto GW Mode"                "prefer"                      -f "$ULINUX_CONF"
  $SET_CFG Network                "Prefer GW Device"            "$DEFAULT_GATEWAY_DEVICE"     -f "$ULINUX_CONF"

  re='^4\.2\.[2-9]|4\.[3-9]\.[0-9]|[5-9]\.[0-9]\.[0-9]$'
  if [[ $(/sbin/getcfg System Version) =~ $re ]]; then
    echo 'System Version 4.2.2 or greater.  Setting fixed default gateways'
    $SET_CFG Network                "Auto GW Mode"                "fixed"                     -f "$ULINUX_CONF"
    $SET_CFG Network                "fixed_default_gw_1"          "$DEFAULT_GATEWAY_DEVICE"   -f "$ULINUX_CONF"
    $SET_CFG Network                "fixed_default_gw_2"          "none"                      -f "$ULINUX_CONF"
  fi
 
  $SET_CFG eth0                   "Usage"                       STATIC                        -f "$ULINUX_CONF"
  $SET_CFG eth0                   "IP Address"                  "$ETH0_IP_ADDRESS"            -f "$ULINUX_CONF"
  $SET_CFG eth0                   "Subnet Mask"                 "$ETH0_SUBNET_MASK"           -f "$ULINUX_CONF"
  $SET_CFG eth0                   "Broadcast"                   "$ETH0_BROADCAST"             -f "$ULINUX_CONF"
  $SET_CFG eth0                   "Gateway"                     "$ETH0_GATEWAY"               -f "$ULINUX_CONF"
  $SET_CFG eth0                   "Use DHCP"                    $ETH0_DHCP                    -f "$ULINUX_CONF"
 
  $SET_CFG eth1                   "Use DHCP"                    FALSE                         -f "$ULINUX_CONF"
  $SET_CFG eth1                   "Usage"                       STATIC                        -f "$ULINUX_CONF"
  $SET_CFG eth1                   "IP Address"                  "$ETH1_IP_ADDRESS"            -f "$ULINUX_CONF"
  $SET_CFG eth1                   "Subnet Mask"                 "$ETH1_SUBNET_MASK"           -f "$ULINUX_CONF"
  $SET_CFG eth1                   "Broadcast"                   "$ETH1_BROADCAST"             -f "$ULINUX_CONF"
  $SET_CFG eth1                   "Gateway"                     "$ETH1_GATEWAY"               -f "$ULINUX_CONF"
  
  if [[ $ETH2_IP_ADDRESS ]]; then 
    $SET_CFG eth2                   "Use DHCP"                    FALSE                         -f "$ULINUX_CONF"
    $SET_CFG eth2                   "Usage"                       STATIC                        -f "$ULINUX_CONF"
    $SET_CFG eth2                   "IP Address"                  "$ETH2_IP_ADDRESS"            -f "$ULINUX_CONF"
    $SET_CFG eth2                   "Subnet Mask"                 "$ETH2_SUBNET_MASK"           -f "$ULINUX_CONF"
    $SET_CFG eth2                   "Broadcast"                   "$ETH2_BROADCAST"             -f "$ULINUX_CONF"
    $SET_CFG eth2                   "Gateway"                     "$ETH2_GATEWAY"               -f "$ULINUX_CONF"
  fi

  if [[ $ETH3_IP_ADDRESS ]]; then 
    $SET_CFG eth3                   "Use DHCP"                    FALSE                         -f "$ULINUX_CONF"
    $SET_CFG eth3                   "Usage"                       STATIC                        -f "$ULINUX_CONF"
    $SET_CFG eth3                   "IP Address"                  "$ETH3_IP_ADDRESS"            -f "$ULINUX_CONF"
    $SET_CFG eth3                   "Subnet Mask"                 "$ETH3_SUBNET_MASK"           -f "$ULINUX_CONF"
    $SET_CFG eth3                   "Broadcast"                   "$ETH3_BROADCAST"             -f "$ULINUX_CONF"
    $SET_CFG eth3                   "Gateway"                     "$ETH3_GATEWAY"               -f "$ULINUX_CONF"
  fi

  echo "Done updating $ULINUX_CONF"
  echo "Updating in memory config"

  $SET_CFG System                 "Web Access Port"             $WEB_ACCESS_PORT
  $SET_CFG System                 "Time Zone"                   "$TIME_ZONE"
  $SET_CFG System                 "Server Name"			$SERVER_NAME
  $SET_CFG System                 "Enable Daylight Saving Time" $ENABLE_DAYLIGHT_SAVING_TIME
  $SET_CFG System                 agree_beta                    0
  $SET_CFG System                 "Auto PowerOn"		TRUE
  $SET_CFG System                 "Enable Live Update"		FALSE
  $SET_CFG SNMP                   "Server Enable"               FALSE
  $SET_CFG Samba                  Enable                        FALSE
  $SET_CFG Appletalk              Enable                        FALSE
  $SET_CFG WebFS                  Enable                        FALSE
  $SET_CFG QWEB                   Enable                        0
  $SET_CFG QPHOTO                 Enable                        FALSE
  $SET_CFG BTDownload             Enable                        FALSE
  $SET_CFG FTP                    Enable                        FALSE
  $SET_CFG "DHCP Server"          Enable                        FALSE
  $SET_CFG Printers               Enable                        FALSE
  $SET_CFG MySQL                  Enable                        FALSE
  $SET_CFG "Network Recycle Bin"  Enable                        FALSE
  $SET_CFG PgSQL                  Enable                        FALSE
  $SET_CFG MUSICSTATION           Enable                        FALSE
  $SET_CFG PHOTOSTATION           Enable                        FALSE
  $SET_CFG VIDEOSTATION           Enable                        FALSE
  $SET_CFG iTune                  Enable                        FALSE
  $SET_CFG TwonkyMedia            Enable                        FALSE
  $SET_CFG NFS                    Enable                        FALSE
  $SET_CFG "Bonjour Service"      Web                           0
  $SET_CFG "Bonjour Service"      SAMBA                         0
  $SET_CFG "Bonjour Service"      AFP                           0
  $SET_CFG "Bonjour Service"      SSH                           0
  $SET_CFG "Bonjour Service"      FTP                           0
  $SET_CFG "Bonjour Service"      HTTPS                         0
  $SET_CFG "Bonjour Service"      UPNP                          0
  $SET_CFG "Bonjour Service"      QMobile                       0
  $SET_CFG "Bonjour Service"      CSCO                          0
  $SET_CFG "Bonjour Service"      Enable                        FALSE
  $SET_CFG Qsync                  Enable                        FALSE
  $SET_CFG "UPnP Service"         Enable                        FALSE
  $SET_CFG SDM                    Enabled                       FALSE
  $SET_CFG Stunnel                Enable                        0
  $SET_CFG Versioning             Enable                        FALSE
  $SET_CFG NTP                    "USE NTP Server"              TRUE
  $SET_CFG NTP                    "NTP Server IP"               "$NTP_SERVER_IP"
  $SET_CFG NTP                    "Enable NTP Server"           FALSE
  $SET_CFG NTP                    "INTERVAL"                    8  
  $SET_CFG NTP                    "TIMEUNIT"                    HOUR
  $SET_CFG Misc                   "Buzzer Warning Enable"       FALSE
  $SET_CFG Misc                   "Buzzer Quiet Enable"         TRUE
  $SET_CFG Misc                   "Power_Recovery_Mode"         1
  $SET_CFG Bluetooth              Enable                        FALSE

  $SET_CFG Network                "DNS type"                    $DNS_TYPE
  $SET_CFG Network                "Domain Name Server 1"        $DNS1
  $SET_CFG Network                "Domain Name Server 2"        $DNS2

  $SET_CFG Network                "Default GW Device"           "$DEFAULT_GATEWAY_DEVICE"
  $SET_CFG Network                "Auto GW Mode"                "prefer"
  $SET_CFG Network                "Prefer GW Device"            "$DEFAULT_GATEWAY_DEVICE"

  re='^4\.2\.[2-9]|4\.[3-9]\.[0-9]|[5-9]\.[0-9]\.[0-9]$'
  if [[ $(/sbin/getcfg System Version) =~ $re ]]; then
    echo 'System Version 4.2.2 or greater.  Setting fixed default gateways'
    $SET_CFG Network                "Auto GW Mode"                "fixed"
    $SET_CFG Network                "fixed_default_gw_1"          "$DEFAULT_GATEWAY_DEVICE"
    $SET_CFG Network                "fixed_default_gw_2"          "none" 
  fi

  $SET_CFG eth0                   "Usage"                       STATIC           
  $SET_CFG eth0                   "IP Address"                  "$ETH0_IP_ADDRESS"
  $SET_CFG eth0                   "Subnet Mask"                 "$ETH0_SUBNET_MASK"
  $SET_CFG eth0                   "Broadcast"                   "$ETH0_BROADCAST"
  $SET_CFG eth0                   "Gateway"                     "$ETH0_GATEWAY"
  $SET_CFG eth0                   "Use DHCP"                    $ETH0_DHCP     
 
  $SET_CFG eth1                   "Use DHCP"                    FALSE           
  $SET_CFG eth1                   "Usage"                       STATIC           
  $SET_CFG eth1                   "IP Address"                  "$ETH1_IP_ADDRESS"
  $SET_CFG eth1                   "Subnet Mask"                 "$ETH1_SUBNET_MASK"
  $SET_CFG eth1                   "Broadcast"                   "$ETH1_BROADCAST"
  $SET_CFG eth1                   "Gateway"                     "$ETH1_GATEWAY"
  
  if [[ $ETH2_IP_ADDRESS ]]; then 
    $SET_CFG eth2                   "Use DHCP"                    FALSE                         
    $SET_CFG eth2                   "Usage"                       STATIC                        
    $SET_CFG eth2                   "IP Address"                  "$ETH2_IP_ADDRESS"           
    $SET_CFG eth2                   "Subnet Mask"                 "$ETH2_SUBNET_MASK"           
    $SET_CFG eth2                   "Broadcast"                   "$ETH2_BROADCAST"             
    $SET_CFG eth2                   "Gateway"                     "$ETH2_GATEWAY"               
  fi

  if [[ $ETH3_IP_ADDRESS ]]; then 
    $SET_CFG eth3                   "Use DHCP"                    FALSE                        
    $SET_CFG eth3                   "Usage"                       STATIC                        
    $SET_CFG eth3                   "IP Address"                  "$ETH3_IP_ADDRESS"            
    $SET_CFG eth3                   "Subnet Mask"                 "$ETH3_SUBNET_MASK"           
    $SET_CFG eth3                   "Broadcast"                   "$ETH3_BROADCAST"             
    $SET_CFG eth3                   "Gateway"                     "$ETH3_GATEWAY"               
  fi

  echo "Updated in memory config"

  echo "Reconfiguring network services"
#version 4.2.2 only
  re='^4\.2\.2$'
  if [[ $(/sbin/getcfg System Version) =~ $re || $(uname -m) == "armv7l" ]]; then
    /etc/init.d/network.sh reconfig
  fi
#version 4.3.x and greater
  re='^4\.[3-9]\.[0-9]|[5-9]\.[0-9]\.[0-9]$'
  if [[ ! $(uname -m) == "armv7l" && $(/sbin/getcfg System Version) =~ $re  ]]; then
    /etc/init.d/network.sh check_default_gw
  fi
  echo "Reconfigured network services"
  
  echo "Stop all services /etc/init.d/services.sh stop"
  /etc/init.d/services.sh restart
  echo "stopped all services"

  echo "Shuting down services that do not observe the enabled setting"
  echo "Stop webserver"
  /etc/init.d/Qthttpd.sh stop

  return 0 
}

pkg_uninstall() {
  echo "begin pkg_uninstall of $1"

  echo "disabling $1"
  $SET_CFG $1 Enable FALSE -f "$QPKG_CONF"
  echo "disabled $1"

  echo "Running .uninstall.sh for $1"
  QPKG_ROOT=$($GET_CFG $1 Install_Path -f "$QPKG_CONF") || true

  if [[ -f "$QPKG_ROOT/.uninstall.sh" ]]; then
    ( exec "$QPKG_ROOT/.uninstall.sh" )
    echo "Ran .uninstall.sh for $1"
  else
    echo "$QPKG_ROOT/.uninstall.sh does not exist"
  fi

  echo "Erasing $1 from /etc/config/qpkg.conf"
  $RM_CFG $1 -f /etc/config/qpkg.conf || true

  echo "Deleting $1 install at path $QPKG_ROOT"
  rm -rf "$QPKG_ROOT"
  echo "Done pkg_uninstall of $1"
  return 0
}

clean_up(){
  pkg_uninstall "DownloadStation"
  pkg_uninstall "SDDPd"
  pkg_uninstall "QcloudSSLCertificate"
  pkg_uninstall "VideoStationPro"
  pkg_uninstall "MusicStation"
  pkg_uninstall "PhotoStation"

  echo "Deleting shared folders and symlinks"
  rm -rf /share/Download
  rm -rf /share/Multimedia
  rm -rf /share/Recordings
  rm -rf /share/web
  rm -rf /share/homes
  rm -rf /share/external

  rm -rf $DEFAULT_VOLUME_DIR/Download
  rm -rf $DEFAULT_VOLUME_DIR/Multimedia
  rm -rf $DEFAULT_VOLUME_DIR/Recordings
  rm -rf $DEFAULT_VOLUME_DIR/web
  rm -rf $DEFAULT_VOLUME_DIR/homes
  rm -rf $DEFAULT_VOLUME_DIR/external
  echo "Deleted shared folders and symlinks"

  return 0
}

pkg_install() {
  if [[ -n "$1" ]]; then
    echo "installing $1"

    if [[ -L $DIR/$1.qpkg ]]; then
      (bash $DIR/$(readlink $DIR/$1.qpkg) ) || true 
    fi
    echo "installed $1"
  else
    echo "install skipped"
  fi
  return 0
}

all_pkg_install() {
  set +u
  re='^4\.2\.[2-9]$'
  if [[ $(/sbin/getcfg System Version) =~ $re ]]; then
    echo 'System Version 4.2.2 or greater.  Reset JRE to ELF32 version'
    rm $DIR/$JRE.qpkg && ln -s JRE_8.65.0-1103_x86.qpkg $DIR/$JRE.qpkg
  fi
 
  pkg_install $JRE
  pkg_install $HD_STATION
  pkg_install $SOLINK_CONNECT
  set -u
    return 0
}


configure_vms() {
  CAMERAS_JSON_FILE="$DIR/cameras.json"
  CAMERAS_CONFIG_FILE="$DIR/cameraConfig.csv"
  PROXY_FILE="$DIR/proxy.yaml"
  PORTS_YAML_FILE="$DIR/ports.yaml"
  REGISTRATION_DATABASE="$DIR/Registration.db"
  REGISTRATION_FILE="$DIR/Registration.json"

  if [[ -d $REGISTRATION_DATABASE || -f $REGISTRATION_FILE || -f $CAMERAS_JSON_FILE  || -f $CAMERAS_CONFIG_FILE || -f $PROXY_FILE || -f $PORTS_YAML_FILE ]]; then
    CONNECT_SHELL="$($GET_CFG SolinkConnect Shell -f $QPKG_CONF)"
    SOLINK_ROOT="/solink"
    PID_FILE="$($GET_CFG SolinkConnect Pid_File -f "$QPKG_CONF")"

    echo "Stopping SolinkConnect"
    $CONNECT_SHELL stop || true
    while [ -f $PID_FILE ] && $(kill -0 $(cat $PID_FILE) 2>&-); do
      echo -n "."
      sleep 1
    done
    echo "Stopped SolinkConnect"
  
    PROXY_YAML_FILE="$QPKG_ROOT/data/proxy.yaml"
    if [[ -f $PORTS_YAML_FILE ]] ; then 
      cp $PORTS_YAML_FILE "$QPKG_ROOT/data" 
      echo 'Copying ports.yaml file'
    fi

    if [[ -f $PROXY_FILE ]] ; then
      cp $PROXY_FILE $PROXY_YAML_FILE
      echo 'Copying Proxy config data'
    fi

    if [[ -d $REGISTRATION_DATABASE ]]; then
        echo 'Removing previous database'     
        rm -rf "$SOLINK_ROOT/data/checkin/db/Registration.db"
        mv $REGISTRATION_DATABASE "$SOLINK_ROOT/data/checkin/db/Registration.db"
        echo 'Copying Callhome Registration data'
    elif [[ -f $REGISTRATION_FILE ]]; then
        echo 'Removing previous database'     
        mv $REGISTRATION_FILE "$SOLINK_ROOT/data/checkin/db"
        echo 'Copying Callhome Registration.json'
   fi

    echo "Starting SolinkConnect"
    /sbin/setcfg SolinkConnect Enable TRUE -f $QPKG_CONF
    $CONNECT_SHELL start
    while ! ([ -f $PID_FILE ] && $(kill -0 $(cat $PID_FILE) 2>&-)); do
      echo -n "."
      sleep 1
    done
    echo "Started SolinkConnect"
    
    if [[ -f $CAMERAS_CONFIG_FILE ]]; then
      sleep 30
      cd $DIR
      (bash addCamera.sh ) || true 
      echo 'Copying Camera configs'
    fi
  fi

}

install_swap() {
  if [[ ! -f /share/CACHEDEV1_DATA/swapfile1 ]] ;
  then
    echo 'Creating and installing swap file'
    dd if=/dev/zero of=/share/CACHEDEV1_DATA/swapfile1 bs=1024 count=10485760 && mkswap /share/CACHEDEV1_DATA/swapfile1
    swapon /share/CACHEDEV1_DATA/swapfile1
    if [[ ! -d /tmp/autorun ]] ;
    then 
      mkdir /tmp/autorun
    fi
    SYSTEM_DRIVE=$($GET_CFG System 'System Device' -f $ULINUX_CONF)6
    mount $SYSTEM_DRIVE /tmp/autorun
    echo 'swapon /share/CACHEDEV1_DATA/swapfile1' >> /tmp/autorun/autorun.sh
    chmod 777 /tmp/autorun/autorun.sh
    umount /tmp/autorun
    rmdir /tmp/autorun
    echo "Created swapfile and edited autorun.sh with swapon command".
  fi

}

cd $DEFAULT_VOLUME_DIR
#install_swap

if [[ ! -z ${PASSWORD+x} && ! "$PASSWORD" == "" ]]; then
  echo -e "$PASSWORD\n$PASSWORD" | passwd
fi

system_config

echo "Restarting QNAP web admin and network service new server ip at ETH0_IP $ETH0_IP_ADDRESS or ETH1_IP $ETH1_IP_ADDRESS"
/etc/init.d/thttpd.sh restart

all_pkg_install

while  ( ! [[ -f /etc/init.d/SolinkGateway.sh ]] ||  [[ $(/etc/init.d/SolinkGateway.sh status | grep "info:    No forever processes running" ) != '' ]] ) ;
do 
    echo "Pausing until SolinkConnect installation complete"
    sleep 5
 done
clean_up

if [[ ! -d "/solink/data" ]]; then ln -s /solink/data /share/CACHEDEV1_DATA/.qpkg/SolinkConnect/data ; fi
configure_vms

# Unpack the arp, nmap and tcpdump utilities to /share/Public
if [[ -f $DIR/$UTILS ]]; then tar -xvf $DIR/$UTILS -C $PUBLIC; fi

if [[ "$REBOOT_WHEN_DONE" == "TRUE" ]]; then
  echo "Rebooting"
  reboot
else 
  echo "skip reboot"
  echo "Restarting QNAP web admin and network service new server ip at ETH0_IP $ETH0_IP_ADDRESS or ETH1_IP $ETH1_IP_ADDRESS"
  #/etc/init.d/network.sh restart
  ifconfig eth1 down && ifconfig eth1 up
fi
echo "Done install_functions.sh"
exit 0
