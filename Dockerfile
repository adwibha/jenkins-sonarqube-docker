# Use an official Python runtime as a base image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Install Python venv and other necessary dependencies
RUN apt-get update && apt-get install -y python3-venv

# Copy the current directory contents into the container at /app (including requirements.txt)
COPY . /app

# Create a virtual environment
RUN python3 -m venv venv

# Install the dependencies inside the virtual environment
RUN ./venv/bin/pip install --no-cache-dir -r requirements.txt

# Expose port 80 to be accessible outside the container
EXPOSE 80

# Run the application inside the virtual environment
CMD ["./venv/bin/python", "app.py"]
