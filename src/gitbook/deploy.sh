#!/usr/bin/env bash


declare -A OSS_REPOSITORIES_DICT
OSS_REPOSITORIES_DICT["home1-oss"]="/${GIT_REPO_OWNER}/home1-oss"
OSS_REPOSITORIES_DICT["oss-internal"]="/${GIT_REPO_OWNER}/oss-internal"
OSS_REPOSITORIES_DICT["oss-local"]="/${GIT_REPO_OWNER}/oss-local"
OSS_REPOSITORIES_DICT["oss-github"]="/${GIT_REPO_OWNER}/oss-github"
OSS_REPOSITORIES_DICT["oss-build"]="/${GIT_REPO_OWNER}/oss-build"
OSS_REPOSITORIES_DICT["oss-common-dependencies"]="/${GIT_REPO_OWNER}/oss-common-dependencies"

OSS_REPOSITORIES_DICT["oss-lib"]="/${GIT_REPO_OWNER}/oss-lib"
OSS_REPOSITORIES_DICT["oss-lib-errorhandle"]="/${GIT_REPO_OWNER}/oss-lib-errorhandle"
OSS_REPOSITORIES_DICT["oss-lib-security"]="/${GIT_REPO_OWNER}/oss-lib-security"
OSS_REPOSITORIES_DICT["oss-lib-webmvc"]="/${GIT_REPO_OWNER}/oss-lib-webmvc"
OSS_REPOSITORIES_DICT["oss-lib-hystrix"]="/${GIT_REPO_OWNER}/oss-lib-hystrix"
OSS_REPOSITORIES_DICT["oss-lib-swagger"]="/${GIT_REPO_OWNER}/oss-lib-swagger"
OSS_REPOSITORIES_DICT["oss-lib-adminclient"]="/${GIT_REPO_OWNER}/oss-lib-adminclient"
OSS_REPOSITORIES_DICT["oss-lib-log4j2"]="/${GIT_REPO_OWNER}/oss-lib-log4j2"

OSS_REPOSITORIES_DICT["oss-eureka"]="/${GIT_REPO_OWNER}/oss-eureka"
OSS_REPOSITORIES_DICT["oss-admin"]="/${GIT_REPO_OWNER}/oss-admin"
OSS_REPOSITORIES_DICT["oss-configserver"]="/${GIT_REPO_OWNER}/oss-configserver"
OSS_REPOSITORIES_DICT["oss-configlint"]="/${GIT_REPO_OWNER}/oss-configlint"
OSS_REPOSITORIES_DICT["oss-keygen"]="/${GIT_REPO_OWNER}/oss-keygen"

OSS_REPOSITORIES_DICT["oss-archetype"]="/${GIT_REPO_OWNER}/oss-archetype"
OSS_REPOSITORIES_DICT["oss-release"]="/${GIT_REPO_OWNER}/oss-release"

OSS_REPOSITORIES_DICT["oss-todomvc-app-config"]="/${GIT_REPO_OWNER}/oss-todomvc-app-config"
OSS_REPOSITORIES_DICT["oss-todomvc"]="/${GIT_REPO_OWNER}/oss-todomvc"
OSS_REPOSITORIES_DICT["oss-todomvc-gateway-config"]="/${GIT_REPO_OWNER}/oss-todomvc-gateway-config"
OSS_REPOSITORIES_DICT["oss-todomvc-thymeleaf-config"]="/${GIT_REPO_OWNER}/oss-todomvc-thymeleaf-config"

#echo "${!OSS_REPOSITORIES_DICT[@]}"
#echo "${OSS_REPOSITORIES_DICT["key"]}"
for key in ${!OSS_REPOSITORIES_DICT[@]}; do echo ${key}; done
for value in ${OSS_REPOSITORIES_DICT[@]}; do echo ${value}; done
echo "OSS_REPOSITORIES_DICT has ${#OSS_REPOSITORIES_DICT[@]} elements"

# 将oss全套项目和配置repo逐个clone到当前目录下

