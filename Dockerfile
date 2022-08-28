FROM composer:latest

RUN composer global require laravel/pint --no-progress

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "--test -v" ]
