#!/usr/bin/env bash

# args: docs_path
function clean() {
    local docs_path="${1}"
    rm -rf _book;
    rm -rf ${docs_path}
}

function generate_resources() {
    local base_path="${1}"
    local projects=(`(cd ${base_path}; find . -maxdepth 1 -name '*' -type d)`)
    for project in "${projects[@]}"; do
        project=${project:2}
        project_path="${base_path}${project}"
        if [ -f ${project_path}/pom.xml ]; then
            echo "project ${project}"
            (cd ${project_path}; mvn clean:clean@auto-clean-readme resources:resources@auto-copy-readme-to-markdown resources:resources@auto-copy-readme-assets-to-markdown)
        fi
    done
}

# args: docs_path
function copy_resources() {
    local base_path="${1}"
    local docs_path="${2}"
    local file_type="${3}"
    files=(`(cd ${base_path}; find . -name "*.${file_type}" -print0 | xargs -0 ls | grep -E '^./(oss)-.+' | grep -v 'node_modules' | grep -v 'bower_components' | grep -v 'deprecated' | grep '/src/site/markdown/')`)
    for file in "${files[@]}"; do
        file=${file:2}
        local directory="$(echo $(dirname ${file}) | sed 's#/src/site/markdown##g')"
        #echo "directory: ${directory}"
	    #echo "file: ${file}"
	    echo "mkdir -p ${docs_path}/${directory}"
        mkdir -p ${docs_path}/${directory}

        local target="${docs_path}/$(echo ${file} | sed 's#/src/site/markdown##g')"
        echo "cp ${base_path}${file} ${target}"
        cp ${base_path}${file} ${target}
    done
}

function process_resources() {
    local base_path="${1}"
    local docs_path="docs"
    clean "${docs_path}"
    generate_resources "${base_path}"
    copy_resources "${base_path}" "${docs_path}" "md"
    copy_resources "${base_path}" "${docs_path}" "jpg"
    copy_resources "${base_path}" "${docs_path}" "jpeg"
    copy_resources "${base_path}" "${docs_path}" "png"
    copy_resources "${base_path}" "${docs_path}" "gif"
}

function deploy() {
    local target="${1}"
    local channel="${2}"
    local directory=""
    local id=""
    local port=""
    local user_host=""
    if [ "${target}" == "local" ]; then
        # ssh
        #directory="/usr/share/nginx/html/${directory}/"
        #id="-i ~/.ssh/local-mvnsite"
        #port="10022"
        #user_host="root@local-mvnsite"
        #echo "ssh ${id} -p ${port} ${user_host} 'rm -rf ${directory}; mkdir -p ${directory}'"
        #ssh ${id} -p ${port} ${user_host} "rm -rf ${directory}; mkdir -p ${directory}"
        #echo "scp ${id} -P ${port} -r ./_book/* ${user_host}:${directory}"
        #scp ${id} -P ${port} -r ./_book/* ${user_host}:${directory}
        # webdav
        directory="oss-${channel}/gitbook"
        local repository_url="${LOCAL_NEXUS}/repository/mvnsite/"
        local files=($(find ./_book -type f -print0 | xargs -0 ls))
        for file in "${files[@]}"; do
            local remote_file="${directory}/$(echo "${file}" | sed 's#^./_book/##')"
            echo "upload file: ${file}, to: ${repository_url}${remote_file}"
            #curl --user "deployment:deployment" --upload-file "${file}" "${repository_url}${remote_file}"
            # TODO 用户名密码从文件读取
            curl --user "deployment:deployment" -T "${file}" "${repository_url}${remote_file}"
        done
    else
        directory="/opt/mvn-sites/${directory}/"
        id="-i ~/.ssh/internal-mvnsite"
        port="22"
        user_host="root@mvn-site.internal"
        echo "ssh ${id} -p ${port} ${user_host} 'rm -rf ${directory}; mkdir -p ${directory}'"
        ssh ${id} -p ${port} ${user_host} "rm -rf ${directory}; mkdir -p ${directory}"
        echo "scp ${id} -P ${port} -r ./_book/* ${user_host}:${directory}"
        scp ${id} -P ${port} -r ./_book/* ${user_host}:${directory}
    fi
}

if type -p gitbook; then
    echo "gitbook executable found in PATH."
else
    echo "gitbook executable not found in PATH."
    if type -p npm; then
        echo "auto install gitbook via npm."
        npm --registry=https://registry.npm.taobao.org install 'gitbook-cli@2.3.0' -g
    else
        echo "gitbook executable not found in PATH."
        echo "can not auto install gitbook via npm."
    fi
fi

arg_base_path=""
if [ "deploy" != "${1}" ] && [ ! -z "${2}" ] && [ -d "${2}" ]; then
    arg_base_path="${2}"
    if [[ "${arg_base_path}" != */ ]]; then
        arg_base_path="${arg_base_path}/"
    fi
else
    arg_base_path="../../../"
fi
echo "arg_base_path: ${arg_base_path}"

case $1 in
    "serve")
        process_resources "${arg_base_path}"
        exec gitbook serve
        ;;

    "build")
        process_resources "${arg_base_path}"
        exec gitbook build
        ;;

    "build_debug")
        process_resources "${arg_base_path}"
        exec gitbook build ./ --log=debug --debug
        ;;

    "deploy")
        target="${2}"
        if [ -z "${target}" ]; then
            echo "no target specified"
            exit 1
        fi
        if [ -z "${BUILD_PUBLISH_CHANNEL}" ]; then
          deploy "${target}" "snapshot"
        else
          deploy "${target}" "${BUILD_PUBLISH_CHANNEL}"
        fi
        ;;

    "pdf")
        process_resources "${arg_base_path}"
        exec gitbook pdf ./ ./oss.pdf
        ;;

    "epub")
        process_resources "${arg_base_path}"
        exec gitbook epub ./ ./oss.epub
        ;;

    "mobi")
        process_resources "${arg_base_path}"
        exec gitbook mobi ./ ./oss.mobi
        ;;

    *)
        echo -e "Usage: $0 param
    param are follows:
        serve       Preview and serve your book
        build       Build the static website using
        build_debug Debugging build
        pdf         Generate a PDF file
        epub        Generate an ePub file
        mobi        Generate a Mobi file
        deploy      deploy to [ local | internal ]
        "
        ;;
esac
