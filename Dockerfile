FROM debian:stable-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# Install build dependencies
RUN apt-get update -y
RUN apt-get install -y \
  python3 \
  python3-pip

RUN apt-get install -y wget


# Install PostgreSQL
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get -y install postgresql
RUN apt install python3.11-venv -y


WORKDIR /app
COPY requirements.txt .
RUN python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip
RUN /bin/bash -c "source venv/bin/activate && pip install -r requirements.txt"
COPY . .

# start postgresql
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER admin WITH SUPERUSER PASSWORD 'password';" &&\
    createdb mydb

# EXPOSE port 8000
EXPOSE 8000

# hop into virtual environment
CMD ["/bin/bash", "-c", "source venv/bin/activate", "&&", "uvicorn", "main:app", "--reload"]