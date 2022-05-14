# APIM_DEPLOYER
This script will help to deploy the API Manager with MySQL databases within few seconds


Thank you for using the APIM Deployer script to deploy the API Manager 3.2.0 in Fully Distributed deployment

##For MAC OS users can use the below command to deploy the API Manager 3.2.0 in fully distributed way.

    ###FORMAT
        ```sh APIM_DEPLOYER_MAC.sh -f <APIM_ZIP_PATH>/<APIM_ZIP_FILE_NAME> -z <APIM_ZIP_FILE_NAME> -b wso2am-3.2.0 -d <DEPLOYMENT_PATTERN> -r <MYSQL_ROOT_USERNAME> -p <MYSQL_ROOT_PASSWORD> -c <JDBC_CONNECTOR_JAR_LOCATION>/<JDBC_CONNECTOR_JAR_NAME> -a <APIM_DATABASE_NAME> -s <SHARED_DATABASE_NAME>```

    ###EXAMPLE
        ```sh APIM_DEPLOYER_MAC.sh -f /home/sumudu/.wum3/products/wso2am/3.2.0/full/dist/wso2am-3.2.0+<WUM_LEVEL>.full.zip -z wso2am-3.2.0+<WUM_LEVEL>.full.zip -b wso2am-3.2.0 -d full -r root -p PASSWORD -c /home/sumudu/.wum3/products/wso2am/3.2.0/full/dist/mysql-connector-java-8.0.27.jar -a TEST_APIM_DB -s TEST_SHARED_DB```

##For Linux OS users can use the below command to deploy the API Manager 3.2.0 in fully distributed way.

    ###FORMAT
        ```sh APIM_DEPLOYER_LINUX.sh -f <APIM_ZIP_PATH>/<APIM_ZIP_FILE_NAME> -z <APIM_ZIP_FILE_NAME> -b wso2am-3.2.0 -d <DEPLOYMENT_PATTERN> -r <MYSQL_ROOT_USERNAME> -p <MYSQL_ROOT_PASSWORD> -c <JDBC_CONNECTOR_JAR_LOCATION>/<JDBC_CONNECTOR_JAR_NAME> -a <APIM_DATABASE_NAME> -s <SHARED_DATABASE_NAME>```

    ###EXAMPLE
        ```sh APIM_DEPLOYER_LINUX.sh -f /home/sumudu/.wum3/products/wso2am/3.2.0/full/dist/wso2am-3.2.0+<WUM_LEVEL>.full.zip -z wso2am-3.2.0+<WUM_LEVEL>.full.zip -b wso2am-3.2.0 -d full -r root -p PASSWORD -c /home/sumudu/.wum3/products/wso2am/3.2.0/full/dist/mysql-connector-java-8.0.27.jar -a TEST_APIM_DB -s TEST_SHARED_DB```
