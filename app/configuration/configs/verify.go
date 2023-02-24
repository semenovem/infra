package configs

func Verify(cfg *Config) []string {
	errs := verifyRoles(cfg)
	errs = append(errs, verifyPortForwarding(cfg)...)
	errs = append(errs, verifyHosts(cfg)...)

	return errs
}

func duplicates(arr []string) []string {
	var (
		dubls = make([]string, 0)
		set   = make(map[string]struct{})
	)

	for _, item := range arr {
		_, ok := set[item]
		if ok {
			dubls = append(dubls, item)
		}
		set[item] = struct{}{}
	}

	return dubls
}

func getKnownRoles(cfg *Config) map[string]struct{} {
	m := make(map[string]struct{})

	if cfg.Roles != nil {
		for _, role := range cfg.Roles {
			m[role.Name] = struct{}{}
		}
	}

	return m
}
