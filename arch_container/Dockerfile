from archlinux:latest

RUN pacman -Sy && pacman -S --noconfirm base-devel distcc

# Enable distcc connections and set logging
RUN sed -i '/^DISTCC_ARGS=/d' /etc/conf.d/distccd && \
	echo 'DISTCC_ARGS="--allow-private --log-level info --log-stderr --log-file /distccd.log"' >> /etc/conf.d/distccd

# compiler port
EXPOSE 3632

# statistics port
EXPOSE 3633

CMD ["bash", "-c", \
	"source /etc/conf.d/distccd && /usr/bin/distccd --no-detach --daemon --stats $DISTCC_ARGS"]
