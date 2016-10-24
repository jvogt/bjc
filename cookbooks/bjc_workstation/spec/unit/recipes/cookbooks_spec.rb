#
# Cookbook Name:: bjc_workstation
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

home = Dir.home

describe 'bjc_workstation::cookbooks' do
  context 'When all attributes are default, on Windows Server 2012R2 platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.normal['bjc_workstation']['cookbooks'] = ['bass_web', 'site-config', 'bjc-ecommerce', 'bjc_bass']
      end.converge(described_recipe)
    end

    it 'creates the cookbooks directory' do
      expect(chef_run).to create_directory("#{home}/cookbooks")
    end

    it 'downloads the payload cookbooks' do
      expect(chef_run).to create_remote_file("#{home}/cookbooks/bass_web.zip")
      expect(chef_run).to create_remote_file("#{home}/cookbooks/site-config.zip")
      expect(chef_run).to create_remote_file("#{home}/cookbooks/bjc-ecommerce.zip")
      expect(chef_run).to create_remote_file("#{home}/cookbooks/bjc_bass.zip")
    end

    it 'creates the .kitchen.yml file for site-config' do
      expect(chef_run).to render_file("#{home}/cookbooks/site-config/.kitchen.yml").with_content('sg-2560a741')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
