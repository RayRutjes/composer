#!/bin/bash

set -u

# Create the group if it does not exist
id -g $GROUP_ID > /dev/null 2>&1;
if [ $? = 1 ]; then
  echo "Create group with id: $GROUP_ID"
  groupadd --gid $GROUP_ID composer
fi

# Create the user if it does not exist
id -u $USER_ID > /dev/null 2>&1;
if [ $? = 1 ]; then
  echo "Create user with id: $USER_ID"
  useradd --gid $GROUP_ID --home "$COMPOSER_HOME" --uid $USER_ID --create-home --shell /bin/bash composer
fi

# if [ -w $COMPOSER_HOME ]; then
#   echo "Composer home is writeable by $USER_ID:$GROUP_ID"
# fi

# chown -R "$USER_ID:$GROUP_ID" .
# chown -R "$USER_ID:$GROUP_ID" $COMPOSER_HOME

exec gosu "$USER_ID:$GROUP_ID" composer "$@"
