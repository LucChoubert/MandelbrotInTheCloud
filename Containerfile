# Use the official image as a parent image.
FROM python:3-slim AS base

# We copy just the requirements.txt first to leverage Docker cache
COPY ./backend/requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip3 install -r requirements.txt

COPY ./backend/ /app
COPY ./frontend/ /app/static/

EXPOSE 5000

# Development Stage
FROM base AS DEV

CMD [ "python", "-m", "flask", "--app", "MandelbrotBackend", "--debug", "run", "--host=0.0.0.0" ]


# Production Stage
FROM base AS PRD

RUN pip install --no-cache-dir gunicorn

CMD [ "python", "-m", "flask", "--app", "MandelbrotBackend", "run", "--host=0.0.0.0" ]