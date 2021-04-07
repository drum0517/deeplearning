FROM ubuntu:18.04

RUN sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list 

#install miscellaneous
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  sudo \
  apt-utils \
  xz-utils \
  build-essential \
  curl \
  less \
  wget \
  cmake \
  python \
  python-lxml \
  python3-pip \
  seccomp \
  vim \
  ssh \
  software-properties-common \
  net-tools \
  iproute2 \
  iputils-ping \
  gdb \
  gdbserver \
  libjansson-dev \
  doxygen \
  graphviz \
  libpcap-dev \
  libsnmp-dev \
  cmake-curses-gui \
  cmake-gui \
  tftp-hpa  \
  locales \
  ca-certificates \
  pkg-config \
  libglib2.0-dev \
  libglibmm-2.4-dev \
  tree \
  libgtest-dev

RUN python3 -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org --upgrade pip
RUN python3 -m pip install virtualenv scipy matplotlib jupyter tensorflow lxml jinja2 treelib setuptools pyinstaller --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org

#install clang 6.0 
RUN wget --no-check-certificate -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
RUN apt-get install -y clang-6.0 lldb-6.0 lld-6.0

#setup user to match host user name and user id
#set superuser permissions for new user
ARG USER_NAME
ARG USER_ID
ARG GROUP_NAME
ARG GROUP_ID
ARG HOST
ARG DDS_LD_LIBRARY_PATH
ARG DBUS_SESSION_BUS_ADDRESS

RUN if [ "$HOST" = "Linux" ] ; \
        then groupadd -f --system --gid ${GROUP_ID} ${GROUP_NAME} ; \
    fi
RUN if [ "$HOST" = "Linux" ] ; \
        then useradd --system \
        --uid ${USER_ID} \
        --gid ${GROUP_ID} \
        --shell /bin/bash \
        --create-home ${USER_NAME} ; \
    fi
RUN if [ "$HOST" = "Windows" ] ; \
        then useradd --system -U --shell /bin/bash --create-home ${USER_NAME} ; \
    fi
RUN if [ "$S32G_TOOLCHAIN_DIR" != "" ] ;then \
        mkdir -p ${S32G_TOOLCHAIN_DIR} && \
        chown  -R ${USER_NAME}:${GROUP_NAME} ${S32G_TOOLCHAIN_DIR}; \
    fi
RUN usermod --append --groups sudo ${USER_NAME}
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#create mount points and set owner
RUN mkdir /deeplearning
RUN chown -R ${USER_NAME}:${GROUP_NAME} /deeplearning

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER ${USER_NAME}
CMD [ "/bin/bash" ]
