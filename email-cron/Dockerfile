FROM mambaorg/micromamba:latest

# Set working directory
WORKDIR /app

# Copy environment.yml file
COPY environment.yml /app/environment.yml

# Create conda environment
RUN micromamba create -f environment.yml && \
    micromamba clean --all --yes

# Install cron
USER root
RUN apt-get update && apt-get install -y cron

# Copy files
COPY src/send_email.py /app/
COPY src/run_email.sh /app/
COPY src/templates/ /app/templates/
COPY config/crontab /etc/cron.d/email-cron

# Give execution rights to scripts and cron
RUN chmod 0644 /etc/cron.d/email-cron && \
    chmod +x /app/send_email.py && \
    chmod +x /app/run_email.sh

# Apply cron job
RUN crontab /etc/cron.d/email-cron

# Create a log file to output emails sent
RUN touch /var/log/cron.log

# Set the shell for the crontab
RUN echo "SHELL=/bin/bash" >> /etc/cron.d/email-cron && \
    echo "PATH=/opt/conda/envs/email_env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/cron.d/email-cron

# Run the command on container startup
CMD printenv | grep -v "no_proxy" > /etc/environment && cron && tail -f /var/log/cron.log
