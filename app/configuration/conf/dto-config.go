package configs

import (
	"fmt"
	"strings"
)

type Config struct {
	Version          string             `yaml:"version"`
	Hosts            []*DTOHost         `yaml:"hosts"`
	Roles            []*DTORole         `yaml:"roles"`
	SSHRemoteForward *DTOSSHPortForward `yaml:"ssh_remote_forward"`
}

func (c *Config) getMapOfHosts() map[string]*DTOHost {
	m := make(map[string]*DTOHost)

	for _, host := range c.Hosts {
		m[host.Name] = host
	}

	return m
}

func (c *Config) GetHostByNameDeprec(n string) *DTOHost {
	for _, host := range c.Hosts {
		if strings.EqualFold(host.Name, n) {
			return host
		}
	}

	return nil
}

func (c *Config) GetHostByName(n string) (*DTOHost, error) {
	for _, host := range c.Hosts {
		if strings.EqualFold(host.Name, n) {
			return host, nil
		}
	}

	return nil, NewErrNotFound("host [%s] not found", n)
}

// GetHostRoleByName получить роль машины по имени
func (c *Config) GetHostRoleByName(n string) string {
	host := c.GetHostByNameDeprec(n)
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
			pubKey := host.getMainPubKeyBySSHUserName()

			if pubKey != "" {
				pubKeys = append(pubKeys, pubKey)
			}
		}
	}

	return pubKeys
}

func (c *Config) GetSSHLocalForwardByHostName(n string) *DTOSSHPortForward {
	host := c.GetHostByNameDeprec(n)
	if host != nil && host.SSHRemoteForward != nil {
		var pfw = new(DTOSSHPortForward)
		*pfw = *host.SSHRemoteForward

		if pfw.HostsRaw == "" && c.SSHRemoteForward != nil {
			pfw.HostsRaw = c.SSHRemoteForward.HostsRaw
		}

		return pfw
	}

	return nil
}

// GetSSHConnForward возвращает данные для проброса портов
func (c *Config) GetSSHConnForward(hostName string) ([]*SSHConnForward, error) {
	thisHost, err := c.GetHostByName(hostName)
	if err != nil || thisHost.SSHRemoteForward == nil {
		return nil, err
	}

	conns, err := thisHost.SSHRemoteForward.getConnectTo()
	if err != nil {
		return nil, err
	}

	fmt.Println()
	fmt.Println()

	var (
		mapOfHosts = c.getMapOfHosts()
		//user       = thisHost.SSHRemoteForward.getUser()
	)

	// Обогатить данные
	for _, v := range conns {
		if host, ok := mapOfHosts[v.conn.host]; ok {
			if h := host.getSSHPublicConn(); h != "" {
				v.conn.host = h
			}
			//v.conn.
		}

		fmt.Printf("................ %+v \n", v)
	}

	return conns, nil
}

// GetExistingRoles Возвращает список существующих ролей
func (c *Config) GetExistingRoles() (map[string]*DTORole, error) {
	roles := make(map[string]*DTORole)

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
