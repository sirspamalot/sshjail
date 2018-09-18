#!/bin/bash
SFTPONLY_GROUP="sftponly"
SFTP_BASE_FOLDER="/srv/sftp"

USERID="$1"

# Check parameters
if [ "$1" = "" ]
then
  echo "Usage: $0 <new username>" 1>&2
  exit 1
fi

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Make sure the group exists
/bin/egrep  -i "^${SFTPONLY_GROUP}" /etc/group
if [ $? -eq 0 ]; then
        echo "Nice, group $SFTPONLY_GROUP already exists in /etc/group"
else
        echo "Group $SFTPONLY_GROUP does not exist, creating..."
        groupadd $SFTPONLY_GROUP
fi

# Make sure the user does not exist
/bin/egrep  -i "^${USERID}" /etc/passwd
if [ $? -eq 0 ]; then
        echo "User $USERID exists in /etc/passwd, aborting..."
        exit 1
else
        echo "Good, $USERID is a new user."

        if [ -d "$SFTP_BASE_FOLDER/$USERID" ]; then
                echo "Folder $SFTP_BASE_FOLDER/$USERID already exists, aborting..."
                exit 1
        else
                echo "Adding user..."
                adduser $USERID

                echo "Creating folder $SFTP_BASE_FOLDER/$USERID..."
                mkdir $SFTP_BASE_FOLDER/$USERID

                echo "Setting home directory of the new user..."
                usermod -d / $USERID

                echo "Assigning $USERID to $SFTPONLY_GROUP..."
                usermod -G $SFTPONLY_GROUP $USERID

                echo "Setting necessary permissions for chroot folder..."
                chmod -R 755 $SFTP_BASE_FOLDER/$USERID

                echo "Done."
        fi
fi
