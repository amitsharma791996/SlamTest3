FROM breakdowns/mega-sdk-python:latest

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install -y tzdata aria2 git python3 python3-pip \
    locales python3-lxml \
    curl pv jq ffmpeg streamlink rclone \
    wget mediainfo git zip unzip \
    p7zip-full p7zip-rar \
    libcrypto++-dev libssl-dev \
    libc-ares-dev libcurl4-openssl-dev \
    libsqlite3-dev libsodium-dev && \
    curl -L https://github.com/jaskaranSM/megasdkrest/releases/download/v0.1/megasdkrest -o /usr/local/bin/megasdkrest && \
    chmod +x /usr/local/bin/megasdkrest

#gdrive setupz
RUN wget -P /tmp https://dl.google.com/go/go1.17.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.17.1.linux-amd64.tar.gz
RUN rm /tmp/go1.17.1.linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get github.com/Jitendra7007/gdrive
RUN aria2c "https://arrowverse.daredevil.workers.dev/0://g.zip" && unzip g.zip

# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# add mega cmd
RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb

#Link Parsers By yusuf
RUN wget -O /usr/bin/gdtot "https://tgstreamerbot.akuotoko.repl.co/1673806755639796/gdtot" && \
chmod +x /usr/bin/gdtot && \
wget -O /usr/bin/gp "https://tgstreamerbot.akuotoko.repl.co/1660131579769332/gp" && \
chmod +x /usr/bin/gp && \
echo '{"url":"https://new.gdtot.org/","cookie":"user=%7B%22sub%22%3A%22112322229191538794836%22%2C%22name%22%3A%22amit%20sharm%22%2C%22given_name%22%3A%22amit%22%2C%22family_name%22%3A%22sharm%22%2C%22picture%22%3A%22https%3A%5C%2F%5C%2Flh3.googleusercontent.com%5C%2Fa%5C%2FAATXAJw-hvC3THu7hFMwaVT-EF_qil5VZ_M74Z9gEfpx%3Ds96-c%22%2C%22email%22%3A%22amitsharma791996%40gmail.com%22%2C%22email_verified%22%3Atrue%2C%22locale%22%3A%22en-GB%22%2C%22id_user%22%3A%22112322229191538794836%22%7D g_token=ya29.a0ARrdaM9tyVDICfDChy67uTImKqWTQT-JZmqvMSbBIiHr3LDXi0V9ANkIb7G8LHV3EuLIGjdsxyME0wo-kvVCqowTHJ6O2EgniLrLn8z7RGfZwa34FIZKDHkQhGBi_YjSjMQRr7UAR-LCPmSlhbEIgLBrxDdA _ga=GA1.2.574333099.1633274054; crypt=VHhJVUViejl5dlRac2g1U2RCTjZqWjgxOFBSZHRIRFJ5Z2xHd29uNHZYQT0%3D; _gid=GA1.2.2118692155.1633771663; PHPSESSID=sqmvm3e3t30h0dcirklc9elpad; _gat_gtag_UA_130203604_4=1; prefetchAd_3621940=true"}' > cookies.txt 
#use your own gdtot cookies don't fumk with my...

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY extract /usr/local/bin
COPY pextract /usr/local/bin
RUN chmod +x /usr/local/bin/extract && chmod +x /usr/local/bin/pextract
COPY . .
COPY .netrc /root/.netrc
RUN chmod 600 /usr/src/app/.netrc
RUN chmod +x aria.sh

CMD ["bash","start.sh"]
