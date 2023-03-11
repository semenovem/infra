package configs

import (
	"fmt"
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
		if strings.EqualFold(role.Name, n) {
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

func (c *Config) GetSSHLocalForwardByHostName(n string) *SSHRemoteForward {
	host := c.GetHostByName(n)
	if host != nil && host.SSHRemoteForward != nil {
		var pfw = new(SSHRemoteForward)
		*pfw = *host.SSHRemoteForward

		if pfw.HostsRaw == "" && c.SSHRemoteForward != nil {
			pfw.HostsRaw = c.SSHRemoteForward.HostsRaw
		}

		return pfw
	}

	return nil
}

// GetExistingRoles Возвращает список существующих ролей
func (c *Config) GetExistingRoles() (map[string]*Role, error) {
	roles := make(map[string]*Role)

	for _, r := range c.Roles {
		n := strings.ToLower(r.Name)

		if _, ok := roles[n]; ok {
			return nil, fmt.Errorf(errDuplicateRoleMsg, r.Name)
		}
		roles[n] = r
	}

	return roles, nil
}

// IsRoleExists проверяет - существует ли роль
func (c *Config) IsRoleExists(roleName string) error {
	name := strings.ToLower(roleName)

	roles, err := c.GetExistingRoles()
	if err != nil {
		return err
	}

	_, ok := roles[name]
	if !ok {
		return fmt.Errorf(errRoleExistsMsg, name)
	}

	return nil
}
