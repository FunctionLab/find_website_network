FROM rocker/shiny:3.5.3
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
RUN apt-get update
RUN apt-get -y install git
RUN rm -r /srv/shiny-server
RUN git clone https://github.com/FunctionLab/find_website_network.git  /srv/shiny-server
