FROM rocker/shiny
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
        apt-get -y install default-jre-headless && \
            apt-get clean && \
                rm -rf /var/lib/apt/lists/*
RUN R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r  \
    --deps TRUE \
    sigmaNet \
    magrittr \
    RColorBrewer \
    data.table \
    igraph \
    shiny \
    && rm -rf /tmp/downloaded_packages/

