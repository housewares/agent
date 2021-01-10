# This info is gathered from rancher/rancher GitHub releases:
# https://github.com/rancher/rancher/releases

# https://github.com/rancher/rancher/releases/v1.6.30
# rancher/server:v1.6.30
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.14

# https://github.com/rancher/rancher/releases/v1.6.30
# rancher/server:v1.6.29
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.13

# https://github.com/rancher/rancher/releases/v1.6.28
# rancher/server:v1.6.28
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.11

# https://github.com/rancher/rancher/releases/v1.6.27
# rancher/server:v1.6.27
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.11

# https://github.com/rancher/rancher/releases/v1.6.26
# rancher/server:v1.6.26
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.6

# https://github.com/rancher/rancher/releases/v1.6.25
# rancher/server:v1.6.25
# rancher/agent:v1.2.11
# rancher/lb-service-haproxy:v0.9.6

# set -x

# Get built-in agent version in server image

printf -v dash '%.0s-' {1..80}

get_agent_version () {
    image="${1}"
    printf -v tag "${2}" "${3}"
    server_agent_path='/usr/share/cattle/artifacts/go-agent.tar.gz'
    tmp_file="$(mktemp)"
    digest="$(docker pull "${image}:${tag}" | grep -oP '\Ksha256:\w+$')"

    docker run --rm --entrypoint tar "${image}@${digest}" \
      --extract --to-stdout --wildcards --no-anchored 'agent' --file="${server_agent_path}" > "${tmp_file}"

    chmod +x "${tmp_file}"

    version="$("${tmp_file}" --version | awk '{print $3}')"

    printf "Server image  : %s\nImage digest  : %s\nAgent version : %s\nAgent git log : %s\n" \
      "${image}:${tag}" \
      "${digest}" \
      "${version}" \
      "$(git rev-list --format=%n%B%n%n%D --max-count=1 "${version/-dirty/}")"

    rm "${tmp_file}"

    echo $dash
}

echo $dash
echo '  [ rancher/server ]'
echo $dash

range=30
for ((i=25 ; i<=range ; i++))
do
  get_agent_version 'rancher/server' 'v1.6.%s' "${i}"
done

echo '  [ housewares/server ]'
echo $dash

get_agent_version 'housewares/server' 'v1.6.%s-no-links' '30'
