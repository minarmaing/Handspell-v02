FROM python:3.10-slim

WORKDIR /code

# Install system utilities and Google Cloud CLI
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://google.com cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://google.com | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# --- THE MAGIC STEP ---
# Build argument to dynamically inject your bucket name
ARG BUCKET_NAME
ENV BUCKET_NAME=$BUCKET_NAME
# Download the entire models folder from GCS straight into the container image
RUN gsutil -m cp -r gs://${BUCKET_NAME}/models /code/models

COPY ./landmark_api.py /code/landmark_api.py

CMD ["sh", "-c", "uvicorn landmark_api:app --host 0.0.0.0 --port ${PORT:-8080}"]
