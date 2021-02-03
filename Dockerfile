FROM tsl0922/musl-cross
RUN git clone --depth=1 https://github.com/tsl0922/ttyd.git /ttyd \
    && cd /ttyd && env BUILD_TARGET=$BUILD_TARGET WITH_SSL=$WITH_SSL ./scripts/cross-build.sh

FROM ubuntu:18.04
COPY --from=0 /ttyd/build/ttyd /usr/bin/ttyd

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /sbin/tini
RUN chmod +x /sbin/tini

FROM python:3.8.5-slim-buster

RUN apt-get update; apt-get install -y --no-install-recommends python3 python3-setuptools python3-pip zip unzip p7zip-full \
    wget nano detox tmux curl htop net-tools \
    neofetch python3-dev git bash build-essential nodejs npm ruby \
    python-minimal locales python-lxml gettext-base xz-utils \
    pip3 install gdown && pip3 install speedtest-cli && apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
    
RUN wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xvf ffmpeg*.xz && \
    cd ffmpeg-*-static && \
    mv "${PWD}/ffmpeg" "${PWD}/ffprobe" /usr/local/bin/

ENV LANG C.UTF-8

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive

# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

# rclone
RUN curl https://rclone.org/install.sh | bash
RUN pip3 install -r requirements.txt
ADD ./mc /app/mc
RUN chmod +x /app/mc && mv /app/mc /usr/local/bin/
ENV LOGIN_USER admin
ENV LOGIN_PASSWORD admin

#EXPOSE 7681

ENTRYPOINT ["/sbin/tini", "--"]
#CMD ["ttyd", "bash"]
CMD ttyd --port $PORT --credential $LOGIN_USER:$LOGIN_PASSWORD bash
