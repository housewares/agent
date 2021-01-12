
---

⚠️ Custom version of [rancher/agent](https://github.com/rancher/agent) for Linux with disabled [links](https://rancher.com/docs/rancher/v1.6/en/cattle/adding-services/#linking-services) support to workaround this issue:

* https://github.com/rancher/rancher/issues/30734

See [dist/README.md](dist/README.md) for details on building and deploying this custom agent version.

* Pre-built agent binary and archive: [Releases/v0.3.11-no-links](https://github.com/housewares/agent/releases/tag/v0.3.11-no-links)
* Pre-built Rancher server container with updated agent: [housewares/server:v1.6.30-no-links](https://hub.docker.com/r/housewares/server)

---

agent
========

This agent runs on compute nodes in a Rancher cluster. It receives events from the Rancher server, acts upon them, and returns response events.

## Building

`make`


## Running

`./bin/agent`

## License
Copyright (c) 2014-2016 [Rancher Labs, Inc.](http://rancher.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
