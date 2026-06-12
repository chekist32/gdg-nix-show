FROM alpine:latest
RUN apk add --no-cache busybox htop

CMD [ "sh" ]
