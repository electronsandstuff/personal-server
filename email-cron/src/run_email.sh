#!/bin/bash

# Log start time
echo "Starting email script at $(date)" >> /var/log/cron.log

# Run the Python script with environment variables
/opt/conda/envs/email_env/bin/python /app/send_email.py >> /var/log/cron.log 2>&1

# Log completion
echo "Email script completed at $(date)" >> /var/log/cron.log