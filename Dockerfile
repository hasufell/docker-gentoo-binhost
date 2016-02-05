FROM       mosaiksoftware/gentoo-nginx:latest
MAINTAINER Julian Ospald <hasufell@posteo.de>

##### PACKAGE INSTALLATION #####

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && \
	cave update-world -s tools && \
	cave update-world -s server && \
	cave resolve -c world -x -f && \
	cave resolve -c world -x && \
	cave fix-linkage -x && \
	rm -rf /usr/portage/distfiles/* /srv/binhost/*

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5


################################

RUN rm /etc/paludis/package_mask.conf.d/binhost.conf \
	/etc/paludis/package_unmask.conf.d/binhost.conf

COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default.conf

COPY ./config/bashrc.addition /root/bashrc.addition
RUN cat /root/bashrc.addition >> /root/.bashrc

COPY ./config/90cave.env.d /etc/env.d/90cave
RUN mkdir -p /etc/paludis/tmp
RUN env-update

RUN mkdir -p /var/log/nginx/log
