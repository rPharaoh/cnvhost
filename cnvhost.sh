#!/bin/bash

#   Created: Sun August 03 21:04:12 2014 by Nader Nabil @Nader_N2012
#

## Web Site Dirs and Logs

## user can edit this section if it need:
webDir="/var/www/htdocs/"
logDir="/var/www/log/"
vhostsDir="/etc/apache2/vhosts/"

## port for the vhost configration file 80 the stander
port="80"

configFilePath="/etc/apache2/"
configFileName="apache2.conf"
backupConfigFile="apache2.conf.bak"

## Logs Files Access Log And Error Log

errorLog="_error.log"
accessLog="_access.log"

## vhost file for site

configFile=".conf"
injectedComment="# Include vhosts"
injectedCommand="Include vhosts/*.conf"
checkInjectedCommand="Include vhosts/\*.conf"

## user argement and options
opt=$1
siteName=$2
delOpt=$3

## full configration path 
mainConfigFile=$configFilePath$configFileName
mainConfigBackupFile=$configFilePath$backupConfigFile

## vhost paths
## all site will be vhosts/sitename.conf
## later we can make it: vhosts/sitenameFolder/sitename.conf
## for avoiding nasted files and subdomains configrations files

nSiteVHostConfigFile=$vhostsDir$siteName$configFile

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
                
                echo "[+] Configration file is Backed up."
        else
                echo "[-] Error!, Configration file Backup error!"
        fi;
else 
        echo "[-] Configration file is already exist!"
fi;

check=$(cat ${mainConfigFile} | grep -n "${injectedComment}" | head -1 | cut -d: -f2)

if [ "$injectedComment" = "$check" ]; then
        echo "[-] comment already exist!"
else
        echo "[+] adding script comment!"
        echo ${injectedComment} >> ${mainConfigFile}
fi;


## find vhost config folder to apache2 configration

check2=$(cat ${mainConfigFile} | grep -n "${checkInjectedCommand}" | head -1 | cut -d: -f2)

if [ "$injectedCommand" = "$check2" ]; then
        echo "[-] command already exist!"
else
        echo "[+] adding script command!"
        echo ${injectedCommand} >> ${mainConfigFile}
fi;

}

function createAllFolders {

## check the vhost folder if it exist
## =================================
## Main vhosts Dir

if [ ! -d $vhostsDir ]; then
        mkdir -p $vhostsDir;
        echo "[+] Creating Virtual Host Folder."
else 
        echo "[-] '$vhostsDir' Folder already exist!"
fi;

## =================================
## check and create logs folders 
## main Logs Dir

if [ ! -d ${nSiteLogsDIR} ]; then
        mkdir -p ${nSiteLogsDIR};
        echo "[+] Creating Log Folder.";
else 
        echo "[-] '${nSiteLogsDIR}' Folder already exist!"
fi;

## =================================
## make the web site folders

if [ ! -d ${nSiteDIR} ]; then
        mkdir -p ${nSiteDIR};
        mkdir -p ${nSitePubHTM};
        echo "[+] Creating web site folder: " ${nSiteDIR};
        echo "[+] Creating web site public_html folder: " ${nSitePubHTM};

else
        echo "[-] '${nSiteDIR}' Folder already exist!"
        echo "[-] '${nSitePubHTM}' Folder already exist!"
fi;


}

function createLogsFiles {
## ==================================
## create the log files
## this created with -c option

if [ ! -e ${nSiteLogErrorFile} ]; then
        echo '' > ${nSiteLogErrorFile};
        echo "[+] creating file: " ${nSiteLogErrorFile};
else
        echo "[-] '${nSiteLogErrorFile}' File dos not exist!"
fi;

if [ ! -e ${nSiteLogAccessFile} ]; then
        echo '' > ${nSiteLogAccessFile};
        echo "[+] creating file: " ${nSiteLogAccessFile};
else
        echo "[-] '${nSiteLogAccessFile}' File already exist!"
fi;

}

function createVHostFiles {
 
## creating the vhost configration files
## =================================

if [ ! -e ${nSiteVHostConfigFile} ]; then
        echo '' > ${nSiteVHostConfigFile};
        echo "[+] Creating file: " ${nSiteVHostConfigFile};
        ## write the configration 
        vhostFileSchame
else
        echo "[-] '${nSiteVHostConfigFile}' File already exist!"
fi;

}


function vhostFileSchame {

## creating vhost config file for the web site
## =================================

echo "[+] writeing vhost config file schame!"

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

echo "[+] writeing vhost config file, done!"
}

