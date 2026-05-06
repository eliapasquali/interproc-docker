# Interproc Docker

## About
Interprocedural static analyzer for an academic imperative language with numerical variables and procedure calls.

## Usage

### Via docker compose

To run interproc using docker compose
```bash
git clone https://github.com/Edivad99/interproc-docker.git
cd interproc-docker
docker compose up -d
```

### Via docker
```bash
git clone https://github.com/Edivad99/interproc-docker.git
cd interproc-docker
docker build -t interproc_image .
docker create -p 8080:80 --name interproc interproc_image
# Start the server
docker start interproc
# Stop the server
docker stop interproc
# Delete the container
docker rm -f interproc
```

Once done, you can connect to Interproc by typing on your browser `localhost:8080` or by clicking [here](http://localhost:8080).
