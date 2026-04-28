# `Chiskat/Acme.sh-Deploy-Docker`

[![](https://img.shields.io/docker/v/chiskat/acme.sh-deploy-docker?sort=semver)](https://hub.docker.com/r/chiskat/acme.sh-deploy-docker) ![](https://img.shields.io/docker/image-size/chiskat/acme.sh-deploy-docker)

[`Chiskat/Acme.sh-Deploy-Docker`](https://hub.docker.com/r/chiskat/acme.sh-deploy-docker) 是基于 [acme.sh](https://acme.sh) 的官方镜像 [`neilpang/acme.sh`](https://hub.docker.com/r/neilpang/acme.sh) 的集成 Docker CLI 版本。

如果你的 Acme.sh 和 Nginx 都使用 Docker 部署，那么 Acme.sh 每次安装新的证书后，想要通过 `--reloadcmd` 通知 Nginx 运行 `nginx -s reload` 会很困难，因为容器之间是隔离的；本镜像内置 Docker CLI，你只需把宿主机的 `/var/run/docker.sock` 原样挂载进来，便可直接在镜像中运行 `docker` 命令。

## 配置示例

适用于 `docker-compose.yml` 的示例：

```yml
services:
  acme-sh:
    image: chiskat/acme.sh-deploy-docker
    container_name: acme-sh
    restart: unless-stopped
    volumes:
      # ↓ 必须添加这一行
      - /var/run/docker.sock:/var/run/docker.sock
      # ...
    environment:
      - TZ=Asia/Shanghai
      - AUTO_UPGRADE=1
      # ...
    command: daemon
```

这样便支持通过 `--reloadcmd` 来让 nginx 容器重载配置了。

在宿主机上给 Acme.sh 下达自动安装证书命令：

```bash
docker exec acme-sh acme.sh --install-cert -d example.com \
  --key-file /path/to/key.pem \
  --fullchain-file /path/to/fullchain.pem \
  --reloadcmd "docker exec nginx nginx -s reload"
```

此后 Acme.sh 便可通过 `docker exec` 命令操控 Nginx 容器，在每次安装证书后让 Nginx 重载。

## 关于版本号

此镜像通过 GitHub 定时任务定期构建，每次构建均会同步最新的 `acme.sh` 版本。

每次构建都会推送两个 TAG：

- 构建日期，例如 `2026.4.1`
- 版本号拼接，例如 `acme_3.1.2`，这样可以精确确定预装的各个依赖项的版本。

一般来说，如无特殊需要，直接使用 `latest` 最新版本号标签即可。

## 自行构建

如果你对第三方的镜像不放心，也可以自己构建，以下是方法：

1. 打开 [GitHub 仓库](https://github.com/chiskat/acme.sh-deploy-docker) 克隆此项目，或者，只下载此项目中的 [`Dockerfile`](https://github.com/chiskat/acme.sh-deploy-docker/blob/main/Dockerfile) 文件
2. 运行 `docker build -t 镜像名 .`，这里的镜像名你可以自己随便取，构建时会自动使用最新版本的 `acme.sh`