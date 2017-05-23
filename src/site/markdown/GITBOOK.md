
# 如何构建oss的gitbook

    ./book.sh build
    
    # 预览 http://127.0.0.1:4000
    ./book.sh serve
    
  查看更多命令请执行
    
    ./book.sh help

## 如何使用gitbook

https://github.com/GitbookIO/gitbook
http://toolchain.gitbook.com/pages.html

    # 准备gitbook目录
    cd ~/ws/architecture
    mkdir -p oss/src/gitbook
    cd oss/src/gitbook

    # 写此文档时的环境
    node --version
    v6.2.2
    npm --version
    3.9.5

    npm install gitbook-cli@2.3.0 -g
    gitbook init
    # 生成README.md 和 SUMMARY.md
    
    # Preview and serve your book using:
    gitbook serve
    # Or build the static website using:
    gitbook build
    # Debugging
    gitbook build ./ --log=debug --debug

## 生成PDF等其他格式的电子书

需要安装 `ebook-convert`, 可以到 `https://calibre-ebook.com/` 下载

  Mac用户可以执行 `brew install Caskroom/cask/calibre` 安装, 但前提是你已经安装了 `Homebrew`


## 如何发布oss的gitbook到github pages

1. 在travis为项目home1-oss配置github的token，

    GITHUB_GIT_SERVICE_TOKEN=XXXXX

2. 新建项目,用来维护gitbook的静态页

           https://github.com/home1-oss/home1-oss-gitbook
           git clone git@github.com:home1-oss/home1-oss-gitbook.git
           cd home1-oss-gitbook
           git branch gh-pages
           git push origin gh-pages

3. 在.travis.yml增加如下配置


        env:
         global:
          - OSS_GITBOOK_GITHUB_PAGES_OWNER=home1-oss
          - OSS_GITBOOK_GITHUB_PAGES_REPO=home1-oss-gitbook

        before_deploy:
        - bash ci.sh before_deploy

        deploy:
         provider: pages
         skip_cleanup: true
         github_token: $GITHUB_GIT_SERVICE_TOKEN # Set in travis-ci.org dashboard
         local_dir: $OSS_GITBOOK_GITHUB_PAGES_REPO
         repo: $OSS_GITBOOK_GITHUB_PAGES_OWNER/$OSS_GITBOOK_GITHUB_PAGES_REPO
         on:
           branch:
           - develop
           - master

3. 使用mvn gitflow插件辅助发布，操作如下


        cd XXXXXX/home1-oss
        git checkout develop
        mvn gitflow:release-start
        # check version and push to remote optionally..
        # git push origin release/1.0.6.OSS
        mvn gitflow:release-finish
        git push origin develop # 发布snapshot
        git push origin master # 发布release

3. 检查travis发布进度，发布完成访问gitbook首页查看

    - [release首页](https://home1-oss.github.io/home1-oss-gitbook/release/)
    - [snapshot首页](https://home1-oss.github.io/home1-oss-gitbook/snapshot/)

## 参考资料

- [https://docs.travis-ci.com/user/deployment/pages/](https://docs.travis-ci.com/user/deployment/pages/)
