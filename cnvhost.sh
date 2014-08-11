#!/bin/bash

#   Created: Sun August 03 21:04:12 2014 by Nader Nabil @Nader_N2012
#

## sudo get the permissions first 

LRED="\033[01;31m"
LGREEN="\033[01;32m"

## Web Site Dirs and Logs
## user can edit this section if it need:
## this configration for ubuntu servers 
webDir="/var/www/htdocs/"
vhostsDir="vhosts/"

## port for the vhost configration file 80 the stander
port="80"

## vhost file for site
configFile=".conf"
injectedComment="# Include vhosts"
injectedCommand="Include vhosts/*.conf"
checkInjectedCommand="Include vhosts/\*.conf"

## for CentOS can use configration like
## find system type
## CentOS or Ubuntu

ubuntu=$(cat /proc/version | grep -o ubuntu)
centOS=$(cat /proc/version | grep -o centos)

if [[ -n $ubuntu && "$ubuntu" == "ubuntu" ]]; then
        echo -e "${LGREEN}[+]\e[0m System detacted: " $ubuntu

        configFilePath="/etc/apache2/"
        configFileName="apache2.conf"
        backupConfigFile="apache2.conf.bak" 
        logDir="/var/www/log/" 

elif [[ -n $centOS && "$centOS" == "centos" ]]; then
        echo -e "${LGREEN}[+]\e[0m System detacted: " $centOS

        ## for CentOS can use configration like
        configFilePath="/etc/httpd/conf/"
        configFileName="httpd.conf"
        backupConfigFile="httpd.conf.bak"
        logDir="/etc/httpd/logs/"

        injectedCommand="Include conf/vhosts/*.conf"
        checkInjectedCommand="Include conf/vhosts/\*.conf"

else
        echo -e "${LRED}[-]\e[0m error!, can't detact system"
        echo -e "${LGREEN}[+]\e[0m using defualt setting"
        ## this the defualt configration for the script
        configFilePath="/etc/apache2/conf"
        configFileName="apache2.conf"
        backupConfigFile="apache2.conf.bak" 
        logDir="/var/www/log/" 

fi;

## Logs Files Access Log And Error Log
errorLog="_error.log"
accessLog="_access.log"

## user argement and options
opt=$1
siteName=$2
delOpt=$3

## full configration path 
mainConfigFile=$configFilePath$configFileName
mainConfigBackupFile=$configFilePath$backupConfigFile
mainvHostDir=$configFilePath$vhostsDir

## vhost paths
## all site will be vhosts/sitename.conf
## later we can make it: vhosts/sitenameFolder/sitename.conf
## for avoiding nasted files and subdomains configrations files

nSiteVHostConfigFile=$mainvHostDir$siteName$configFile

## web site paths 
nSiteDIR=$webDir$siteName"/"
nSitePubHTM=$webDir$siteName"/public_html/"
nSiteIndex=$webDir$siteName"/public_html/index.html"
nSiteLogsDIR=$logDir$siteName"/"
nSiteLogErrorFile=$logDir$siteName"/"$siteName$errorLog
nSiteLogAccessFile=$logDir$siteName"/"$siteName$accessLog

function editApache2Config {

## open and edit apache2 configration file 
## and adding vhost configration files into     
## find and add Include path of the vhost folder and file

## first search for the defination in the configration file
## # Include vhosts
## if it exitst the vhosts already added
## else add the vhosts configration 
## Include vhosts/*.conf

## Used Variables: configFile, injectedComment, injectedCommand 
## mainConfigBackupFile, mainConfigFile, checkInjectedCommand

## find comment of our script

## backup main configration file

if [ ! -e ${mainConfigBackupFile} ]; then

        echo "Configration file Backup is running..."
        cp ${mainConfigFile} ${mainConfigBackupFile}

        if [ -e ${mainConfigBackupFile} ]; then 
                
                echo -e "${LGREEN}[+]\e[0m Configration file is Backed up."
        else
                echo -e "${LRED}[-]\e[0m Error!, Configration file Backup error!"
        fi;
else 
        echo -e "${LRED}[-]\e[0m Configration file is already exist!"
fi;

check=$(cat ${mainConfigFile} | grep -n "${injectedComment}" | head -1 | cut -d: -f2)

if [ "$injectedComment" = "$check" ]; then
        echo -e "${LRED}[-]\e[0m comment already exist!"
else
        echo -e "${LGREEN}[+]\e[0m adding script comment!"
        echo ${injectedComment} >> ${mainConfigFile}
fi;

## find vhost config folder to apache2 configration

check2=$(cat ${mainConfigFile} | grep -n "${checkInjectedCommand}" | head -1 | cut -d: -f2)

if [ "$injectedCommand" = "$check2" ]; then
        echo -e "${LRED}[-]\e[0m command already exist!"
else
        echo -e "${LGREEN}[+]\e[0m adding script command!"
        echo ${injectedCommand} >> ${mainConfigFile}
fi;

}