function indexPageSchame {

## simplfiy some stuff
## =================================

if [ ! -e ${nSiteIndex} ]; then 
        echo "[+] creating the index page..."

        echo "<!DOCTYPE html>" > ${nSiteIndex};
        echo "<html>" >> ${nSiteIndex};
        echo "<head>" >> ${nSiteIndex};
        echo "<title> ${siteName} </title> " >> ${nSiteIndex};
        echo "</head>" >> ${nSiteIndex};
        echo "<body>" >> ${nSiteIndex};
        echo "<h1>This is index page for ${siteName} virtual host</h1>" >> ${nSiteIndex};
        echo "</body>" >> ${nSiteIndex};
        echo "</html>" >> ${nSiteIndex};
        
        echo "[+] changing index permissions "
        sudo chown -R $USER:$USER ${nSiteIndex}
else 
        echo "[-] '${nSiteIndex}' File already exist!"
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
        
        echo "[+] deleting web site folder: " ${nSiteDIR};
        echo "[+] deleting web site public_html folder: " ${nSitePubHTM};

else
        echo "[-] '${nSiteDIR}' Folder dos not exist!"
        echo "[-] '${nSitePubHTM}' Folder dos not exist!"
fi;

## delete website logs folder

if [ -d ${nSiteLogsDIR} ]; then
        rm -r -f ${nSiteLogsDIR}

        echo "[+] deleting Log Folder" ${nSiteLogsDIR}; 
else
        echo "[-] '${nSiteLogsDIR}' Folder not exist!"
fi;

}

function deleteVHostFile {
## delete website vhost configration file

if [ -e ${nSiteVHostConfigFile} ]; then

        ## back it up first
        rm -f ${nSiteVHostConfigFile}

        echo "[+] deleting web site config file: " ${nSiteVHostConfigFile}

else
        echo "[-] '${nSiteVHostConfigFile}' File dos not exist!"
fi;

}

function deleteLogFiles {

## ==================================
## delete the log files
## this delete with -d option

if [ -e ${nSiteLogErrorFile} ]; then
        rm -f ${nSiteLogErrorFile};
        echo "[+] deleting file: ", ${nSiteLogErrorFile};
else 
        echo "[-] '${nSiteLogErrorFile}' File dos not exist!"
fi;

if [ -e ${nSiteLogAccessFile} ]; then
        rm -f ${nSiteLogAccessFile};
        echo "[+] deleting file: ", ${nSiteLogAccessFile};
else
        echo "[-] '${nSiteLogAccessFile}' File not exist!"
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

                echo "[+] file removed successfuly."
        else
                echo "[-] Error!, configration file not removed!"
        fi;
else
        echo "[-] Configration file not exist!"

fi;

if [ ! -d ${nSiteLogsDIR} ]; then
        rm -f -r ${nSiteLogsDIR};
        echo "[+] deleting file: ", ${nSiteLogsDIR};
else
        echo "[-] '${nSiteLogsDIR}' File dos not exist!"
fi;

## =================================
## delete the Main vhosts Dir

## here the delete for the hole vhost folder and files P.S do not implement it ## if you make sure its have a spreated command like -da --deleteAll
## this dingers do not use it at all

if [ -d ${vhostsDir} ]; then

        ## back it up first

        rm -f -r ${vhostsDir};
        
        echo "[+] deleting web site folder: ", ${vhostsDir};

else
        echo "[-] '${vhostsDir}' Folder dos not exist!"
        
fi;

}

function restartApache2 {

        ## restart apache server for the new changes
        echo "[*] Restarting apache2 server."

        ## restrt apache2 in Ubuntu system
        sudo /etc/init.d/apache2 restart;

        ## you can also use service apahce2 restart     
        #sudo service apahce2 restart

        ## on CentOS systems 
        #sudo /etc/init.d/httpd restart

        exit;
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

function main {

## the execution of the program

if [ "$opt" = "-da" ]; then
        read -p "deleting all logs and vhosts, are you sure [Y - N] ? " useropt
        
        if [[ "$useropt" = "y" || "$useropt" = "Y"  ]]; then
                deleteAllDir

        elif [[ "$useropt" = "y" || "$useropt" = "N" ]]; then
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
                echo "Createing the new virtual host for '$siteName' ..."
                createSite

        elif [ "$opt" = "-d" ]; then
                echo "deleting $siteName !"     
                deleteSite
        else 
                echo "Error!, unknown option."
        fi;
else 
        
        echo "error!, please check your domain name."
        exit 1
fi;

}

## Execute the Script from the main function 

main
