package configs

import (
	"strings"
)

func (c *Config) GetHostByName(n string) *Host {
	for _, host := range c.Hosts {
		if strings.EqualFold(host.Name, n) {
			return host
		}
	}

	return nil
}

// GetHostRoleByName получить роль машины по имени
func (c *Config) GetHostRoleByName(n string) string {
	host := c.GetHostByName(n)
	if host != nil {
		return host.Role
	}

	return ""
}

// GetAllowIncomingSSHByRole Получить роли, которые могут подключиться к хосту
func (c *Config) GetAllowIncomingSSHByRole(n string) []string {
	for _, role := range c.Roles {
		if role.Name == n {
			return role.AllowIncomingSSHForRoles()
		}
	}

	return nil
}

// GetPubKeysOfUserMainByRoles Получить публичные ключи у хостов, имеющих роли у пользователя main
func (c *Config) GetPubKeysOfUserMainByRoles(roles []string) []string {
	var (
		pubKeys = make([]string, 0)
		roleMap = make(map[string]struct{})
	)

	for _, r := range roles {
		roleMap[r] = struct{}{}
	}

	for _, host := range c.Hosts {
		if _, ok := roleMap[host.Role]; ok {
			pubKey := host.GetMainPubKeyBySSHUserName()

			if pubKey != "" {
				pubKeys = append(pubKeys, pubKey)
			}
		}
	}

	return pubKeys
}

func (c *Config) GetSSHLocalForwardByHostName(n string) *SSHLocalForward {
	host := c.GetHostByName(n)
	if host != nil && host.SSHLocalForward != nil {
		var pfw = new(SSHLocalForward)
		*pfw = *host.SSHLocalForward

		if pfw.HostsRaw == "" && c.SSHLocalForward != nil {
			pfw.HostsRaw = c.SSHLocalForward.HostsRaw
		}

		return pfw
	}

	return nil
}
