# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory in the container to /app
WORKDIR /app

# Copy only the requirements.txt file into the container at /app
COPY . /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Run docker-info.py when the container launches
CMD ["python3", "proxy.py"]
