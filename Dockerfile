FROM rocker/shiny:4.0.5

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libmkl-rt libxml2 libodbc1 libglpk-dev

RUN Rscript -e 'install.packages("shiny")'
RUN Rscript -e 'install.packages("igraph")'
RUN Rscript -e 'install.packages("sigmaNet")'
RUN Rscript -e 'install.packages("magrittr")'
RUN Rscript -e 'install.packages("RColorBrewer")'
RUN Rscript -e 'install.packages("data.table")'


RUN apt-get update && apt-get -y install git vim
RUN rm -r /srv/shiny-server

COPY ./shiny-app/* /srv/shiny-server/
CMD ["/usr/bin/shiny-server"]
