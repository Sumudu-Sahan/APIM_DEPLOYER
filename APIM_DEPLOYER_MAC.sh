#APIM distribution configurations below.
pathToBasePack=""
zipFilename=""
extractedPackDirName=""

#MySQL Connector path and the file below
pathToMySQLConnectorFile=""

#Constant. Do not change the below line
RESULT_SUCCESS=1

#APIM deployment patterns. Currently supporting only the PATTERN3
DEPLOYMENT_GWCP="GWCP"
DEPLOYMENT_FULL="FULL"

#MySQL Root user credentials below
MYSQL_ROOT_USERNAME=""
MYSQL_ROOT_PASSWORD=""

#Collecting the parsed flag for the process
deploymentPattern=""

#Database names below
APIM_DB_WSO2AM_400=""
SHARED_DB_WSO2AM_400=""

UPDATE_LEVEL=0
UPDATE_SKIP_LEVEL=0

LOG_STATEMENT=""
timestamp=""

printVersion(){
  printf "V1.0.0\n"
}

printUsage(){
  echo "-v  --version => To get the version of this script"
  echo "Eg: \n sh APIM_DEPLOYER_<OS>.sh -v \n"

  echo "-h  --help => Get all the information regarding this script"
  echo "Eg: \n sh APIM_DEPLOYER_<OS>.sh -h \n"

  echo "-d  => Parse the deployment pattern here"
  echo "Available patterns\n  * $DEPLOYMENT_GWCP\n  * $DEPLOYMENT_FULL"
  echo "-f  => Base pack location path"
  echo "-z  => ZIP file name of the APIM pack (Eg: wso2am-4.0.0.zip)"
  echo "-b  => Extracted directory name of the pack. You can take this name inside the ZIP file. (Eg: wso2am-4.0.0)"
  echo "-r  => Root user name of the MySQL server"
  echo "-p  => Root user password of the MySQL server"
  echo "-c  => Path of the MySQL JDBC connector Jar"
  echo "-a  => APIM database name"
  echo "-s  => SHARED database name"
  echo "-u  => Update level that needs to update the pack. (optional)"
  
  echo "Eg: \n sh APIM_DEPLOYER_<OS>.sh -f /home/sumudu/.wum3/products/wso2am/4.0.0/wso2am-4.0.0.zip -z wso2am-4.0.0.zip -b wso2am-4.0.0 -d FULL -r root -p PASSWORD -c /home/sumudu/.wum3/products/wso2am/mysql-connector-java-8.0.27.jar -a TEST_APIM_DB -s TEST_SHARED_DB -u 91"
}

for var in "$@"
    do
      case "$var" in
      "-v" | "--version") 
        printVersion
        exit
      ;;
      "-h" | "--help") 
        printUsage
        exit
      ;;
    esac
done

while getopts "d:f:z:b:p:r:c:a:s:u:" flags
  do
    case "${flags}" in
      d) deploymentPattern=${OPTARG};;
      b) extractedPackDirName=${OPTARG};;
      z) zipFilename=${OPTARG};;
      f) pathToBasePack=${OPTARG};;
      r) MYSQL_ROOT_USERNAME=${OPTARG};;
      p) MYSQL_ROOT_PASSWORD=${OPTARG};;
      c) pathToMySQLConnectorFile=${OPTARG};;
      a) APIM_DB_WSO2AM_400=${OPTARG};;
      s) SHARED_DB_WSO2AM_400=${OPTARG};;
      u) UPDATE_LEVEL=${OPTARG};;
    esac
  done

ARGS=$(getopt -a --options fzdbprcasvhu --long "file,zip,base,deployment,password,version,help,root,connector,apim,shared,update" -- "$@")

GWCPDeployment(){
  LOG_STATEMENT="Starting CP GW deployment\n"
  printINFOLog
  copyTheBasePackToDirs
}

TMSeparatedDeployment(){
  LOG_STATEMENT="Starting Traffic Manager separated deployment\n"
  printINFOLog
  copyTheBasePackToDirs
}

