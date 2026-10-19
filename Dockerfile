FROM python:3.10-slim

WORKDIR /code

# Install your app dependencies
COPY ./requirements-landmark.txt /code/requirements-landmark.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements-landmark.txt

# Bring over the model directory (pre-downloaded by Cloud Build)
COPY ./models /code/models

# Bring over your API execution script logic
COPY ./landmark_api.py /code/landmark_api.py

# Boot the web application server
CMD ["sh", "-c", "uvicorn landmark_api:app --host 0.0.0.0 --port ${PORT:-8080}"]
