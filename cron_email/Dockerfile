FROM mambaorg/micromamba:latest

# Set working directory
WORKDIR /app

# Copy environment.yml file
COPY environment.yml /app/environment.yml

# Create conda environment
RUN micromamba install -y -n base -f environment.yml && \
    micromamba clean --all --yes

# Install cron
USER root
RUN apt-get update && apt-get install -y cron

# Copy files
COPY src/send_email.py /app/
COPY config/crontab /etc/cron.d/email-cron

# Give execution rights to the cron job and script
RUN chmod 0644 /etc/cron.d/email-cron && \
    chmod +x /app/send_email.py

# Apply cron job
RUN crontab /etc/cron.d/email-cron

# Create a log file to output emails sent
RUN touch /var/log/cron.log

# Set the shell for the crontab to use conda environment
RUN echo "SHELL=/bin/bash" >> /etc/cron.d/email-cron && \
    echo "PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/cron.d/email-cron

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log