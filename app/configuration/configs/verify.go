package configs

func verify(c Config) error {
	return nil
}

// Проверить:
// - PortForwarding.HostsRaw не содержат дубликатов и не существующих значений
// - Host.roles = не содержат дубликатов и только значения из roles.
