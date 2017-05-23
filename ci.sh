#!/usr/bin/env bash

### OSS CI CONTEXT VARIABLES BEGIN
if [ -n "${CI_BUILD_REF_NAME}" ] && ([ "${CI_BUILD_REF_NAME}" == "master" ] || [ "${CI_BUILD_REF_NAME}" == "develop" ]); then BUILD_SCRIPT_REF="${CI_BUILD_REF_NAME}"; else BUILD_SCRIPT_REF="develop"; fi
if [ -z "${GIT_SERVICE}" ]; then
    if [ -n "${CI_PROJECT_URL}" ]; then INFRASTRUCTURE="internal"; GIT_SERVICE=$(echo "${CI_PROJECT_URL}" | sed 's,/*[^/]\+/*$,,' | sed 's,/*[^/]\+/*$,,'); else INFRASTRUCTURE="local"; GIT_SERVICE="${LOCAL_GIT_SERVICE}"; fi
fi
if [ -z "${GIT_REPO_OWNER}" ]; then
    if [ -n "${TRAVIS_REPO_SLUG}" ]; then
        GIT_REPO_OWNER=$(echo ${TRAVIS_REPO_SLUG} | awk -F/ '{print $1}');
    else
        if [ -z "${INTERNAL_GIT_SERVICE_USER}" ]; then GIT_REPO_OWNER="infra"; else GIT_REPO_OWNER="${INTERNAL_GIT_SERVICE_USER}"; fi
    fi
fi
### OSS CI CONTEXT VARIABLES END

export BUILD_PUBLISH_DEPLOY_SEGREGATION="false"
export BUILD_SITE="true"
export BUILD_SITE_PATH_PREFIX="oss"
export BUILD_HOME1_OSS_OWNER="home1-oss"
export BUILD_SITE_GITHUB_REPOSITORY_OWNER="${BUILD_HOME1_OSS_OWNER}"
export BUILD_SITE_GITHUB_REPOSITORY_NAME="home1-oss"
export BUILD_TEST_FAILURE_IGNORE="false"
export BUILD_TEST_SKIP="false"
export BUILD_PUBLISH_CHANNEL="snapshot"



### OSS CI CALL REMOTE CI SCRIPT BEGIN
echo "eval \$(curl -s -L ${GIT_SERVICE}/${GIT_REPO_OWNER}/oss-build/raw/${BUILD_SCRIPT_REF}/src/main/ci-script/ci.sh)"
eval "$(curl -s -L ${GIT_SERVICE}/${GIT_REPO_OWNER}/oss-build/raw/${BUILD_SCRIPT_REF}/src/main/ci-script/ci.sh)"
### OSS CI CALL REMOTE CI SCRIPT END

. src/gitbook/deploy.sh

# home1-oss && not pr trigger will on condition
if ([ "${GIT_REPO_OWNER}" == "${BUILD_HOME1_OSS_OWNER}" ] && [ "pull_request" != "${TRAVIS_EVENT_TYPE}" ]); then
    case "$CI_BUILD_REF_NAME" in
        "develop")
            export BUILD_PUBLISH_CHANNEL="snapshot";
            $@;
            ;;
        "master")
            export BUILD_PUBLISH_CHANNEL="release";
            $@;
            ;;
        feature*|hotfix*|*)
            echo "skip this action,as not on condition branch,CI_BUILD_REF_NAME=${CI_BUILD_REF_NAME}"
            ;;
    esac
else $@; fi

