#!/usr/bin/env python3
import smtplib
import os
import datetime
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger('email_cron')

# Get environment variables
GMAIL_USER = os.environ.get('GMAIL_USER')
GMAIL_PASSWORD = os.environ.get('GMAIL_PASSWORD')  # App password, not regular password
RECIPIENT = os.environ.get('EMAIL_RECIPIENT')

def send_email():
    # Current time for email subject
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create message container
    msg = MIMEMultipart()
    msg['From'] = GMAIL_USER
    msg['To'] = RECIPIENT
    msg['Subject'] = f"Hourly Email Test - {current_time}"
    
    # Email content
    body = f"""This is an automated email sent from your Docker container at {current_time}.
If you're receiving this, your email test system is working correctly!

Docker Email Cron Service
"""
    
    # Attach the body to the email
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        # Establish connection to Gmail's SMTP server
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()  # Upgrade the connection to encrypted SSL/TLS
        server.login(GMAIL_USER, GMAIL_PASSWORD)
        
        # Send the email
        server.send_message(msg)
        server.quit()
        
        logger.info(f"Email successfully sent at {current_time}")
        
    except Exception as e:
        logger.error(f"Error sending email: {e}")

if __name__ == "__main__":
    if not all([GMAIL_USER, GMAIL_PASSWORD, RECIPIENT]):
        logger.error("Required environment variables are not set.")
        logger.error("Please ensure GMAIL_USER, GMAIL_PASSWORD, and EMAIL_RECIPIENT are set.")
    else:
        send_email()