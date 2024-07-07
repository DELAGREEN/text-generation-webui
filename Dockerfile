FROM ubuntu:20.04 as builder

USER root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Установка зависимостей
RUN apt-get -qq -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
        gcc \
        g++ \
        zlibc \
        zlib1g-dev \
        libssl-dev \
        libbz2-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libgdbm-dev \
        libgdbm-compat-dev \
        liblzma-dev \
        libreadline-dev \
        uuid-dev \
        libffi-dev \
        tk-dev \
        wget \
        curl \
        git \
        make \
        sudo \
        bash-completion \
        expect \
        tree \
        vim \
        nano \
        git-lfs \
        software-properties-common && \
    mv /usr/bin/lsb_release /usr/bin/lsb_release.bak && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Инициализация git-lfs
RUN git lfs install

# Создание пользователя docker с правами sudo
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    cp /root/.bashrc /home/docker/ && \
    mkdir -p /home/docker/data && \
    chown -R docker:docker /home/docker

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /home/docker/data
ENV HOME /home/docker
ENV USER docker
USER docker
ENV PATH /home/docker/.local/bin:$PATH
RUN touch $HOME/.sudo_as_admin_successful

# Клонирование репозитория
RUN git clone https://github.com/DELAGREEN/text-generation-webui.git /home/docker/data/text-generation-webui

# Переключение в директорию репозитория и загрузка больших файлов
WORKDIR /home/docker/data/text-generation-webui
RUN git lfs pull

# Копирование необходимых файлов
COPY /models /home/docker/data/text-generation-webui/models
COPY start.sh /home/docker/data/text-generation-webui/

USER root
RUN chmod +x /home/docker/data/text-generation-webui/start.sh
RUN chmod -R +w /home/docker/data/text-generation-webui

USER docker

# Выполнение скрипта
RUN /home/docker/data/text-generation-webui/start.sh


EXPOSE 7860
CMD [ "/bin/bash" ]
