package conf

import "fmt"

func verifyRoles(cfg *Config) []string {
	if cfg.Roles == nil {
		return nil
	}

	var (
		errs = make([]string, 0)
		arr  = make([]string, 0)
	)

	for _, role := range cfg.Roles {
		arr = append(arr, role.Name)
	}

	dups := duplicates(arr)
	if len(dups) != 0 {
		errs = append(errs, fmt.Sprintf("roles: имеет дубликат %s", dups))
	}

	for _, role := range cfg.Roles {
		dups = duplicates(role.allowIncomingSSHForRoles())
		if len(dups) != 0 {
			errs = append(errs, fmt.Sprintf(
				"roles.[%s].allow_incoming_ssh_for_roles: имеет дубликат %s",
				role.Name, dups))
		}
	}

	return errs
}
