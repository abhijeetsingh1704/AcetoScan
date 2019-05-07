## AcetoScan
## Last modified: tis maj 07, 2019  04:53
## Version: 0.1
## Johan.Nylander\@nbis.se

FROM phusion/baseimage:0.11

LABEL version="1.0" description="AcetoScan" maintainer="Abhijeet Singh <abhijeet.singh@slu.se>"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /AcetoScan

ENV PATH="/AcetoScan/SCRIPTS:${PATH}"

CMD ["/sbin/my_init"]

# Set up and use apt-get for installation
RUN \
    apt clean \
    && sed -i -e 's|http://archive|http://se.archive|g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        cutadapt \
        diamond-aligner \
        emboss \
        git \
        libv8-dev \
        ncbi-blast+ \
        r-base \
        r-base-dev \
        r-bioc-phyloseq \
        r-cran-dplyr \
        r-cran-ggplot2 \
        r-cran-plotly \
        r-cran-plyr \
        r-cran-rcolorbrewer \
        tree \
        wget

# Install additional software
# Install acetoscan from github (from www for now while testing)
# Note: the internal folder structure of AcetoScan is not checked/set at the moment.
# Need to make sure the user have access to db, and that output folders are
# created at the correct locations.
RUN \
    Rscript -e "install.packages('randomcoloR', dependencies=TRUE, repos='https://ftp.acc.umu.se/mirror/CRAN/')" \
    && wget "https://github.com/torognes/vsearch/releases/download/v2.13.1/vsearch-2.13.1-linux-x86_64.tar.gz" \
    && tar xzf vsearch-2.13.1-linux-x86_64.tar.gz \
    && cp vsearch-2.13.1-linux-x86_64/bin/vsearch /usr/local/bin/vsearch \
    && rm -rf vsearch-2.13.1-linux-x86_64/ vsearch-2.13.1-linux-x86_64.tar.gz \
    && wget https://www.abc.se/~nylander/pub/AcetoScan.tgz \
    && tar xzf AcetoScan.tgz \
    && rm AcetoScan.tgz \
    && cp AcetoScan/acetoscan /usr/local/bin/acetoscan \
    && chmod +x /usr/local/bin/acetoscan \

RUN \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /tmp/Rtmp* 

