## AcetoScan
## Last modified: tis maj 07, 2019  11:01
## Version: 0.1
## Johan.Nylander\@nbis.se

FROM phusion/baseimage:0.11

LABEL version="1.0" description="AcetoScan" maintainer="Abhijeet Singh <abhijeet.singh@slu.se>"

ENV DEBIAN_FRONTEND=noninteractive

CMD ["/sbin/my_init"]

RUN \
    apt-get clean && \
    sed -i -e 's|http://archive|http://se.archive|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        tree \
        r-base \
        r-base-dev \
        r-cran-ggplot2 \
        r-bioc-phyloseq \
        r-cran-plotly \
        r-cran-rcolorbrewer \
        r-cran-plyr \
        r-cran-dplyr

# Install vsearch binary from github
RUN \
    wget "https://github.com/torognes/vsearch/releases/download/v2.13.1/vsearch-2.13.1-linux-x86_64.tar.gz" && \
    tar xzf vsearch-2.13.1-linux-x86_64.tar.gz && \
    cp vsearch-2.13.1-linux-x86_64/bin/vsearch /usr/local/bin/vsearch && \
    rm -rf vsearch-2.13.1-linux-x86_64/bin/vsearch vsearch-2.13.1-linux-x86_64.tar.gz

# Install acetoscan from github (from https for now/testing)
#RUN \
#    wget https://www.abc.se/~nylander/pub/acetoscan.tgz
#    wget -O /usr/local/bin/acetoscan "https://www.abc.se/~nylander/pub/AcetoScan-JN" && \
#    chmod +x /usr/local/bin/acetoscan

#    wget "https://www.abc.se/~nylander/pub/AcetoScan.tgz" && \
#    tar xzf AcetoScan.tgz
#

ENV PATH="/AcetoScan/SCRIPTS:${PATH}"



RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

