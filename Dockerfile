FROM python:3.10-slim

WORKDIR /code

# Install system utilities and the Google Cloud SDK inside the build environment
RUN apt-get update && apt-get install -y curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://google.com cloud-sdk main" | tee -a /etc/apt/sources.list.dev /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://google.com | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

COPY requirements-landmark.txt .

RUN pip install --no-cache-dir -r requirements-landmark.txt

COPY local_landmark_api.py .

COPY models/hand_landmarker.task ./models/
COPY models/handspell_xgboost_v1.json ./models/
COPY models/handspell_xgboost_v1_metadata.json ./models/

# --- THE MAGIC STEP ---
# Build arguments pass your bucket details safely without baking hardcoded text into git
ARG BUCKET_NAME
RUN gsutil cp gs://${BUCKET_NAME}/team_asl_landmark_model.h5 /code/team_asl_landmark_model.h5

COPY ./app /code/app

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
