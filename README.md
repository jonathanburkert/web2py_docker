# Web UI Docker Container

## Host Setup

```
mkdir -p /data/cerebro
cd web2py_docker
```

## Set up application

- Move web2py application code to `/data/web-ui/`

## Building the image

```
docker build -t web-ui .
```

## Creating a container

```
docker create -h web-ui -v /data/web-ui/<application>:/opt/web/web2py/applications/<application> --name web-ui -p 443:443 --net=esnet web-ui
```

## Running Web2Py container with systemd

```
cp files/web2py.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable web2py
systemctl start web2py
```

