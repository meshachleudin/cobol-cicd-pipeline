FROM ubuntu:24.04

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends gnucobol4 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/INTCALC.cbl ./src/INTCALC.cbl
COPY tests/sample_accounts.txt ./ACCTIN

RUN cobc -x -o intcalc src/INTCALC.cbl

RUN mkdir -p /output

ENTRYPOINT ["/bin/bash", "-c", "./intcalc && cp ACCTRPT /output/ACCTRPT && cat ACCTRPT"]