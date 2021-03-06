# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.


SCHEMA = {
    "PLUGIN_ACTIVATE": {"Implements": ["NetworkDriver", "IpamDriver"]},
    "SUCCESS": {}
}

# Routes are either given a RouteType of 0 and a value for NextHop;
# or, a RouteType of 1 and no value for NextHop, meaning a connected route.
ROUTE_TYPE = {
    "NEXTHOP": 0,
    "CONNECTED": 1
}

PROTOCOLS = {
    1: 'icmp',
    6: 'tcp',
    17: 'udp'
}

NET_NAME_PREFIX = 'kuryr-net-'
NEUTRON_ID_LH_OPTION = 'kuryr.net.uuid.lh'
NEUTRON_ID_UH_OPTION = 'kuryr.net.uuid.uh'

DOCKER_EXPOSED_PORTS_OPTION = 'com.docker.network.endpoint.exposedports'
KURYR_EXISTING_NEUTRON_NET = 'kuryr.net.existing'
NETWORK_GATEWAY_OPTIONS = 'com.docker.network.gateway'
NETWORK_GENERIC_OPTIONS = 'com.docker.network.generic'
NEUTRON_NAME_OPTION = 'neutron.net.name'
NEUTRON_POOL_NAME_OPTION = 'neutron.pool.name'
NEUTRON_UUID_OPTION = 'neutron.net.uuid'
REQUEST_ADDRESS_TYPE = 'RequestAddressType'
