# Copyright 2014 SUSE
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

haproxy_loadbalancer "ceilometer-api" do
  address "0.0.0.0"
  port node[:ceilometer][:api][:port]
  use_ssl false
  servers CrowbarPacemakerHelper.haproxy_servers_for_service(node, "ceilometer", "ceilometer-server", "api")
  action :nothing
end.run_action(:create)

service_name = "ceilometer-api-service"

pacemaker_primitive service_name do
  agent node[:ceilometer][:ha][:api][:agent]
  op    node[:ceilometer][:ha][:api][:op]
  action [ :create, :start ]
  retries 1
  retry_delay 5
end

pacemaker_clone "clone-#{service_name}" do
  rsc service_name
  action :create
end
