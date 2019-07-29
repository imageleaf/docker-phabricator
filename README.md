# docker-phabricator

A docker composition for Phabricator:

- One container used by mysql, see [database](https://github.com/imageleaf/docker-phabricator/tree/master/database)
- One container used by apache (phabricator)

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
