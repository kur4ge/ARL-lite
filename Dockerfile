FROM python:3.9-slim AS massdns
WORKDIR /massdns
RUN apt-get update && apt-get install git gcc make -y && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/blechschmidt/massdns --depth=1 .
RUN make

FROM golang:1.24-alpine AS nuclei
RUN apk add build-base git
WORKDIR /nuclei
RUN git clone https://github.com/projectdiscovery/nuclei --depth=1 .&& make verify && make build


FROM python:3.9-slim
WORKDIR /tmp
RUN apt-get update && apt-get install gcc python3-dev -y && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /tmp/ARL-NPoC
COPY extra/ARL-NPoC .
RUN pip install -r requirements.txt && pip install . && rm -rf /tmp/*

RUN apt-get update && apt-get install ncrack nmap -y && rm -rf /var/lib/apt/lists/*


WORKDIR /tmp/phantomjs
RUN apt-get update \
    && apt-get install -y \
        curl libfontconfig bzip2 \
    && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
            | tar -xj --strip-components=1 -C /tmp/phantomjs \
    && mv bin/phantomjs /usr/local/bin \
    && cd \
    && apt-get purge --auto-remove -y \
        curl bzip2 \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/*

WORKDIR /arl
COPY app/ app/

# 注意根据环境修改
COPY extra/wih/wih_linux_amd64 /usr/bin/wih
COPY --from=massdns /massdns/bin/massdns app/tools
COPY --from=nuclei /nuclei/bin/nuclei /usr/bin/

RUN nuclei -ut && ln -s /usr/local/bin/phantomjs app/tools/phantomjs
