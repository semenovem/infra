#!/bin/sh

source="https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-arm64.tar.gz"

curl -LO "$source"
tar -zxvf node_exporter-1.8.2.linux-arm64.tar.gz
rm node_exporter-1.8.2.linux-arm64.tar.gz

sudo mkdir -p /opt/node_exporter
sudo cp node_exporter-1.8.2.linux-arm64/node_exporter /opt/node_exporter

# put unit
/etc/systemd/system/node-exporter.service


systemctl start node-exporter.service
systemctl status node-exporter.service
systemctl enable node-exporter.service
