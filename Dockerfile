FROM       hasufell/gentoo-nginx:latest
MAINTAINER Julian Ospald <hasufell@gentoo.org>

##### PACKAGE INSTALLATION #####

# copy paludis config
COPY ./config/paludis /etc/paludis

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x

# install tools set
RUN chgrp paludisbuild /dev/tty && cave resolve -c tools -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

################################


COPY ./config/sites-enabled /etc/nginx/sites-enabled
RUN rm /etc/nginx/sites-enabled/default.conf

RUN mkdir -p /srv/binhost && chgroup paludisbuild /srv/binhost
RUN mkdir -p /var/log/nginx/log