checkTheUpdateFlagAndUpdate(){
  if [ "$UPDATE_LEVEL" -gt "$UPDATE_SKIP_LEVEL" ]
    then
      LOG_STATEMENT="Executing the update 2.0 script\n"
      printINFOLog
      LOG_STATEMENT="Updating the Update 2.0- client\n"
      printINFOLog
      
      cd ../../U2_CLIENT/bin
      ./wso2update_darwin_original
      
      LOG_STATEMENT="Updated the Update 2.0- client\n"
      printINFOLog

      LOG_STATEMENT="Starting to update the API Manager pack to level: $UPDATE_LEVEL\n"
      printINFOLog

      rm -rf ../../distributed_deployment/0_gw/wso2am-4.0.0/bin/wso2update_darwin
      cp wso2update_darwin ../../distributed_deployment/0_gw/wso2am-4.0.0/bin

      cd ../../distributed_deployment/0_gw/wso2am-4.0.0/bin
      ./wso2update_darwin --no-backup --level $UPDATE_LEVEL

      LOG_STATEMENT="Updated the API Manager pack to level: $UPDATE_LEVEL\n"
      printINFOLog
    else
     LOG_STATEMENT="Skipping the update script and continue the deployment\n"
     printINFOLog
  fi
  copyTheDBMSConnector
}

copyTheBasePackToDirs(){
  LOG_STATEMENT="Creating the directory structure\n"
  printINFOLog
  rm -rf distributed_deployment
  mkdir distributed_deployment
  cd distributed_deployment

  if [ "$deploymentPattern" = "$DEPLOYMENT_GWCP" ]
    then
      mkdir 0_gw 1_cp
    else
      mkdir 0_gw 1_tm 2_cp
  fi

  LOG_STATEMENT="Created the directory structure\n"
  printINFOLog

  LOG_STATEMENT="Copying the ZIP pack to 0_gw directory\n"
  printINFOLog
  cp $pathToBasePack 0_gw
  LOG_STATEMENT="Copied the ZIP pack to 0_gw directory\n"
  printINFOLog
  
  cd 0_gw
  extractTheBasePack

  checkTheUpdateFlagAndUpdate
}

copyTheDBMSConnector(){
  LOG_STATEMENT="Copying the DBMS connector\n"
  printINFOLog
  cd ../../
  cp $pathToMySQLConnectorFile $extractedPackDirName/repository/components/lib
  LOG_STATEMENT="Copied the DBMS connector\n"
  printINFOLog

  if [ "$deploymentPattern" = "$DEPLOYMENT_GWCP" ]
    then
      GWCPDeployments
    else
      fullDeployment
  fi
}

