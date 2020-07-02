## File: Dockerfile for AcetoScan
## Last modified: mån  8 jun 2020 17:04:54 CEST
## Version: 1.0
## Sign: Abhi

FROM abhijeetsingh1704/amplibase

#
LABEL version="1.0" description="acetoscan" maintainer="Abhijeet Singh <abhijeetsingh.aau@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p "/acetoscan/" {bin,db}

WORKDIR /acetoscan/bin/

COPY ./bin/* /acetoscan/bin/
COPY ./scripts/* /acetoscan/bin/
COPY ./db/* /acetoscan/db/

ENV PATH="/acetoscan/bin:${PATH}"

ENTRYPOINT ["acetocheck"]
ENTRYPOINT ["acetotax"]
ENTRYPOINT ["acetotree"]
ENTRYPOINT ["acetoscan"]

CMD ["bash", "/acetoscan/bin/"]

VOLUME "/acetoscan/input_dir"
