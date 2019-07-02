FROM iotkitdemo/aws-cli

ENTRYPOINT ["sh"]
CMD ["setup.sh"]

COPY ./docker-compose.yaml .
COPY ./resources/ ./
COPY ./setup.sh .