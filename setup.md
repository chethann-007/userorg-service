# Setup Guide for User Org Service

## Prerequisites

### Software Dependencies
1. Java Development Kit (JDK) 11
2. Apache Maven 3.9.8

### Databases
1. Apache Cassandra

2. Elasticsearch

3. Redis

## Environment Configuration

### Core Configuration
```shell
# Authentication & SSO
sunbird_sso_url=                 # Keycloak server URL
sunbird_sso_realm=               # Keycloak realm name
sunbird_sso_username=            # Keycloak username
sunbird_sso_password=            # Keycloak password
sunbird_sso_client_id=           # Keycloak client ID
sunbird_sso_client_secret=       # Keycloak client secret (optional)
sunbird_sso_publickey=           # SSO public key

# Actor Service Configuration
sunbird_learnerstate_actor_host= # Actor service host (e.g., actor-service)
sunbird_learnerstate_actor_port= # Remote actors port
sunbird_learner_service_url=     # UserOrg service URL

# Badge Configuration
sunbird_valid_badge_subtypes=    # Valid badge subtypes (comma-separated)
sunbird_valid_badge_roles=       # Valid badge roles (comma-separated)
```

### Local Mode Configuration
Required when running actor in local mode:

```shell
# Database Configuration
sunbird_cassandra_host=          # Cassandra server host
sunbird_cassandra_port=          # Cassandra server port
sunbird_cassandra_username=      # Cassandra username (optional)
sunbird_cassandra_password=      # Cassandra password (optional)

# Elasticsearch Configuration
sunbird_es_host=                 # Elasticsearch server host
sunbird_es_port=                 # Elasticsearch server port
sunbird_es_cluster=              # Elasticsearch cluster name (optional)

# PostgreSQL Configuration
sunbird_pg_host=                 # PostgreSQL host
sunbird_pg_port=                 # PostgreSQL port
sunbird_pg_db=                   # PostgreSQL database name
sunbird_pg_user=                 # PostgreSQL username
sunbird_pg_password=             # PostgreSQL password

# Actor Configuration
sunbird_learner_actor_host=      # UserOrg actor host
sunbird_learner_actor_port=      # UserOrg actor port

# Content & API Configuration
ekstep_content_search_base_url=  # EkStep content search base URL
ekstep_authorization=            # Content search authorization
sunbird_content_service_api_base_url= # Content service API base URL
sunbird_api_base_url=           # Content service URL

# Mail Configuration
sunbird_mail_server_host=
sunbird_mail_server_port=
sunbird_mail_server_username=
sunbird_mail_server_password=
sunbird_mail_server_from_email=

# Storage Configuration
sunbird_account_name=            # Azure blob storage account name
sunbird_account_key=            # Azure blob storage account key

# Security Configuration
sunbird_encryption_key=
sunbird_encryption_mode=         # Mode: local or remote

# UI Configuration
sunbird_env_logo_url=           # Logo URL for emails
sunbird_web_url=                # Web page URL
sunbird_app_url=                # Play store URL

# Notification Configuration
sunbird_fcm_account_key=        # FCM account key
sunbird_msg_91_auth=            # MSG91 auth key
sunbird_msg_sender=             # Message sender name

# System Configuration
sunbird_installation=
sunbird_installation_email=      # Admin installation email
sunbird_quartz_mode=            # "embedded" for no DB, other values for PostgreSQL
sunbird_lms_base_url=           # LMS service base URL
sunbird_lms_authorization=       # API gateway auth key

# Actor System Configuration
sunbird_mw_system_host=actor-service
sunbird_mw_system_port=
background_actor_provider=remote
api_actor_provider=off
sunbird_remote_req_router_path=
sunbird_remote_bg_req_router_path=

# Badging Configuration
badging_authorization_key=
sunbird_badger_baseurl=http://badger-service:8000

# Telemetry Configuration
telemetry_pdata_id={{env}}.sunbird.learning.service
telemetry_pdata_pid=actor-service
telemetry_pdata_ver=1.5
```

### Remote Background Actor Configuration
Required when running background actor in remote mode:

```shell
sunbird_background_actor_host=   # Background actor host
sunbird_background_actor_port=   # Background actor port
```

### Actor System Type Configuration
To specify the type of actor system to start on a machine:

```shell
# Values: "RemoteMiddlewareActorSystem" or "BackGroundRemoteMiddlewareActorSystem"
actor_service_name=             # Actor system type to start
```

## Build Instructions

1. Pull the latest sunbird-common submodule:
```shell
git submodule foreach git pull origin master
```

2. Build the services:
```shell
mvn clean install -DCLOUD_STORE_GROUP_ID=org.sunbird -DCLOUD_STORE_ARTIFACT_ID=cloud-store-sdk -DCLOUD_STORE_VERSION=1.4.6
```

3. Generate the controller distribution:
```shell
cd controller
mvn play2:dist
```
The build file ` userorg-service-1.0-SNAPSHOT-dist.zip` will be generated in `userorg-service/controller/target`.

## Running the Service

1. Unzip the distribution file:
```shell
unzip userorg-service-1.0-SNAPSHOT-dist.zip
```

2. Start the service:
```shell
java -cp 'userorg-service-1.0-SNAPSHOT/lib/*' play.core.server.ProdServerStart userorg-service-1.0-SNAPSHOT