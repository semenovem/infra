package roles

type Role string

const (
	ProxyServer   Role = "PROXY_SERVER"
	HomeServer    Role = "HOME_SERVER"
	Workstation   Role = "WORKSTATION"
	StandbyServer Role = "STANDBY_SERVER"
	MiniServer    Role = "MINI_SERVER"
	OfficeServer  Role = "OFFICE_SERVER"
)
