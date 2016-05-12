# An complete base Docker image for running JupyterHub https://github.com/jupyterhub/jupyterhub
#
# This Docker image uses sudospawner to create individual jupyter server for every user.
#

FROM debian:jessie
MAINTAINER emuio.com <info@emuio.com> http://emuio.com

# install nodejs, utf8 locale
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install sudo npm nodejs nodejs-legacy wget locales git &&\
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    locale-gen C.UTF-8 && \
    apt-get remove -y locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8

# install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.0.5-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo 'a7bcd0425d8b6688753946b59681572f63c2241aed77bf0ec6de4c5edc5ceeac */tmp/miniconda.sh' | shasum -a 256 -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.5 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# install js dependencies
RUN npm install -g configurable-http-proxy && rm -rf ~/.npm

RUN groupadd jupyterhub
RUN useradd -m -d /home/jacob -G jupyterhub jacob

RUN pip install git+https://github.com/jupyter/sudospawner

ADD ./sudoers /etc/

RUN pip install git+https://github.com/jupyter/sudospawner
RUN pip install git+https://github.com/jupyterhub/jupyterhub

RUN ln -s /opt/conda/bin/sudospawner /usr/local/bin/sudospawner
RUN ln -s /opt/conda/bin/jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser

RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000

ADD jupyterhub_config.py /srv/jupyterhub/

LABEL org.jupyter.service="jupyterhub"

CMD ["jupyterhub"]