function createAllFolders {

## check the vhost folder if it exist
## =================================
## Main vhosts Dir

if [ ! -d $mainvHostDir ]; then
        mkdir -p $mainvHostDir;
        echo -e "${LGREEN}[+]\e[0m Creating Virtual Host Folder."
else 
        echo -e "${LRED}[-]\e[0m '$mainvHostDir' Folder already exist!"
fi;

## =================================
## check and create logs folders 
## main Logs Dir

if [ ! -d ${nSiteLogsDIR} ]; then
        mkdir -p ${nSiteLogsDIR}
        echo -e "${LGREEN}[+]\e[0m Creating Log Folder."
else 
        echo -e "${LRED}[-]\e[0m '${nSiteLogsDIR}' Folder already exist!"
fi;

## =================================
## make the web site folders

if [ ! -d ${nSiteDIR} ]; then
        mkdir -p ${nSiteDIR}
        mkdir -p ${nSitePubHTM}
        echo -e "${LGREEN}[+]\e[0m Creating web site folder: " ${nSiteDIR};
        echo -e "${LGREEN}[+]\e[0m Creating web site public_html folder: " ${nSitePubHTM};

else
        echo -e "${LRED}[-]\e[0m '${nSiteDIR}' Folder already exist!"
        echo -e "${LRED}[-]\e[0m '${nSitePubHTM}' Folder already exist!"
fi;


}

function createLogsFiles {
## ==================================
## create the log files
## this created with -c option

if [ ! -e ${nSiteLogErrorFile} ]; then
        echo '' > ${nSiteLogErrorFile}
        echo -e "${LGREEN}[+]\e[0m creating file: " ${nSiteLogErrorFile}
else
        echo -e "${LRED}[-]\e[0m '${nSiteLogErrorFile}' File dos not exist!"
fi;

if [ ! -e ${nSiteLogAccessFile} ]; then
        echo '' > ${nSiteLogAccessFile}
        echo -e "${LGREEN}[+]\e[0m creating file: " ${nSiteLogAccessFile}
else
        echo -e "${LRED}[-]\e[0m '${nSiteLogAccessFile}' File already exist!"
fi;

}

function createVHostFiles {
 
## creating the vhost configration files
## =================================

if [ ! -e ${nSiteVHostConfigFile} ]; then
        echo '' > ${nSiteVHostConfigFile}
        echo -e "${LGREEN}[+]\e[0m Creating file: " ${nSiteVHostConfigFile}
        ## write the configration 
        vhostFileSchame
else
        echo -e "${LRED}[-]\e[0m '${nSiteVHostConfigFile}' File already exist!"
fi;

}


function vhostFileSchame {

## creating vhost config file for the web site
## =================================

echo -e "${LGREEN}[+]\e[0m writeing vhost config file schame!"

echo "<VirtualHost *:${port}>" >> ${nSiteVHostConfigFile}

printf "\t # this 1\n" >> ${nSiteVHostConfigFile}
printf "\t ServerName www.%s \n" "${siteName}" >> ${nSiteVHostConfigFile}
printf "\t ServerAlias %s \n" "${siteName}" >> ${nSiteVHostConfigFile}

printf "\t # this 2\n" >> ${nSiteVHostConfigFile}
printf "\t ServerAdmin admin@%s \n" "${siteName}" >> ${nSiteVHostConfigFile}
printf "\t DocumentRoot %s \n" "${nSitePubHTM}" >> ${nSiteVHostConfigFile}

printf "\t # this 3\n" >> ${nSiteVHostConfigFile}
printf "\t ErrorLog %s \n" "${nSiteLogErrorFile}" >> ${nSiteVHostConfigFile}
printf "\t CustomLog %s combined\n" "${nSiteLogAccessFile}" >> ${nSiteVHostConfigFile}

echo "</VirtualHost>" >> ${nSiteVHostConfigFile}

echo -e "${LGREEN}[+]\e[0m writeing vhost config file, done!"
}

