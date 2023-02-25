package configs

import "fmt"

func verifySSHLocalForward(cfg *Config) []string {
	if cfg.SSHRemoteForward == nil {
		return nil
	}

	errs := make([]string, 0)

	dups := duplicates(cfg.SSHRemoteForward.Hosts())
	if len(dups) != 0 {
		errs = append(errs, fmt.Sprintf("ssh_remote_forward.hosts: дубликаты %s", dups))
	}

	return errs
}
