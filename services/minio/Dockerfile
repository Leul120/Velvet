FROM minio/minio:latest
# Render private services expect a single listening port; 10000 matches render.yaml.
CMD ["server", "/data", "--address", ":10000", "--console-address", ":10001"]
EXPOSE 10000
