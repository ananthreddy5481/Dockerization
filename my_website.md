
```
docker build -t mysite .
```

```
docker run -d --name mysite1 -p 8081:80 mysite
```

```
http://localhost:8081/register.php
```

```
docker exec mysite1 mariadb -u root site -e "UPDATE users SET role='admin' WHERE username='yourname';"
```
