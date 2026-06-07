FROM alpine:latest
RUN apk add --no-cache bash busybox htop

CMD [ "sh" ]
