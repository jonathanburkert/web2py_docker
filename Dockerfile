FROM centos:latest
RUN mv /etc/localtime /etc/localtime.bak
RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Set vars
ENV WEB2PY_APP=flakpacket
ENV WEB2PY_PATH=/opt/web
ENV WEB2PY_PASS=password
ENV USERNAME=assessor
ENV GROUP=stack_docker
ENV FQDN=stack-host

# Add user/group
RUN groupadd $GROUP -g 1010
RUN useradd -ms /bin/bash $USERNAME -u 1001 -g $GROUP

# Install packages
RUN yum -y install epel-release
RUN yum -y install python-devel python-pip gcc nginx wget unzip python-psycopg2 MySQL-python openssl uwsgi-plugin-python git

# Create directory
RUN mkdir $WEB2PY_PATH

# Create certs
WORKDIR $WEB2PY_PATH
RUN openssl req -x509 -new -newkey rsa:4096 -days 3652 -nodes -keyout web2py.key -out web2py.crt -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=$FQDN"

# Get web2py
RUN curl http://web2py.com/examples/static/web2py_src.zip -o web2py_src.zip
RUN unzip web2py_src.zip && rm -rf web2py_src.zip
RUN mv $WEB2PY_PATH/web2py/handlers/wsgihandler.py $WEB2PY_PATH/web2py
RUN echo "routers = dict(BASE=dict(default_application=\"$WEB2PY_APP\"))" >> $WEB2PY_PATH/web2py/routes.py

# Get uwsgi
RUN pip install uwsgi
RUN mkdir -p /etc/uwsgi/sites
RUN mkdir -p /var/log/uwsgi
RUN mkdir -p /etc/nginx/ssl/

# Configuring uwsgi
COPY files/web2py.ini /etc/uwsgi/sites/web2py.ini
RUN sed -i "s@WEB2PY_PATH_PLACEHOLDER@$WEB2PY_PATH@" /etc/uwsgi/sites/web2py.ini
RUN sed -i "s@USERNAME_PLACEHOLDER@$USERNAME@" /etc/uwsgi/sites/web2py.ini

# Configuring nginx
COPY files/nginx.conf /etc/nginx/nginx.conf
RUN sed -i "s@YOUR_SERVER_DOMAIN_PLACEHOLDER@$FQDN@" /etc/nginx/nginx.conf
RUN mv $WEB2PY_PATH/web2py.crt /etc/nginx/ssl
RUN mv $WEB2PY_PATH/web2py.key /etc/nginx/ssl

# Setting up
WORKDIR /opt/web/web2py
RUN python -c "from gluon.main import save_password; save_password('$WEB2PY_PASS',443)"
RUN chmod 700 /etc/nginx/ssl
RUN usermod -aG $GROUP nginx

COPY files/entrypoint.sh $WEB2PY_PATH
RUN sed -i "s@USERNAME_PLACEHOLDER@$USERNAME@" $WEB2PY_PATH/entrypoint.sh
RUN chmod 700 $WEB2PY_PATH/entrypoint.sh
RUN chown -R $USERNAME:$GROUP $WEB2PY_PATH

ENTRYPOINT $WEB2PY_PATH/entrypoint.sh
