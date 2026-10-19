FROM python:3.10-slim

WORKDIR /code

# Install your app dependencies
COPY ./requirements-landmark.txt /code/requirements-landmark.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements-landmark.txt

# Bring over the model directory (pre-downloaded by Cloud Build)
COPY ./models /code/models

#COPY models/hand_landmarker.task ./models/
#COPY models/handspell_xgboost_v1.json ./models/
#COPY models/handspell_xgboost_v1_metadata.json ./models/

# Bring over your API execution script logic
COPY local_landmark_api.py .

# Boot the web application server
CMD ["sh", "-c", "uvicorn landmark_api:app --host 0.0.0.0 --port ${PORT:-8080}"]
