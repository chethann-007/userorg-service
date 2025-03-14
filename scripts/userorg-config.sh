#!/bin/bash

# Authorization & Authentication
export sunbird_authorization=""                   # Authorization token for Sunbird APIs
export sunbird_sso_url=""                        # SSO URL with Keycloak auth endpoint
export sunbird_sso_realm="sunbird"               # Keycloak realm
export sunbird_sso_username=""                   # SSO username
export sunbird_sso_password=""                   # SSO password
export sunbird_sso_client_id="lms"               # SSO client ID
export sunbird_sso_client_secret=""              # SSO client secret
export sunbird_sso_publickey=""                  # SSO public key
export sunbird_keycloak_user_federation_provider_id="" # Keycloak federation provider ID
export sunbird_sso_lb_ip="http://keycloak.lern.svc.cluster.local:8080"  # SSO load balancer IP

# Database Configuration
export sunbird_cassandra_host="http://cassandra.lern.svc.cluster.local"  # Cassandra host
export sunbird_cassandra_port="9042"             # Cassandra port
export sunbird_cassandra_consistency_level="local_quorum"  # Cassandra consistency level

# Elasticsearch Configuration
export sunbird_es_host="http://elasticsearch.lern.svc.cluster.local"  # Elasticsearch host
export sunbird_es_port="9300"                    # Elasticsearch port

# Email Configuration
export sunbird_mail_server_from_email=""         # From email address
export sunbird_mail_server_host=""               # SMTP server host
export sunbird_mail_server_password=""           # SMTP server password
export sunbird_mail_server_port=""               # SMTP server port
export sunbird_mail_server_username=""           # SMTP server username
export sunbird_support_email="support@sunbird.org"    # Support email

# SMS Configuration
export sunbird_msg_91_auth=""                    # MSG91 authentication key
export sunbird_msg_sender=""                     # SMS sender ID

# API Base URLs
export sunbird_analytics_api_base_url="http://analytics-service.obsrv.svc.cluster.local:9000"
export sunbird_api_base_url="http://knowledge-mw-service.knowlg.svc.cluster.local:5000"
export sunbird_content_service_api_base_url="http://content-service.knowlg.svc.cluster.local:9000"
export form_api_endpoint="/plugin/v1/form/read"

# System Configuration
export ENV_NAME="dev"                            # Environment name
export PORTAL_SERVICE_PORT="http://player.ed.svc.cluster.local:3000"
export SUNBIRD_KAFKA_URL="http://kafka.lern.svc.cluster.local:9092"
export sunbird_app_name="sunbird"               # Application name
export sunbird_installation="sunbird"           # Installation name
export sunbird_instance="sunbird"               # Instance name
export sunbird_environment="dev"                # Environment name
export sunbird_default_channel="sunbird"        # Default channel

# Security & Encryption
export google_captcha_private_key=""            # Google Captcha private key
export google_captcha_mobile_private_key=""     # Google Captcha mobile private key
export sunbird_encryption_key="encryptionkey"   # Encryption key
export sunbird_encryption_mode="local"          # Encryption mode

# Feature Configuration
export sunbird_cache_enable="true"              # Enable/disable cache
export sunbird_gzip_enable="true"               # Enable/disable GZIP compression
export sunbird_health_check_enable="false"      # Enable/disable health check
export sunbird_url_shortner_enable="false"      # Enable/disable URL shortener
export sunbird_url_shortner_access_token=""     # URL shortener access token

# OTP Configuration
export sunbird_otp_allowed_attempt="2"          # Maximum OTP attempts allowed
export sunbird_otp_expiration="1800"            # OTP expiration time (in seconds)
export sunbird_otp_length="6"                   # OTP length
export sunbird_keycloak_required_action_link_expiration_seconds="2592000"  # Keycloak action link expiration


# Performance Configuration
export sunbird_gzip_size_threshold="262144"     # GZIP size threshold
export sunbird_fuzzy_search_threshold="0.5"     # Fuzzy search threshold
export sunbird_user_bulk_upload_size="1001"     # User bulk upload size limit

# Notification Configuration
export sunbird_reset_pass_msg='You have requested to reset password. Click on the link to set a password: {0}'

# Display Configuration
export sunbird_env_logo_url=""                  # Environment logo URL
export sunbird_installation_display_name="sunbirddev"
export sunbird_installation_display_name_for_sms="sunbird"
export sunbird_user_profile_field_default_visibility="private"

# Telemetry Configuration
export telemetry_pdata_id="learner"            # Telemetry producer data ID
export telemetry_pdata_pid="learner-service"    # Telemetry producer data PID
export telemetry_queue_threshold_value="100"    # Telemetry queue threshold
export user_index_alias="user_alias"            # User index alias

# Time Configuration
export sunbird_time_zone="Asia/Kolkata"         # Application timezone

# Quartz Configuration
export sunbird_quartz_mode="cluster"            # Quartz scheduler mode

# Feed Configuration
export feed_limit="30"                          # Feed limit for user activities