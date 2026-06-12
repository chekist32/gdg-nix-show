FROM alpine:3.24.0
RUN apk add --no-cache busybox htop

CMD [ "sh" ]
