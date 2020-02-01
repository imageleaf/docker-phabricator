# phabricator

A docker composition for Phabricator:

- One container used by apache [phabricator](https://github.com/imageleaf/phabricator)
- One container used by mysql, see [phabricator-mysql](https://github.com/imageleaf/phabricator-mysql)

## Run with image from hub.docker.com

Run mysql:
```
docker run --name phabricator-database imageleaf/phabricator-mysql
```

Run phabricator:
```
docker run -p 8081:80 --link phabricator-database:database imageleaf/phabricator
```

Go to `http://localhost:8081`

## Run using docker-compose

```
docker-compose up -d
```

Go to `http://localhost:8081`

## Credit

Based on the great work by Yvonnick Esnault: [yesnault/docker-phabricator](https://github.com/yesnault/docker-phabricator)
