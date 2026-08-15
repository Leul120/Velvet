FROM minio/minio:latest
# Official image ENTRYPOINT is `minio`, so CMD alone cannot run a shell.
# Override entrypoint to bind object API to Render's PORT.
ENTRYPOINT ["/bin/sh", "-c", "exec minio server /data --address :${PORT:-10000} --console-address :$(( ${PORT:-10000} + 1 ))"]
