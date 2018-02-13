# Web UI Docker Container

## Host Setup

```
mkdir -p /data/web-ui
cd core_webui
git clone git@bitbucket.org:team-infinite-loops/web-ui.git
mv web-ui/ /data/web-ui/flakpacket
chown -R assessor:stack_docker /data/web-ui
```

## Building the image

```
docker build -t web-ui .
```

## Creating a container

```
docker create -h web-ui -v /data/web-ui/flakpacket:/opt/web/web2py/applications/flakpacket --name web-ui -p 443:443 --net=esnet web-ui
```

## Running Web2Py container with systemd

```
cp files/web2py.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable web2py
systemctl start web2py
```

