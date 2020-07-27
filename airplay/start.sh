#!/usr/bin/env bash

#Check for incompatible multi room and client-only setting
if [[ -n $DISABLE_MULTI_ROOM ]] && [[ $CLIENT_ONLY_MULTI_ROOM == "1" ]]; then
  echo “DISABLE_MULTI_ROOM and CLIENT_ONLY_MULTI_ROOM cannot be set simultaneously. Ignoring client-only mode.”
fi

#Exit service if client-only mode is enabled
if [[ -z $DISABLE_MULTI_ROOM ]] && [[ $CLIENT_ONLY_MULTI_ROOM == "1" ]]; then
  exit 0
fi


# Set the device broadcast name for AirPlay
if [[ -z "$DEVICE_NAME" ]]; then
  DEVICE_NAME=$(printf "balenaSound Airplay %s" $(hostname | cut -c -4))
fi

# Use pipe output if multi room is enabled
# Don't pipe for Pi 1/2 family devices since snapcast-server is disabled by default
if [[ -z $DISABLE_MULTI_ROOM ]] && [[ $BALENA_DEVICE_TYPE != "raspberry-pi" || $BALENA_DEVICE_TYPE != "raspberry-pi2" ]]; then
  SHAIRPORT_BACKEND="-o pipe -- /var/cache/snapcast/snapfifo"
fi

# import configuration from CURL if needed
if [[ ! -z "$CURL_URL" ]]; then
  curl $CURL_URL > /etc/shairport-sync.conf
fi

#Pause this script execution if needed for troubleshooting
while [ $PAUSE ]; do sleep 1; done

rm -rf /var/run/dbus.pid #removed as it appeared to be causing issues on the docker...

dbus-uuidgen --ensure
dbus-daemon --system

avahi-daemon --daemonize --no-chroot

# Start AirPlay
#exec shairport-sync -a "$DEVICE_NAME" $SHAIRPORT_BACKEND | printf "Device is discoverable as \"%s\"\n" "$DEVICE_NAME"
printf "Device is discoverable as \"%s\"\n" "$DEVICE_NAME"
su-exec shairport-sync shairport-sync $SHAIRPORT_OPTIONS -a "$DEVICE_NAME" $SHAIRPORT_BACKEND 