#!/usr/bin/env python3
import smtplib
import os
import datetime
import logging
import jinja2
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Set up logging
logger = logging.getLogger('email_cron')

# Get environment variables
gmail_user = os.environ.get('GMAIL_USER')
gmail_password = os.environ.get('GMAIL_PASSWORD')  # App password, not regular password
recipient = os.environ.get('EMAIL_RECIPIENT')

# Set up Jinja2 environment
template_loader = jinja2.FileSystemLoader(searchpath="/app/templates")
template_env = jinja2.Environment(loader=template_loader)

def send_email():
    # Current time for email subject
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create message container
    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = recipient
    msg['Subject'] = f"Email Test of \"{recipient}\" - {current_time}"
    
    # Load and render the email template
    template = template_env.get_template("email_template.html")
    body = template.render(
        current_time=current_time,
        recipient=recipient
    )
    
    # Attach the body to the email
    msg.attach(MIMEText(body, 'plain'))
    
    # Establish connection to Gmail's SMTP server
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()  # Upgrade the connection to encrypted SSL/TLS
    server.login(gmail_user, gmail_password)
    
    # Send the email
    server.send_message(msg)
    server.quit()
    
    logger.info(f"Email successfully sent at {current_time}")


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler()]
    )

    if not all([gmail_user, gmail_password, recipient]):
        logger.error("Required environment variables are not set.")
        logger.error("Please ensure GMAIL_USER, GMAIL_PASSWORD, and EMAIL_RECIPIENT are set.")
    else:
        send_email()
