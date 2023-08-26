FROM fedora:38

ARG FNR_VLC_UID="1000"
ARG FNR_VLC_GID="1000"

ENV USER="vlc"
ENV HOME="/home/vlc"

# Set necessary labels for the Red Hat Universal Base Image
LABEL name="fenar-vlc-streamer" \
      version="1.0" \
      description="A container for streaming using VLC based on FEDORA:38 by Fatih E. NAR"

# Install VLC, wget, curl, and iputils
RUN dnf install -y wget curl iputils procps sudo iproute && \
    dnf clean all

RUN dnf install -y alsa-plugins-pulseaudio && \
    dnf clean all

RUN groupadd -g "${FNR_VLC_GID}" vlc && \
    useradd -m -d /data -s /bin/sh -u "${FNR_VLC_UID}" -g "${FNR_VLC_GID}" "${USER}" && \
    echo "vlc:vlc" | chpasswd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    usermod -aG wheel "${USER}" && \
    dnf upgrade -y && \
    rpm -ivh "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-38.noarch.rpm" && \
    dnf upgrade -y && \
    dnf install -y vlc ffmpeg && \
    dnf clean all

USER ${USER}
WORKDIR "home/${USER}"

# Copy the sample.mp4 from origin host to the container
RUN wget http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4
RUN chown -R $USER:$USER $HOME/

# Set the command to run VLC for HTTP streaming: This is for Docker Desktop Easy Test
# CMD ["vlc", "TearsOfSteel.mp4", "--sout", "#standard{access=http,mux=ts,dst=:8080}", "-I", "dummy"]