GWCPDeployments(){
  LOG_STATEMENT="Copying the extracted content to 1_cp\n"
  printINFOLog
  cp -a $extractedPackDirName ../1_cp
  LOG_STATEMENT="Copied the extracted content to 1_cp\n"
  printINFOLog

  cd ..

  LOG_STATEMENT="Creating the gateway worker profile\n"
  printINFOLog
  sh 0_gw/wso2am-4.0.0/bin/profileSetup.sh -Dprofile=gateway-worker
  LOG_STATEMENT="Created the gateway worker profile\n"
  printINFOLog

  LOG_STATEMENT="Creating the control plane profile\n"
  printINFOLog
  sh 1_cp/wso2am-4.0.0/bin/profileSetup.sh -Dprofile=control-plane
  LOG_STATEMENT="Created the control plane profile\n"
  printINFOLog


  LOG_STATEMENT="Configuring databases by executing scripts\n[APIM_DB] => $APIM_DB_WSO2AM_400\n[SHARED_DB] => $SHARED_DB_WSO2AM_400\nYou need to enter the MySQL root password to continue this step\n"
  printINFOLog

  cd 0_gw/wso2am-4.0.0/dbscripts
  mysql -u$MYSQL_ROOT_USERNAME -p -e "DROP DATABASE IF EXISTS $APIM_DB_WSO2AM_400; DROP DATABASE IF EXISTS $SHARED_DB_WSO2AM_400; CREATE DATABASE $APIM_DB_WSO2AM_400;CREATE DATABASE $SHARED_DB_WSO2AM_400;USE $APIM_DB_WSO2AM_400;SOURCE apimgt/mysql.sql;USE $SHARED_DB_WSO2AM_400;SOURCE mysql.sql;SHOW TABLES;USE $APIM_DB_WSO2AM_400;SHOW TABLES;"
  
  LOG_STATEMENT="Configured databases by executing scripts successfully\n"
  printINFOLog

  cd ../../..

  rm -rf 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  rm -rf 1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  cd ../toml_files

  cp gateway-worker-2.toml ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf
  cp control-plane-2.toml ../distributed_deployment/1_cp/wso2am-4.0.0/repository/conf

  LOG_STATEMENT="Starting to replacing deployment.toml files in all 2 nodes by taking from the toml_files directory\n"
  printINFOLog

  mv ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf/gateway-worker-2.toml ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  mv ../distributed_deployment/1_cp/wso2am-4.0.0/repository/conf/control-plane-2.toml ../distributed_deployment/1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="deployment.toml file replacement is success\n"
  printINFOLog

  cd ../distributed_deployment

  LOG_STATEMENT="Starting to change root user configurations in deployment.toml files\n"
  printINFOLog

  # #FOR MAC OS,
  # #sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml

  sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  sed -i '' "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/gi" 1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="MySQL root username change is completed successfully files\n"
  printINFOLog

  LOG_STATEMENT="Starting to change [database.shared_db] database name configurations in deployment.toml files\n"
  printINFOLog

  sed -i '' "s/SHARED_DB_WSO2AM_400/$SHARED_DB_WSO2AM_400/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/SHARED_DB_WSO2AM_400/$SHARED_DB_WSO2AM_400/gi" 1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="[database.shared_db] database name configurations changes successfully completed\n"
  printINFOLog

  LOG_STATEMENT="Starting to change [database.apim_db] database name configurations in deployment.toml files\n"
  printINFOLog

  sed -i '' "s/APIM_DB_WSO2AM_400/$APIM_DB_WSO2AM_400/gi" 1_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="[database.apim_db] database name configurations changes successfully completed\n"
  printINFOLog

  sleep 2

  LOG_STATEMENT="Distributed deployment is completed. Now you can start all nodes by executing the api-manager.sh file. (OFFSET value already available in the deployment.toml file.)\n"
  printINFOLog

  LOG_STATEMENT="\n\nNODE DETAILS \n\n----------- Control Plane -----------\n\n * Offset: 1\n * Carbon Console URL: https://localhost:9444/carbon\n * Publisher Access URL: https://localhost:9444/publisher\n * Dev Portal Access URL: https://localhost:9444/devportal\n\n----------- API Gateway -----------\n\n * Offset: 0\n * Carbon Console URL: https://localhost:9443/carbon\n * HTTP URL: https://localhost:8280\n * HTTPS URL: https://localhost:8243\n\n"
  printConfigDetail
}

