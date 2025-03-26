FROM docker.io/library/ubuntu:jammy

COPY certificates/zscaler_certificate.pem /usr/local/share/ca-certificates/zscaler_certificate.crt
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y ca-certificates
RUN apt-get autoremove
RUN apt-get clean
RUN update-ca-certificates
ENV R_VERSION="devel"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC"

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh
RUN /rocker_scripts/install_R_source.sh

ENV CRAN="https://cloud.r-project.org"
ENV LANG=en_US.UTF-8

COPY scripts/bin/ /rocker_scripts/bin/
COPY scripts/setup_R.sh /rocker_scripts/setup_R.sh
RUN /rocker_scripts/setup_R.sh

ENV S6_VERSION="v2.1.0.2"
ENV SHINY_SERVER_VERSION="latest"
ENV PANDOC_VERSION="default"

COPY scripts/install_shiny_server.sh /rocker_scripts/install_shiny_server.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
RUN /rocker_scripts/install_shiny_server.sh

WORKDIR /opt/shiny-server
ENV NODE_EXTRA_CA_CERTS="/usr/local/share/ca-certificates/zscaler_certificate.crt"
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
RUN bin/npm install -g npm@latest
RUN apt-get install -y git
RUN bin/npm update path_to_regexp
RUN bin/npm audit fix

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
RUN apt-get autoremove -y && apt-get clean

EXPOSE 3838
CMD ["/init"]

COPY scripts /rocker_scripts
