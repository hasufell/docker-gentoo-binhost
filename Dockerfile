FROM       hasufell/gentoo-nginx:latest
MAINTAINER Julian Ospald <hasufell@gentoo.org>

##### PACKAGE INSTALLATION #####

# get paludis config
RUN mv /etc/paludis /etc/paludis-orig && \
	git clone --depth=1 https://github.com/hasufell/gentoo-server-config.git \
	/etc/paludis && cp /etc/paludis-orig/sets/nginx.conf /etc/paludis/sets/ \
	&& cp /etc/paludis-orig/use.conf.d/nginx.conf /etc/paludis/use.conf.d/

# temporarily disable binhost repo
RUN mv /etc/paludis/repositories/binhost.conf \
	/etc/paludis/repositories/binhost.conf.bak

# rm etckeeper, we don't need it here
RUN rm /etc/paludis/hooks/ebuild_postinst_post/etckeeper.bash \
	/etc/paludis/hooks/ebuild_postrm_post/etckeeper.bash \
	/etc/paludis/hooks/ebuild_preinst_post/etckeeper.bash \
	/etc/paludis/hooks/ebuild_prerm_post/etckeeper.bash

# clone libressl
RUN git clone --depth=1 https://github.com/gentoo/libressl.git \
	/var/db/paludis/repositories/libressl
RUN chgrp paludisbuild /dev/tty && cave fix-cache && eix-update

# temporarily disable CC=clang
RUN sed -i -e 's/CC=/#CC=/' -e 's/CXX=/#CXX=/' /etc/paludis/bashrc
# install clang
RUN chgrp paludisbuild /dev/tty && cave resolve -z -1 clang -x
# enable clang
RUN sed -i -e 's/#CC=/CC=/' -e 's/#CXX=/CXX=/' /etc/paludis/bashrc

# install libressl
RUN chgrp paludisbuild /dev/tty && cave resolve -z -1 dev-libs/libressl \
	dev-libs/openssl::libressl -D dev-libs/openssl -x -f
RUN chgrp paludisbuild /dev/tty && cave resolve -z -1 dev-libs/libressl \
	dev-libs/openssl::libressl -D dev-libs/openssl -x
# fix linkage in case libressl broke it
RUN chgrp paludisbuild /dev/tty && cave fix-linkage -x

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && cave resolve -c -f world -x
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x

# install tools set
RUN chgrp paludisbuild /dev/tty && cave resolve -c -f tools -x
RUN chgrp paludisbuild /dev/tty && cave resolve -c tools -x

# install server set
RUN chgrp paludisbuild /dev/tty && \
	cave resolve -z -1 \!sys-fs/udev sys-fs/eudev virtual/udev -x -F sys-fs/eudev
RUN chgrp paludisbuild /dev/tty && cave resolve -c -f server -x \
	--permit-old-version 'dev-python/docker-py'
RUN chgrp paludisbuild /dev/tty && cave resolve -c server -x

RUN chgrp paludisbuild /dev/tty && cave fix-linkage -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

# restore binhost repo
RUN mv /etc/paludis/repositories/binhost.conf.bak \
	/etc/paludis/repositories/binhost.conf

################################


COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default.conf

RUN mkdir -p /srv/binhost && chgrp paludisbuild /srv/binhost
RUN mkdir -p /var/log/nginx/log
