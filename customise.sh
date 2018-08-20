apk add --update python python-dev py-pip 

pip install pgxnclient

apk add postgresql-contrib

apk add postgresql-dev=10.4-r0

apk add ca-certificates

apk add build-base

pgxn install temporal_tables

apk add git

apk add bison

apk add flex

echo 'now creating user root'
su - postgres -c 'psql -c "CREATE USER root WITH SUPERUSER;"'
echo 'created user root'

git clone https://github.com/postgrespro/jsquery.git
cd jsquery
make USE_PGXS=1
make USE_PGXS=1 install

cd ..


#fetch db creation script for ethercis and run it
git clone https://github.com/ethercis/ehrservice || { echo "Could not clone ethercis/ehrservice repository, exiting..." && exit 1; }

cd ehrservice/db # stay in this dir, we'll run graddle in a while

su - postgres -c "psql < /ehrservice/db/createdb.sql"

#now create db schemas etc using graddle && flyway

#need java for graddle
apk add openjdk8
#install graddle
wget https://services.gradle.org/distributions/gradle-4.3-bin.zip
mkdir -p /opt/gradle
unzip -d /opt/gradle gradle-4.3-bin.zip
export PATH=$PATH:/opt/gradle/gradle-4.3/bin
#run flyway via graddle
gradle flywayMigrate

cd / # go to root before clean up

#clean directories used for installation
rm -f -r /ehrservice
rm -f -r /jsquery
rm -f -r /opt/gradle
rm -f -r /usr/lib/jvm/java-1.8-openjdk
rm -f -r /usr/lib/jvm/default-jvm


su - postgres -c "pg_ctl  -D $PGDATA -m fast -w stop"



