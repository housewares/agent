# Building and deploying custom agent version for Rancher 1.6.x

Depending on your setup, to use updated `agent` binary you may need to follow one of the options below.

Note that [rancher/agent](https://hub.docker.com/r/rancher/agent) image doesn't include an actual `agent` binary. It's acquired from the server during the agent startup on host.

## 1. Updating agent in `rancher-agent` container

If you already run `rancher-agent` container on registered hosts, you can update `agent` binary directly in the container.

1. Run `make` in repo root to build agent
2. Upload [bin/agent](/bin/agent) to http(s) server
3. Login to Rancher worker node (not server!)
4. Execute this one-liner, supplying correct url for uploaded `agent` binary in step 1
    ```shell
    docker exec \
    --env agent_url='https://example.com/agent' \
    --env agent_path='/var/lib/cattle/pyagent/agent' \
    rancher-agent \
    bash -c '\
    mv --verbose --no-clobber "${agent_path}" "${agent_path}.bak" && \
    rm "${agent_path}" && \
    curl "${agent_url}" --silent --location --output "${agent_path}" && \
    chmod +x "${agent_path}" && \
    killall --exact agent && \
    "${agent_path}" --version'
    ```

## 2. Specify alternate agent archive url for new hosts

If you plan to register new hosts, you can configure Rancher server to send [custom url](https://forums.rancher.com/t/docs-on-how-to-build-a-debug-rancher-rancher-agent/6351) for `agent` binary archive to newly registering hosts.

1. Run `make` in repo root to build agent
2. Upload [dist/artifacts/go-agent.tar.gz](/dist/artifacts/go-agent.tar.gz) to http(s) server
3. Configure `agent.package.python.agent.url` setting in Rancher server with new url from step 1:  
   https://your-rancher-server/v2-beta/settings/agent.package.python.agent.url
4. Register new host with Rancher server as usual, by running `rancher-agent` container with options provided by Rancher server's `Add host` page.

## 3. Buld custom versions of [rancher/server](https://hub.docker.com/r/rancher/server) image and upgrade to it

If you have no hosts added to Rancher server you may only need this. Otherwise, see option 1 to update existing hosts.

1. Run `make` in repo root
2. Update `CATTLE_RANCHER_SERVER_IMAGE` variable in [Dockerfile](Dockerfile) with your container image registry/repository
3. Run `docker build .` in this directory
4. Push resulting image to your registry
5. Upgrade your Rancher server to this image: https://rancher.com/docs/rancher/v1.6/en/upgrading/

Alternatevely, you can use pre-bult image: [housewares/server](https://hub.docker.com/r/housewares/server)

### Details

I don't have time/energy to make proper image builds for `rancher/server` image, so we just use it as a base and copy our custom agent build output on top of the existing image. See [Dockerfile](Dockerfile) in this directory for details.

The [server-and-agent-versions.sh](server-and-agent-versions.sh) helper script goes through the [rancher/server](https://hub.docker.com/r/rancher/server) images and tries to figure out what version of Linux agent is included in the image and which commit in this repo it's built from.

Note, that `-dirty` in version means that agent was built from non-tagged commit and there were untracked files in the repo. See [version](/scripts/version) script for details.

Example output

```none
--------------------------------------------------------------------------------
  [ rancher/server ]
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.25
Image digest  : sha256:7cec47e198334214ac70bab960288bd0b300a965e83efde57d8a1efafdd6f2a4
Agent version : v0.13.9
Agent git log : commit 71443e64a4574d9b2fc686973a483587ef62189c

reuse transport connection


tag: v0.13.9
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.26
Image digest  : sha256:e0f061df99c0a2e1b4ccad8d39fd2091b1cc70ccb1833f12125d149891465b40
Agent version : c8663d1-dirty
Agent git log : commit c8663d12dd253ef13258750dca056d4b1219fc10

Merge pull request #287 from alena1108/jan3

 Use go 1.9.0

HEAD -> origin/v1.6, refs/original/refs/tags/v0.13.11
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.27
Image digest  : sha256:290e94536b32665d0ff537c2b947804faeed2768cd8652f0088a0d7e1acced75
Agent version : c8663d1-dirty
Agent git log : commit c8663d12dd253ef13258750dca056d4b1219fc10

Merge pull request #287 from alena1108/jan3

 Use go 1.9.0

HEAD -> origin/v1.6, refs/original/refs/tags/v0.13.11
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.28
Image digest  : sha256:03a1759d5edbceeb0160c0eda6406021c3ab037e3f2661cfac36c6cf1132eecc
Agent version : c8663d1-dirty
Agent git log : commit c8663d12dd253ef13258750dca056d4b1219fc10

Merge pull request #287 from alena1108/jan3

 Use go 1.9.0

HEAD -> origin/v1.6, refs/original/refs/tags/v0.13.11
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.29
Image digest  : sha256:bceb994e83d86a8d2c0e199c36ce247b3d79c0b40f9e4dded2d2f5e834c35900
Agent version : c8663d1-dirty
Agent git log : commit c8663d12dd253ef13258750dca056d4b1219fc10

Merge pull request #287 from alena1108/jan3

 Use go 1.9.0

HEAD -> origin/v1.6, refs/original/refs/tags/v0.13.11
--------------------------------------------------------------------------------
Server image  : rancher/server:v1.6.30
Image digest  : sha256:95b55603122c28baea4e8d94663aa34ad770bbc624a9ed6ef986fb3ea5224d91
Agent version : c8663d1-dirty
Agent git log : commit c8663d12dd253ef13258750dca056d4b1219fc10

Merge pull request #287 from alena1108/jan3

 Use go 1.9.0

HEAD -> origin/v1.6, refs/original/refs/tags/v0.13.11
--------------------------------------------------------------------------------
```