fullDeployment(){
  LOG_STATEMENT="Copying the extracted content to 1_tm\n"
  printINFOLog
  cp -a $extractedPackDirName ../1_tm
  LOG_STATEMENT="Copied the extracted content to 1_tm\n"
  printINFOLog

  LOG_STATEMENT="Copying the extracted content to 2_cp\n"
  printINFOLog
  cp -a $extractedPackDirName ../2_cp
  LOG_STATEMENT="Copied the extracted content to 2_cp\n"
  printINFOLog

  cd ..

  LOG_STATEMENT="Creating the gateway worker profile\n"
  printINFOLog
  sh 0_gw/wso2am-4.0.0/bin/profileSetup.sh -Dprofile=gateway-worker
  LOG_STATEMENT="Created the gateway worker profile\n"
  printINFOLog
 
  LOG_STATEMENT="Creating the traffic manager profile\n"
  printINFOLog
  sh 1_tm/wso2am-4.0.0/bin/profileSetup.sh -Dprofile=traffic-manager
  LOG_STATEMENT="Created the traffic manager profile\n"
  printINFOLog
  
  LOG_STATEMENT="Creating the control plane profile\n"
  printINFOLog
  sh 2_cp/wso2am-4.0.0/bin/profileSetup.sh -Dprofile=control-plane
  LOG_STATEMENT="Created the control plane profile\n"
  printINFOLog

  LOG_STATEMENT="Configuring databases by executing scripts\n[APIM_DB] => $APIM_DB_WSO2AM_400\n[SHARED_DB] => $SHARED_DB_WSO2AM_400\nYou need to enter the MySQL root password to continue this step\n"
  printINFOLog

  cd 0_gw/wso2am-4.0.0/dbscripts
  mysql -u$MYSQL_ROOT_USERNAME -p -e "DROP DATABASE IF EXISTS $APIM_DB_WSO2AM_400; DROP DATABASE IF EXISTS $SHARED_DB_WSO2AM_400; CREATE DATABASE $APIM_DB_WSO2AM_400;CREATE DATABASE $SHARED_DB_WSO2AM_400;USE $APIM_DB_WSO2AM_400;SOURCE apimgt/mysql.sql;USE $SHARED_DB_WSO2AM_400;SOURCE mysql.sql;SHOW TABLES;USE $APIM_DB_WSO2AM_400;SHOW TABLES;"
  
  LOG_STATEMENT="Configured databases by executing scripts successfully\n"
  printINFOLog

  cd ../../..

  rm -rf 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  rm -rf 1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  rm -rf 2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  cd ../toml_files

  cp gateway-worker.toml ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf
  cp traffic-manager.toml ../distributed_deployment/1_tm/wso2am-4.0.0/repository/conf
  cp control-plane.toml ../distributed_deployment/2_cp/wso2am-4.0.0/repository/conf

  LOG_STATEMENT="Starting to replacing deployment.toml files in all 3 nodes by taking from the toml_files directory\n"
  printINFOLog

  mv ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf/gateway-worker.toml ../distributed_deployment/0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  mv ../distributed_deployment/1_tm/wso2am-4.0.0/repository/conf/traffic-manager.toml ../distributed_deployment/1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  mv ../distributed_deployment/2_cp/wso2am-4.0.0/repository/conf/control-plane.toml ../distributed_deployment/2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="deployment.toml file replacement is success\n"
  printINFOLog

  cd ../distributed_deployment

  LOG_STATEMENT="Starting to change root user configurations in deployment.toml files\n"
  printINFOLog

  # #FOR MAC OS,
  # #sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml

  sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_USERNAME/$MYSQL_ROOT_USERNAME/gi" 2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  sed -i '' "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/gi" 1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/gi" 2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="MySQL root username change is completed successfully files\n"
  printINFOLog

  LOG_STATEMENT="Starting to change [database.shared_db] database name configurations in deployment.toml files\n"
  printINFOLog

  sed -i '' "s/SHARED_DB_WSO2AM_400/$SHARED_DB_WSO2AM_400/gi" 0_gw/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/SHARED_DB_WSO2AM_400/$SHARED_DB_WSO2AM_400/gi" 1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/SHARED_DB_WSO2AM_400/$SHARED_DB_WSO2AM_400/gi" 2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="[database.shared_db] database name configurations changes successfully completed\n"
  printINFOLog

  LOG_STATEMENT="Starting to change [database.apim_db] database name configurations in deployment.toml files\n"
  printINFOLog

  sed -i '' "s/APIM_DB_WSO2AM_400/$APIM_DB_WSO2AM_400/gi" 1_tm/wso2am-4.0.0/repository/conf/deployment.toml
  sed -i '' "s/APIM_DB_WSO2AM_400/$APIM_DB_WSO2AM_400/gi" 2_cp/wso2am-4.0.0/repository/conf/deployment.toml

  LOG_STATEMENT="[database.apim_db] database name configurations changes successfully completed\n"
  printINFOLog

  sleep 2

  LOG_STATEMENT="Distributed deployment is completed. Now you can start all nodes by executing the api-manager.sh file. (OFFSET value already available in the deployment.toml file.)\n"
  printINFOLog

  LOG_STATEMENT="\n\nNODE DETAILS \n\n----------- Control Plane -----------\n\n * Offset: 2\n * Carbon Console URL: https://localhost:9445/carbon\n * Publisher Access URL: https://localhost:9445/publisher\n * Dev Portal Access URL: https://localhost:9445/devportal\n\n----------- Traffic Manager -----------\n\n * Offset: 1\n * Carbon Console URL: https://localhost:9444/carbon\n\n----------- API Gateway -----------\n\n * Offset: 0\n * Carbon Console URL: https://localhost:9443/carbon\n * HTTP URL: https://localhost:8280\n * HTTPS URL: https://localhost:8243\n\n"
  printConfigDetail
}

