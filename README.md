[![wakatime](https://wakatime.com/badge/user/54ad05ce-f39b-4fa3-9f2a-6fe4b1c53ba4/project/6181686d-ca25-48bc-9367-2f161173dc67.svg?style=for-the-badge)](https://wakatime.com/badge/user/54ad05ce-f39b-4fa3-9f2a-6fe4b1c53ba4/project/6181686d-ca25-48bc-9367-2f161173dc67?style=for-the-badge)

# email_newsletter

A email newsletter service written in rust

So far this is just a demo and can be used as a template

## Run as docker image

First start a Postgres sever in Docker

```bash
./scripts/init_db.sh
```

Then build the container with the app

```bash
docker build --tag email_newsletter --file Dockerfile .
```

Then run

```bash
docker run -p 8000:8000 email_newsletter
```
