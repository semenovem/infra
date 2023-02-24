package configs

import "fmt"

func verifyPortForwarding(cfg *Config) []string {
	if cfg.PortForwarding == nil {
		return nil
	}

	errs := make([]string, 0)

	dups := duplicates(cfg.PortForwarding.Hosts())
	if len(dups) != 0 {
		errs = append(errs, fmt.Sprintf("port_forwarding.hosts: дубликаты %s", dups))
	}

	return errs
}
