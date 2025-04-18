# Cron Email Sender
This container hosts a script which will send an email to an address on a schedule controled by cron. The idea of this is to have a repeated test so I know my less used email addresses (like lost@chris-pierce.com) are still working. These addresses don't regularly get mail, but it would be bad if they don't work when they are needed.

## Settings
This tool works using legacy application authentication in gmail. You must configure an "Application Password" for the sender's gmail account. Right now, an application password can be configured from [this page](https://myaccount.google.com/apppasswords).

The following environment variables then need to be set inside of the container.
 - `GMAIL_USER`: The email of the user from which emails will be sent.
 - `GMAIL_PASSWORD`: The application password for the account.
 - `EMAIL_RECIPIENT`: The address to which emails will be sent.

How often the emails will be sent is configured in the crontab configuration file `config/crontab`. It is set to weekly by default.