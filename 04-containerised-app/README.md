# Containerised Web App

A small Python web application packaged as a Docker image and pushed to a private
ECR registry. This is the application that runs on Fargate in
[`05-ecs-fargate`](../05-ecs-fargate).

## The application

`app.py` is about twenty lines using only Python's standard library. It listens on
port 8080 and replies with the hostname of the machine answering:

```
Hello from 3f9a2b1c4d5e
```

**The hostname is the point.** When several containers run behind a load balancer,
refreshing the page returns a different name each time, which makes load balancing
visible rather than theoretical.

No web framework, so the image needs no dependencies installed and stays small.

## The Dockerfile

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
```

**`FROM python:3.12-slim`** — start from an official image that already has Python
3.12. `slim` is the stripped-down variant, which keeps the result around 180MB
instead of roughly a gigabyte for the full image.

**`WORKDIR /app`** — a single folder for the application, kept separate from the
operating system's own directories.

**`COPY app.py .`** — the application enters the image here.

**`EXPOSE 8080`** — documentation. It records which port the application uses; it
does not open anything by itself.

**`CMD ["python", "app.py"]`** — what runs when a container starts. Everything above
builds the package; this line is the only one that executes at run time.

## Building and running

```bash
docker build -t my-app .
docker run -d -p 8080:8080 my-app
```

Then `http://localhost:8080`.

`-p 8080:8080` maps a port on the host to a port inside the container. The
left-hand number is the host, the right-hand number is the container — a container
is otherwise sealed off and unreachable.

```bash
docker ps          # list running containers
docker logs <id>   # see the application's output
docker stop <id>   # stop it
```

## Pushing to ECR

The image is stored in a private Elastic Container Registry so ECS can pull it.

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin 039324592089.dkr.ecr.us-east-1.amazonaws.com

docker tag my-app:latest 039324592089.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
docker push 039324592089.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
```

**Tagging does not copy anything.** It adds a second name to an image that already
exists, which is why `my-app` and the full ECR address share an image ID. The
registry address has to be part of the name because that is how Docker knows where
to push it.

The login command pipes a temporary password straight into `docker login` rather
than putting it on the command line, so it never appears in shell history.

## Notes

- **The `latest` tag** means "whatever was pushed most recently", so it can change
  without warning. Versioned tags would be better for anything real.
- **Image size is about 180MB**, nearly all of it the Python base image. A
  multi-stage build would reduce it, but there is nothing to strip out here.
- **Storage cost in ECR** is roughly 2p per month for this image.
