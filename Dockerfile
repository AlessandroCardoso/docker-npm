FROM node:6.0.0

MAINTAINER i9corp <support@i9corp.com.br>

WORKDIR /local-npm
ADD . /local-npm/

RUN apt-get update
RUN apt-get install -y vim sudo openssh-server samba dos2unix
RUN apt-get autoremove
RUN apt-get clean

ENV VOL_DIR=/etc/i9corp
ENV SMB_DIR=${VOL_DIR}/samba

RUN mkdir -p ${SMB_DIR}

RUN groupadd -r local-npm --gid=999 \
    && useradd -r -g local-npm --uid=999 local-npm

RUN npm set progress=false && npm install --no-color && npm dedupe

RUN useradd -m i9corp && echo "i9corp:q1w2e3" | chpasswd \
    && chown -R i9corp:i9corp /etc/i9corp \
    && echo "i9corp:q1w2e3" | sudo chpasswd \
    && (echo "q1w2e3"; echo "q1w2e3") | smbpasswd -s -a i9corp \
    && echo "i9corp ALL=(ALL:ALL) ALL" >> /etc/sudoers

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages \
    && chmod +x /usr/local/bin/start-packages

RUN cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp
COPY  ./samba/smb.conf /etc/samba/smb.conf
RUN dos2unix /etc/samba/smb.conf

VOLUME /data

#NPM
EXPOSE 5080
EXPOSE 16984
#SSH
EXPOSE 22
#Proftpd
EXPOSE 21
#Samba
EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139
EXPOSE 445

CMD /usr/local/bin/start-packages
