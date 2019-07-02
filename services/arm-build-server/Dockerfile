FROM iotkitdemo/aws-cli

ENTRYPOINT ["sh"]
CMD ["setup.sh"]

COPY --from=dockertemplate/interpolator:v0.1.2 /interpolator /interpolator

COPY ./remote/* ./
COPY ./assets/* /assets/
COPY ./setup.sh .