# arguments: git_domain, source_group
function clone_oss_repositories() {
    local git_domain="${1}"
    local source_group="${2}"

    echo "clone_oss_repositories ${git_domain} ${source_group}"
    for repository in ${!OSS_REPOSITORIES_DICT[@]}; do
        original_repository_path=$(echo ${OSS_REPOSITORIES_DICT[${repository}]} | sed 's#^/##')

        if [ ! -z "${source_group}" ]; then
            source_repository_path="${source_group}/${repository}"
            repository_path="${source_repository_path}"
        else
            repository_path="${original_repository_path}"
        fi

        if [ -d ${repository} ] && [ -d ${repository}/.git ]; then
            if [ "${repository_path}" != "${original_repository_path}" ] && [ -z "$(cd ${repository}; git remote -v | grep -E 'upstream.+(fetch)')" ]; then
                (cd ${repository} && git remote add upstream https://$GITHUB_GIT_SERVICE_TOKEN:x-oauth-basic@${git_domain}/${repository_path} && git fetch upstream)
            fi
        else
            if [ ! -d ${repository}/.git ]; then
                rm -rf ${repository}
            fi
            echo clone repository ${repository}
            # echo http: ${git_domain}/${repository_path}
            # echo "clone: git@${git_domain}:${repository_path}.git"
            # https://github.com/blog/1270-easier-builds-and-deployments-using-git-over-https-and-oauth
            echo "clone: https://$GITHUB_GIT_SERVICE_TOKEN:x-oauth-basic@${git_domain}/${repository_path}"
            git clone https://$GITHUB_GIT_SERVICE_TOKEN:x-oauth-basic@${git_domain}/${repository_path}
            if [ "${repository_path}" != "${original_repository_path}" ]; then
                (cd ${repository} && git remote add upstream git@${git_domain}:${original_repository_path}.git && git fetch upstream)
            fi
        fi
    done
}

function get_git_domain() {
  local git_service="${1}"
  local git_host_port=$(echo ${git_service} | awk -F/ '{print $3}')
  if [[ "${git_service}" == *local-git:* ]]; then
    echo ${git_host_port} | sed -E 's#:[0-9]+$##'
  else
    echo ${git_host_port}
  fi
}

# build gitbook
function gitbook_build(){
  echo "build gitbook"
#  eval "$(curl -s -L ${GIT_SERVICE}/${GIT_REPO_OWNER}/oss-build/raw/${BUILD_SCRIPT_REF}/src/main/install/oss_repositories.sh)"

  if [ ! -d src/gitbook/oss-workspace ]; then
        mkdir -p src/gitbook/oss-workspace
  fi
  echo "GIT_SERVICE: ${GIT_SERVICE}"
  source_git_domain="$(get_git_domain "${GIT_SERVICE}")"
  (cd src/gitbook/oss-workspace; clone_oss_repositories "${source_git_domain}")
  for repository in ${!OSS_REPOSITORIES_DICT[@]}; do
    source_git_branch=""
    if [ "release" == "${BUILD_PUBLISH_CHANNEL}" ]; then source_git_branch="master"; else source_git_branch="develop"; fi
    echo "git checkout ${source_git_branch} of ${repository}"
    (cd src/gitbook/oss-workspace/${repository}; git checkout ${source_git_branch} && git pull)
  done
  (cd src/gitbook; ./book.sh "build" "oss-workspace")
  # clean unused dir
  (cd src/gitbook; rm -rf _book/oss-workspace)
}

function before_deploy(){
  git_domain="$(get_git_domain "${GIT_SERVICE}")"

  if [ -d "src/gitbook/${OSS_GITBOOK_GITHUB_PAGES_REPO}" ]; then
    rm -rf src/gitbook/${OSS_GITBOOK_GITHUB_PAGES_REPO}
  fi

  (cd src/gitbook/ && git clone https://$GITHUB_GIT_SERVICE_TOKEN:x-oauth-basic@${git_domain}/${OSS_GITBOOK_GITHUB_PAGES_OWNER}/${OSS_GITBOOK_GITHUB_PAGES_REPO})
  (cd src/gitbook/${OSS_GITBOOK_GITHUB_PAGES_REPO} && git checkout gh-pages && git pull)
  if [ ! -d "src/gitbook/${OSS_GITBOOK_GITHUB_PAGES_REPO}/${BUILD_PUBLISH_CHANNEL}" ]; then mkdir -p src/gitbook/${OSS_GITBOOK_GITHUB_PAGES_REPO}/${BUILD_PUBLISH_CHANNEL}; fi

  (rm -rf src/gitbook/$OSS_GITBOOK_GITHUB_PAGES_REPO/.git)
  (rm -rf src/gitbook/$OSS_GITBOOK_GITHUB_PAGES_REPO/$BUILD_PUBLISH_CHANNEL/*)
  (cp -R src/gitbook/_book/* src/gitbook/$OSS_GITBOOK_GITHUB_PAGES_REPO/$BUILD_PUBLISH_CHANNEL/)
  (rm -rf $OSS_GITBOOK_GITHUB_PAGES_REPO && mv src/gitbook/$OSS_GITBOOK_GITHUB_PAGES_REPO $OSS_GITBOOK_GITHUB_PAGES_REPO && ls -lh $OSS_GITBOOK_GITHUB_PAGES_REPO/*)
  echo "prepare for deploy to gh-pages"
}