function indexPageSchame {

## simplfiy some stuff
## =================================

if [ ! -e ${nSiteIndex} ]; then 
        echo -e "${LGREEN}[+]\e[0m creating the index page..."

        echo "<!DOCTYPE html>" > ${nSiteIndex}
        echo "<html>" >> ${nSiteIndex}
        echo "<head>" >> ${nSiteIndex}
        echo "<title> ${siteName} </title> " >> ${nSiteIndex}
        echo "</head>" >> ${nSiteIndex}
        echo "<body>" >> ${nSiteIndex};
        echo "<h1>This is index page for $siteName virtual host</h1>" >> ${nSiteIndex}
        echo "</body>" >> ${nSiteIndex}
        echo "</html>" >> ${nSiteIndex}
        
        echo -e "${LGREEN}[+]\e[0m changing index permissions "
        sudo chown -R $USER:$USER ${nSiteIndex}
else 
        echo -e "${LRED}[-]\e[0m '${nSiteIndex}' File already exist!"
fi;

}

function deleteFolders {

## =================================
## delete the Main website dir and its content
## this delete with option -d

if [ -d ${nSiteDIR} ]; then

        ## back it up first
        
        rm -f -r ${nSitePubHTM}
        rm -f -r ${nSiteDIR}
        
        echo -e "${LGREEN}[+]\e[0m deleting web site folder: " ${nSiteDIR}
        echo -e "${LGREEN}[+]\e[0m deleting web site public_html folder: " ${nSitePubHTM}

else
        echo -e "${LRED}[-]\e[0m '${nSiteDIR}' Folder dos not exist!"
        echo -e "${LRED}[-]\e[0m '${nSitePubHTM}' Folder dos not exist!"
fi;

## delete website logs folder

if [ -d ${nSiteLogsDIR} ]; then
        rm -r -f ${nSiteLogsDIR}

        echo -e "${LGREEN}[+]\e[0m deleting Log Folder" ${nSiteLogsDIR}
else
        echo -e "${LRED}[-]\e[0m '${nSiteLogsDIR}' Folder not exist!"
fi;

}

function deleteVHostFile {
## delete website vhost configration file

if [ -e ${nSiteVHostConfigFile} ]; then

        ## back it up first
        rm -f ${nSiteVHostConfigFile}

        echo -e "${LGREEN}[+]\e[0m deleting web site config file: " ${nSiteVHostConfigFile}

else
        echo -e "${LRED}[-]\e[0m '${nSiteVHostConfigFile}' File dos not exist!"
fi;

}

function deleteLogFiles {

## ==================================
## delete the log files
## this delete with -d option

if [ -e ${nSiteLogErrorFile} ]; then
        rm -f ${nSiteLogErrorFile};
        echo -e "${LGREEN}[+]\e[0m deleting file: ", ${nSiteLogErrorFile}
else 
        echo -e "${LRED}[-]\e[0m '${nSiteLogErrorFile}' File dos not exist!"
fi;

if [ -e ${nSiteLogAccessFile} ]; then
        rm -f ${nSiteLogAccessFile};
        echo -e "${LGREEN}[+]\e[0m deleting file: ", ${nSiteLogAccessFile}
else
        echo -e "${LRED}[-]\e[0m '${nSiteLogAccessFile}' File not exist!"
fi;

}

