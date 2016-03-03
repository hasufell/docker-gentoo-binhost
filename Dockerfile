FROM       mosaiksoftware/gentoo-nginx:latest
MAINTAINER Julian Ospald <hasufell@posteo.de>


# this image is for developing pbins and shall not be optimized for size
# so remove the corresponding hook
RUN rm /etc/paludis/hooks/ebuild_preinst_pre/cleanup_files.bash


##### PACKAGE INSTALLATION #####

# update world with our USE flags
# we need to rebuild everything in order to revert the base image
# directory removal, especially /usr/include
RUN chgrp paludisbuild /dev/tty && \
	git -C /usr/portage checkout -- . && \
	mkdir /usr/portage/distfiles && \
	env-update && \
	source /etc/profile && \
	cave sync && \
	cave update-world -s tools && \
	cave update-world -s server && \
	cave resolve -e world -x -f --permit-old-version '*/*' && \
	cave resolve -e world -x --permit-old-version '*/*' && \
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

# allow local sync again
RUN sed -i -e 's|^#sync|sync|' /etc/paludis/repositories/*.conf