extractTheBasePack(){
  LOG_STATEMENT="Extracting the ZIP file\n"
  printINFOLog
  
  unzip $zipFilename

  LOG_STATEMENT="ZIP file extracted\n"
  printINFOLog
}

init(){
  LOG_STATEMENT="Starting the distributed deployment script of the WSO2 API Manager 4.0.0\n"
  printINFOLog
  LOG_STATEMENT="Created by Sumudu Weerasuriya from the Integration CS Team\n"
  printINFOLog

  for var in "$@"
    do
      case "$var" in
      "-v" | "--version") 
        printVersion
        exit
      ;;
      "-h" | "--help") 
        printUsage
        exit
      ;;
    esac
    done

    if [ -z "$deploymentPattern" ]
      then
        LOG_STATEMENT="Deployment pattern is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$extractedPackDirName" ]
      then
        LOG_STATEMENT="Extracted ZIP directory name is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$zipFilename" ]
      then
        LOG_STATEMENT="Zip file name is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$pathToBasePack" ]
      then
        LOG_STATEMENT="Base pack path is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$pathToMySQLConnectorFile" ]
      then
        LOG_STATEMENT="JDBC connector path is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$MYSQL_ROOT_USERNAME" ]
      then
        LOG_STATEMENT="MySQL root user name is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$MYSQL_ROOT_PASSWORD" ]
      then
        LOG_STATEMENT="MySQL root user password is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$APIM_DB_WSO2AM_400" ]
      then
        LOG_STATEMENT="APIM database name is not defined\n"
        printERRLog
        exit 1
    fi

    if [ -z "$SHARED_DB_WSO2AM_400" ]
      then
        LOG_STATEMENT="SHARED database name is not defined\n"
        printERRLog
        exit 1
    fi

    LOG_STATEMENT="\n\nDEPLOYMENT DETAILS \n\n* Deployment Pattern: $deploymentPattern \n* Base Pack Path: $pathToBasePack\n* ZIP Name: $zipFilename\n* Update Level: $UPDATE_LEVEL\n* Directory Name Of The Extracted Content: $extractedPackDirName \n\n"
    printConfigDetail

    LOG_STATEMENT="\n\nDATABASE DETAILS \n\n* JDBC Connector File Path: $pathToMySQLConnectorFile \n* ROOT User Name: $MYSQL_ROOT_USERNAME\n* APIM Database Name: $APIM_DB_WSO2AM_400\n* Shared Database Name: $SHARED_DB_WSO2AM_400\n\n"
    printConfigDetail

    case "$deploymentPattern" in
      $DEPLOYMENT_GWCP) 
        GWCPDeployment
      ;;
      $DEPLOYMENT_FULL) 
        TMSeparatedDeployment
      ;;
      *)
        LOG_STATEMENT="Invalid Deployment Pattern"
        printERRLog
        exit 1;;
    esac
}

getSystemTimestamp() {
	timestamp=`date '+%Y-%m-%d %H:%M:%S' | sed 's/\(:[0-9][0-9][0-9]\)[0-9]*$/\1/' `
}

printINFOLog(){
  getSystemTimestamp
  printf "[${timestamp}] INFO - $LOG_STATEMENT"
}

printERRLog(){
  getSystemTimestamp
  printf "[${timestamp}] ERROR - $LOG_STATEMENT"
}

printConfigDetail(){
  getSystemTimestamp
  printf "[${timestamp}] CONFIG_DETAIL - $LOG_STATEMENT"
}

init