function deleteAllDir {

## =================================
## check and create logs folders 
## main Logs Dir

## here the delete for the hole logs folder and files P.S do not implement it 
## if you make sure its have a spreated command like -da -l --deleteAll --logs

## backup main configration file

if [ -e ${mainConfigBackupFile} ]; then

        echo "Removing configration file."
        rm -r -f ${mainConfigFile}
        mv ${mainConfigBackupFile} ${mainConfigFile}

        if [ ! -e ${mainConfigBackupFile} ]; then

                echo -e "${LGREEN}[+]\e[0m file removed successfuly."
        else
                echo -e "${LRED}[-]\e[0m Error!, configration file not removed!"
        fi;
else
        echo -e "${LRED}[-]\e[0m Configration file not exist!"

fi;

if [ ! -d ${nSiteLogsDIR} ]; then
        rm -f -r ${nSiteLogsDIR};
        echo -e "${LGREEN}[+]\e[0m deleting file: ", ${nSiteLogsDIR}
else
        echo -e "${LRED}[-]\e[0m '${nSiteLogsDIR}' File dos not exist!"
fi;

## =================================
## delete the Main vhosts Dir

## here the delete for the hole vhost folder and files P.S do not implement it ## if you make sure its have a spreated command like -da --deleteAll
## this dingers do not use it at all

if [ -d ${mainvHostDir} ]; then

        ## back it up first

        rm -f -r ${mainvHostDir};
        
        echo -e "${LGREEN}[+]\e[0m deleting web site folder: ", ${mainvHostDir}

else
        echo -e "${LRED}[-]\e[0m '${mainvHostDir}' Folder dos not exist!"
        
fi;

}

function restartApache2 {

        ## restart apache server for the new changes
        echo "[*] Restarting apache2 server."

if [[ -n $ubuntu && "$ubuntu" == "ubuntu" ]]; then

        ## restrt apache2 in Ubuntu system
        sudo /etc/init.d/apache2 restart
        exit;
        
elif [[ -n $centOS && "$centOS" == "centos" ]]; then
        ## other commands for apache on CentOS
        sudo /etc/init.d/httpd stop
        sudo /etc/init.d/httpd start
        exit;
fi;

}

function createSite {

## all folder created first     
## call the functions to do this jobi
## creating new website in virtual host

# Editing the configration file of Apache server 
# Tested and working
editApache2Config

# creating all folder for the site 
createAllFolders

# creating the logs files error and access 
createLogsFiles

# creating the vhost config file
createVHostFiles

# adding the html page
indexPageSchame

# restarting the apache server for the new configration
restartApache2

}

function deleteSite {

## all files deleted first
## this delete the web site and it logs only 

# delete the site logs 
deleteLogFiles

## delete vhost configration file
deleteVHostFile

## delete the website folders and all its content
deleteFolders

# restarting the apache server for the new configration
restartApache2

}

function sysCheck {

## find system type
## CentOS or Ubuntu

ubuntu=$(cat /proc/version | grep -o ubuntu)
centOS=$(cat /proc/version | grep -o centos)

if [[ -n $ubuntu && "$ubuntu" == "ubuntu" ]]; then
        echo -e "${LGREEN}[+]\e[0m System detacted: " $ubuntu

elif [[ -n $centOS && "$centOS" == "centos" ]]; then
        echo -e "${LGREEN}[+]\e[0m System detacted: " $centOS
else
        echo -e "${LRED}[-]\e[0m error!, can't detact system"
fi;

}

function main {

## the execution of the program

if [ "$opt" = "-da" ]; then
        read -p "deleting all logs and vhosts, are you sure [Y - N] ? " useropt
        
        if [[ "$useropt" = "y" || "$useropt" = "Y"  ]]; then
                deleteAllDir

        elif [[ "$useropt" = "n" || "$useropt" = "N" ]]; then
                exit 1
        fi;
fi;

if [ -z $siteName  ]; then
        echo " "
        echo "Usage: $0 [option] [-c, -d] domanin.com"
        echo "Example: $0 -c example.com" 
        echo "-c creating new virtual host website"
        echo "-d deleting the site you assient"
        echo "-da deleting all logs and vhosts, example: $0 -da "
        echo " "
        exit 1
fi;

## checking the domain name with Regex and adding it to a variable

regex=$(echo $siteName | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)')

if [ "$regex" = "$siteName" ]; then
        
        if [ "$opt" = "-c" ]; then
                echo -e "${LGREEN}[+]\e[0m Createing the new virtual host for '$siteName' ..."
                createSite

        elif [ "$opt" = "-d" ]; then
                echo -e "${LGREEN}[+]\e[0m deleting $siteName !"     
                deleteSite
        else 
                echo -e "${LRED}[-]\e[0m Error!, unknown option."
        fi;
else 
        
        echo -e "${LRED}[-]\e[0m error!, please check your domain name."
        exit 1
fi;

}

## Execute the Script from the main function 

main
