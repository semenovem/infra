package configs

import "fmt"

func verifyHosts(cfg *Config) []string {
	if cfg.Hosts == nil {
		return nil
	}

	var (
		errs       = make([]string, 0)
		knownRoles = getKnownRoles(cfg)
		hostNames  = make([]string, 0)
	)

	for _, host := range cfg.Hosts {
		hostNames = append(hostNames, host.Name)
	}

	dups := duplicates(hostNames)
	if len(dups) != 0 {
		errs = append(errs, fmt.Sprintf("hosts: дубликаты %s", dups))
	}

	// Неизвестные роли
	for _, host := range cfg.Hosts {
		if _, ok := knownRoles[host.Role]; !ok {
			errs = append(errs, fmt.Sprintf(
				"hosts.[%s].Role: неизвестная роль %s",
				host.Name, host.Role))
		}
	}

	return errs
}