#!/bin/sh
set -eu

# Radarr has no environment-driven first account (unlike Sonarr, whose
# AuthOptions exposes InitialUsername/InitialPassword). At startup it reads the
# first user from <Username>/<Password> in /config/config.xml and hashes the
# password itself -- see UserService.Handle(ApplicationStartedEvent). So the file
# must exist before the app first boots, otherwise the UI comes up protected by
# Forms auth with nobody able to log in.
#
# Write it only once: after that Radarr owns the file and appends its own state.

CONF_DIR="/config"
CONF="${CONF_DIR}/config.xml"

mkdir -p "${CONF_DIR}"

if [ ! -f "${CONF}" ]; then
  echo "radarr: seeding initial config.xml with forms auth"
  cat > "${CONF}" <<EOF
<Config>
  <BindAddress>*</BindAddress>
  <Port>7878</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <ApiKey></ApiKey>
  <AuthenticationMethod>Forms</AuthenticationMethod>
  <AuthenticationRequired>Enabled</AuthenticationRequired>
  <Branch>master</Branch>
  <LogLevel>info</LogLevel>
  <SslCertHash></SslCertHash>
  <UrlBase></UrlBase>
  <UpdateMechanism>External</UpdateMechanism>
  <UpdateAutomatically>False</UpdateAutomatically>
  <Username>${RADARR_ADMIN_USERNAME}</Username>
  <Password>${RADARR_ADMIN_PASSWORD}</Password>
</Config>
EOF
  chmod 0644 "${CONF}"
else
  echo "radarr: config.xml already present, leaving it untouched"
fi

exec /init
