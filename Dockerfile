FROM composer:latest

RUN apk add --update --no-cache jq git
RUN composer global require laravel/pint --no-progress

COPY entrypoint.sh /entrypoint.sh

USER 1000

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "--test -v" ]
