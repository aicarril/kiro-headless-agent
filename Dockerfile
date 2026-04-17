FROM python:3.12-slim

# Install dependencies
RUN apt-get update && apt-get install -y git unzip curl && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Kiro CLI
RUN curl -fsSL https://cli.kiro.dev/install -o /tmp/install-kiro.sh && \
    echo "y" | bash /tmp/install-kiro.sh && \
    rm /tmp/install-kiro.sh

# Copy agent workspace
COPY workspace/ /workspace/

WORKDIR /workspace

ENTRYPOINT ["/root/.local/bin/kiro-cli"]
