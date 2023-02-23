package configs

func verify(c Config) error {
	return nil
}

// Проверить:
// - PortForwarding.ProxiesRaw не содержат дубликатов и не существующих значений
// - CPI.roles = не содержат дубликатов и только значения из roles.
