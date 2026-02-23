#!/bin/bash

# if bluetoothctl show | grep -q "Powered: yes"; then
# Broke on 13/02/2026.
# A bashism alternative is
# if bluetoothctl <<< 'show' | grep -q "Powered: yes"; then

if printf 'show' | bluetoothctl | grep -q "Powered: yes"; then
    # Disconnect all devices
    for device in $(printf 'devices' | bluetoothctl | awk '/^Device/ {print $2}'); do
        bluetoothctl disconnect "$device"
    done
    # Turn off Bluetooth
    bluetoothctl power off && rfkill block bluetooth
else
    # Turn on Bluetooth
    rfkill unblock bluetooth && bluetoothctl power on && bluetoothctl scan on
fi
