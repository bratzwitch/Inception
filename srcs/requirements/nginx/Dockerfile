FROM alpine:3.20

RUN apk update && apk upgrade && apk add --no-cache nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

