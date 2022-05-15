# APIM_DEPLOYER
This script will help to deploy the API Manager with MySQL databases within few seconds


Thank you for using the APIM Deployer script to deploy the API Manager 4.0.0 in Fully Distributed deployment (TM separated or not)

##For MAC OS users can use the below command to deploy the API Manager 4.0.0 in fully distributed way.

    ###FORMAT
        ```sh APIM_DEPLOYER_MAC.sh -f <APIM_ZIP_PATH>/<APIM_ZIP_FILE_NAME> -z <APIM_ZIP_FILE_NAME> -b wso2am-4.0.0 -d <DEPLOYMENT_PATTERN> -r <MYSQL_ROOT_USERNAME> -p <MYSQL_ROOT_PASSWORD> -c <JDBC_CONNECTOR_JAR_LOCATION>/<JDBC_CONNECTOR_JAR_NAME> -a <APIM_DATABASE_NAME> -s <SHARED_DATABASE_NAME>  -u <UPDATE_LEVEL_TO_INSTALL>```

    ###EXAMPLE
        ```sh APIM_DEPLOYER_MAC.sh -f /home/sumudu/.wum3/products/wso2am/4.0.0/wso2am-4.0.0.zip -z wso2am-4.0.0.zip -b wso2am-4.0.0 -d FULL -r root -p PASSWORD -c /home/sumudu/.wum3/products/wso2am/mysql-connector-java-8.0.27.jar -a TEST_APIM_DB -s TEST_SHARED_DB -u 91```

##For Linux OS users can use the below command to deploy the API Manager 3.2.0 in fully distributed way.

    ###FORMAT
        ```sh APIM_DEPLOYER_LINUX.sh -f <APIM_ZIP_PATH>/<APIM_ZIP_FILE_NAME> -z <APIM_ZIP_FILE_NAME> -b wso2am-4.0.0 -d <DEPLOYMENT_PATTERN> -r <MYSQL_ROOT_USERNAME> -p <MYSQL_ROOT_PASSWORD> -c <JDBC_CONNECTOR_JAR_LOCATION>/<JDBC_CONNECTOR_JAR_NAME> -a <APIM_DATABASE_NAME> -s <SHARED_DATABASE_NAME>  -u <UPDATE_LEVEL_TO_INSTALL>```

    ###EXAMPLE
        ```sh APIM_DEPLOYER_LINUX.sh -f /home/sumudu/.wum3/products/wso2am/4.0.0/wso2am-4.0.0.zip -z wso2am-4.0.0.zip -b wso2am-4.0.0 -d FULL -r root -p PASSWORD -c /home/sumudu/.wum3/products/wso2am/mysql-connector-java-8.0.27.jar -a TEST_APIM_DB -s TEST_SHARED_DB -u 91```

