require 'rspec'
require 'json'
require 'bosh/template/test'
require 'yaml'
require 'iniparse'
require 'ipaddr'

describe 'garden' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('garden') }
  let(:template) { job.template('config/config.ini') }
  let(:properties) {{}}

  context 'config/config.ini' do
    context 'with defaults' do
      let(:rendered_template) { IniParse.parse(template.render(properties)) }

      it 'binds to a socket' do
        expect(rendered_template['server']['bind-socket']).to eql('/var/vcap/data/garden/garden.sock')
      end

      it 'sets the ip tables bin dir' do
        expect(rendered_template['server']['iptables-bin']).to eql('/var/vcap/packages/iptables/sbin/iptables')
      end

      it 'sets the ip tables restore bin dir' do
        expect(rendered_template['server']['iptables-restore-bin']).to eql('/var/vcap/packages/iptables/sbin/iptables-restore')
      end

      it 'sets the init bin dir' do
        expect(rendered_template['server']['init-bin']).to eql('/var/vcap/data/garden/bin/init')
      end

      it 'sets the default grace time' do
        expect(rendered_template['server']['default-grace-time']).to eql(0)
      end

      it 'sets the image-plugin' do
        expect(rendered_template['server']['image-plugin']).to eql('/var/vcap/packages/grootfs/bin/grootfs')
      end

      it 'sets the image-plugin-extra-arg' do
        expect(rendered_template['server']['image-plugin-extra-arg']).to eql(['"--config"', '/var/vcap/jobs/garden/config/grootfs_config.yml'])
      end

      it 'sets the privileged-image-plugin' do
        expect(rendered_template['server']['privileged-image-plugin']).to eql('/var/vcap/packages/grootfs/bin/grootfs')
      end

      it 'sets the privileged-image-plugin-extra-arg extra arg' do
        expect(rendered_template['server']['privileged-image-plugin-extra-arg']).to eql(['"--config"', '/var/vcap/jobs/garden/config/privileged_grootfs_config.yml'])
      end

      it 'sets the mtu to 0' do
        expect(rendered_template['server']['mtu']).to eql(0)
      end

      it 'sets the apparmor to garden-default' do
        expect(rendered_template['server']['apparmor']).to eql('garden-default')
      end

      it 'sets the log level to info' do
        expect(rendered_template['server']['log-level']).to eql('info')
      end

      it 'sets the default grace time to 0' do
        expect(rendered_template['server']['default-grace-time']).to eql(0)
      end

      it 'sets the default container blockio wait to 0' do
        expect(rendered_template['server']['default-container-blockio-weight']).to eql(0)
      end

      it 'sets the default container rootfs to busybox' do
        expect(rendered_template['server']['default-rootfs']).to eq('/var/vcap/packages/busybox/busybox-1.27.2.tar')
      end

      it 'sets the runtime plugin to 0' do
        expect(rendered_template['server']['runtime-plugin']).to eql('/var/vcap/packages/runc/bin/runc')
      end

      it 'sets the max containers to 250' do
        expect(rendered_template['server']['max-containers']).to eql(250)
      end

      it 'sets the cpu quota per share to 0' do
        expect(rendered_template['server']['cpu-quota-per-share']).to eql(0)
      end

      it 'sets the experimental cpu entitlement per share in percent per share to 0' do
        expect(rendered_template['server']['cpu-entitlement-per-share']).to eql(0)
      end

      it 'sets the enable cpu throttling per share to 0' do
        expect(rendered_template['server']['enable-cpu-throttling']).to eql(false)
      end

      it 'sets the experimental cpu throttling check interval to 15' do
        expect(rendered_template['server']['cpu-throttling-check-interval']).to eql(15)
      end

      it 'sets the network-pool to 10.254.0.0/22' do
        expect(rendered_template['server']['network-pool']).to eql('10.254.0.0/22')
      end

      it 'sets the properties-path' do
        expect(rendered_template['server']['properties-path']).to eql('/var/vcap/data/garden/props.json')
      end

      it 'sets the port-pool-properties-path' do
        expect(rendered_template['server']['port-pool-properties-path']).to eql('/var/vcap/data/garden/port-pool-props.json')
      end      

      it 'sets the time-format' do
        expect(rendered_template['server']['time-format']).to eql('unix-epoch')
      end

    end

    context 'with a listen address' do
      it 'switches to a listen address and port' do
        properties.merge!(
          'garden' => {
            'listen_network' => 'tcp',
            'listen_address' => '127.0.0.1:5555'
          }
        )
        
        rendered_template = IniParse.parse(template.render(properties))
        expect(rendered_template['server']['bind-ip']).to eql('127.0.0.1')
        expect(rendered_template['server']['bind-port']).to eql(5555)
      end

      # it 'throws an exception if the ip is invalid' do
      #   properties.merge!({
      #     'garden' => {
      #       'listen_network' => 'tcp',
      #       'listen_address' => '0.0.0.1:5555'
      #     }
      #   })
        
      #   expect {template.render(properties)}.to raise_error(IPAddr::InvalidAddressError)
      # end
    end
  end
end