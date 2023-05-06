package conf

import (
	"configuration/entity"
	"fmt"
	"strings"
)

func (c *Config) GetHost(n string) (*DTOHost, error) {
	for _, host := range c.Hosts {
		if strings.EqualFold(host.Name, n) {
			return host, nil
		}
	}

	return nil, NewErrNotFound("host [%s] not found", n)
}

func (c *Config) IfHasGetHost(n string) *DTOHost {
	for _, host := range c.Hosts {
		if strings.EqualFold(host.Name, n) {
			return host
		}
	}

	return nil
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

// GetSSHConnForward возвращает данные для проброса портов
func (c *Config) GetSSHConnForward(hostName string) ([]*entity.SSHPortForward, error) {
	sshForward, err := c.getHostSSHPortForward(hostName)
	if err != nil || sshForward == nil {
		return nil, err
	}

	conns1, err := sshForward.getConvertHosts()
	if err != nil {
		return nil, err
	}

	conns2, err := sshForward.getConnections()
	if err != nil {
		return nil, err
	}

	conns := append(conns1, conns2...)

	// Обогатить данные
	for _, v := range conns {
		if host := c.IfHasGetHost(v.Host); host != nil {
			if host.SSH != nil {
				ssh := host.SSH

				if v.User == "" {
					v.User = ssh.getMainUser()
					v.Port = ssh.Port
				}

				if v.Port == 0 {
					v.Port = ssh.Port
				}
			}

			v.Host = host.getSSHPublicURLOrIP()
		}

		if v.User == "" && sshForward.User != "" {
			v.User = sshForward.User
		}
	}

	return conns, nil
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

// GetAllowIncomingSSHByRole Получить роли, которые могут подключиться к хосту
func (c *Config) GetAllowIncomingSSHByRole(n string) []string {
	for _, role := range c.Roles {
		if strings.EqualFold(role.Name, n) {
			return role.allowIncomingSSHForRoles()
		}
	}

	return nil
}
