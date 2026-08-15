FROM minio/minio:latest
# Render injects PORT; bind object API there so the free web service health-proxies correctly.
CMD ["sh", "-c", "exec minio server /data --address :${PORT:-10000} --console-address :$(( ${PORT:-10000} + 1 ))"]
EXPOSE 10000
