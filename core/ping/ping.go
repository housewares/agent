package ping

import (
	"github.com/docker/docker/client"
	"github.com/pkg/errors"
	"github.com/rancher/agent/core/hostinfo"
	"github.com/rancher/agent/model"
	"github.com/rancher/agent/utilities/config"
	"github.com/rancher/agent/utilities/constants"
	revents "github.com/rancher/event-subscriber/events"
)

func DoPingAction(event *revents.Event, resp *model.PingResponse, dockerClient *client.Client, collectors []hostinfo.Collector) error {
	if !config.DockerEnable() {
		return nil
	}
	if err := addResource(event, resp, dockerClient, collectors); err != nil {
		return errors.Wrap(err, constants.DoPingActionError+"failed to add resource")
	}
	if err := addInstance(event, resp, dockerClient); err != nil {
		return errors.Wrap(err, constants.DoPingActionError+"failed to add instance")
	}
	return nil
}
