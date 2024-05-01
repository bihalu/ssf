FROM debian:bookworm-slim

# expose server port and node port
EXPOSE 8011 32000

# set workdir to /app
WORKDIR /app

# environment variables
ENV MODE client
ARG HOST
ENV HOST $HOST
ENV PORT 8011
ARG FORWARD_HOST
ENV FORWARD_HOST $FORWARD_HOST
ENV FORWARD_SERVICE 32000

# create folder for certs and symbolic links
RUN mkdir -p /app/certs/trusted && \
    ln -s /certs/ca.crt /app/certs/trusted/ca.crt && \
    ln -s /certs/dh4096.pem /app/certs/dh4096.pem && \
    ln -s /certs/certificate.crt /app/certs/certificate.crt && \
    ln -s /certs/private.key /app/certs/private.key

# copy all needed files into container image
COPY upx-ssf upx-ssfd start.sh /app/

# command
CMD ["/app/start.sh"]