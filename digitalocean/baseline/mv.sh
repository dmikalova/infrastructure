#!/bin/sh
. $HOME/.bashrc
tg state mv 'module.vpcs.digitalocean_vpc.name["blr1"]' 'module.vpcs.digitalocean_vpc.main["blr1"]'
tg state mv 'module.vpcs.digitalocean_vpc.name["nyc1"]' 'module.vpcs.digitalocean_vpc.main["nyc1"]'
tg state mv 'module.vpcs.digitalocean_vpc.name["nyc3"]' 'module.vpcs.digitalocean_vpc.main["nyc3"]'
tg state mv 'module.vpcs.digitalocean_vpc.name["sfo2"]' 'module.vpcs.digitalocean_vpc.main["sfo2"]'
tg state mv 'module.vpcs.digitalocean_vpc.name["sfo3"]' 'module.vpcs.digitalocean_vpc.main["sfo3"]'
