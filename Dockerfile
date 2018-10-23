FROM quay.io/prometheus/busybox:latest
LABEL maintainer="kobtea9696@gmail.com"

COPY example/simple.yml /etc/dummy_exporter.yml
COPY dist/linux_amd64/dummy_exporter /bin/dummy_exporter

EXPOSE 9510
ENTRYPOINT ["/bin/dummy_exporter"]
CMD ["--config=/etc/dummy_exporter.yml"]
