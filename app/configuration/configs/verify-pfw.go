package configs

import "fmt"

func verifySSHLocalForward(cfg *Config) []string {
	if cfg.SSHLocalForward == nil {
		return nil
	}

	errs := make([]string, 0)

	dups := duplicates(cfg.SSHLocalForward.Hosts())
	if len(dups) != 0 {
		errs = append(errs, fmt.Sprintf("ssh_local_forward.hosts: дубликаты %s", dups))
	}

	return errs
}
