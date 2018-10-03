#!/bin/ash

source /ethercis/env.rc

#this is where we have to modify services.properties contents 
#using sed before file location is passed as a parameter to java
#we'll use environtment variables which will be provided
#to docker run command as input

#if [ -n "${1}" ]; =>  if var is not null or empty
#if [ -z "$ENV_TEST" ]; if var is null or empty

if [ -z "$DB_HOST" -o -z "$DB_PORT" -o -z "$DB_PASS" -o -z "$DB_USER" ]; then
    echo "You must provide all of the following environment variables: DB_HOST, DB_PORT, DB_USER, DB_PASS"
    exit 1    
fi  

#replace only once. In case docker container is stopped/started, or we'd corrupt these lines by replacing > 1 times
if grep -q {init:} /etc/opt/ecis/services.properties; then
	echo "First time configuring db connection parameters: replacing placeholders with actual values"
	
	sed -i "s|{init:}server.persistence.jooq.url=|server.persistence.jooq.url=jdbc:postgresql://$DB_HOST:$DB_PORT/ethercis|g" /etc/opt/ecis/services.properties    
	sed -i "s|{init:}server.persistence.jooq.login=|server.persistence.jooq.login=$DB_USER|g" /etc/opt/ecis/services.properties    
	sed -i "s|{init:}server.persistence.jooq.password=|server.persistence.jooq.password=$DB_PASS|g" /etc/opt/ecis/services.properties    
fi	

if grep -q {log_dir} ${ECIS_ETC}/log4j.xml; then
	echo "First time configuring logging: replacing placeholders with actual values"
	sed -i "s|{log_dir}|${ECIS_VAR}/logs|g" ${ECIS_ETC}/log4j.xml
fi


export LIB_DEPLOY=${ECIS_OPT}/lib/deploy
export SYSLIB=${ECIS_OPT}/lib/system

export _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

# runtime parameters
export JVM=${JAVA_HOME}/bin/java
export RUNTIME_HOME=${ECIS_OPT}
export RUNTIME_ETC=${ECIS_ETC}
export RUNTIME_LOG=${ECIS_VAR}
export ENABLE_DEBUG_LOG="2>> ${RUNTIME_LOG}/ethercis_test.log >> ${RUNTIME_LOG}/ethercis_test.log"
export RUNTIME_DIALECT=EHRSCAPE  #specifies the query dialect used in HTTP requests (REST)
export SERVER_PORT=${ECIS_REST_PORT} # the port address to bind to
export SERVER_HOST=${ECIS_REST_HOST} # the network address to bind to

export JOOQ_DIALECT=POSTGRES
JOOQ_DB_PORT=${ECIS_PG_PORT}
JOOQ_DB_HOST=${ECIS_PG_HOST}
JOOQ_DB_SCHEMA=${ECIS_PG_SCHEMA}
export JOOQ_URL=jdbc:postgresql://${JOOQ_DB_HOST}:${JOOQ_DB_PORT}/${JOOQ_DB_SCHEMA}
export JOOQ_DB_LOGIN=${ECIS_PG_ID}
export JOOQ_DB_PASSWORD=${ECIS_PG_PWD}

export CLASSPATH=$LIB_DEPLOY/*:$SYSLIB/ecis-dependencies/*:$SYSLIB/openehr-java-lib/*

#this is the command the start script of ethercis runs once the start script is created
#by the installation script
${JVM}    -Xmx256M    -Xms256M    -server     -XX:-EliminateLocks     -XX:-UseVMInterruptibleIO   -cp ${CLASSPATH}    -Djava.util.logging.config.file=${RUNTIME_ETC}/logging.properties -Dlog4j.configurationFile=file:${RUNTIME_ETC}/log4j.xml     -Djava.net.preferIPv4Stack=true     -Djava.awt.headless=true    -Djdbc.drivers=org.postgresql.Driver         -Dserver.node.name=${ECIS_NODE_NAME}          -Dfile.encoding=UTF-8     -Djava.rmi.server.hostname=${SERVER_HOST}  -Djooq.dialect=${JOOQ_DIALECT}  -Djooq.url=${JOOQ_URL}  -Djooq.login=${JOOQ_DB_LOGIN}   -Djooq.password=${JOOQ_DB_PASSWORD}     -Druntime.etc=${RUNTIME_ETC}     com.ethercis.vehr.Launcher     -propertyFile /etc/opt/ecis/services.properties     -server_host ${ECIS_REST_HOSTNAME}     -server_port ${ECIS_REST_PORT}

exit 0