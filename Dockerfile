FROM centos:6
MAINTAINER Marijn Giesen <marijn@studio-donder.nl>

# Install repositories, update system and install software
RUN yum -y install --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
    http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
    sed -i -e '/\[remi\]/,/^\[/s/enabled=0/enabled=1/' /etc/yum.repos.d/remi.repo; \
    yum -y update --setopt=tsflags=nodocs; \
    yum -y --setopt=tsflags=nodocs install nginx python-pip; \
    rm -rf /var/cache/yum/*; \
    yum clean all

# Configure software
RUN pip install pip --upgrade && pip install setuptools --upgrade && pip install supervisor; \
    rm -rf /tmp/*; \
    echo "NETWORKING=yes" > /etc/sysconfig/network; \
    mkdir -p /etc/service-config

COPY etc/service-config /etc/service-config
COPY bootstrap/start_container /usr/bin/start_container

RUN ln -sf /etc/service-config/supervisor/supervisord.conf /etc/supervisord.conf && \
    ln -sf /etc/service-config/nginx/nginx.conf /etc/nginx/nginx.conf && \
    ln -sf /etc/service-config/nginx/fastcgi_params_php /etc/nginx/fastcgi_params_php; \
    ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime; \
    chmod 700 /usr/bin/start_container

EXPOSE 80

CMD ["/usr/bin/start_container", "web"]
