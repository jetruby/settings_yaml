require 'spec_helper'
require 'settings_yaml'
# require 'yaml'

RSpec.describe SettingsYaml, type: :model do
  before { stub_const 'Rails', double(env: 'test', root: gem_root) }
  let(:gem_root) { @gem_root || Pathname.new(File.expand_path '../..', __FILE__) }
  subject { described_class.new.load! }

  it { is_expected.to eql Hashie::Mash.new }

  context 'when settings.yml file exists' do
    around do |example|
      within_construct do |construct|
        @construct = construct

        construct.directory 'config' do |directory|
          directory.file 'settings.yml', yaml_content

          example.run
        end
      end
    end
    let(:construct) { @construct }
    let(:gem_root) { construct }
    let(:settings) { {} }
    let(:yaml_content) { settings.deep_stringify_keys.to_yaml }

    it { is_expected.to eql Hashie::Mash.new }

    context 'with global section' do
      let(:settings) { {global: {one: 1, two: {three: {four: '4'}}}} }

      it 'reads it into settings' do
        expect(subject.one).to eql 1
        expect(subject.two.three.four).to eql '4'
      end

      context 'and current environment section' do
        let :settings do
          {
            global: {two: {three: {four: '4'}}},
            test: {seven: {eight: 8}}
          }
        end

        it 'reads both sections' do
          expect(subject.two.three.four).to eql '4'
          expect(subject.seven.eight).to eql 8
        end

        context 'and current environment settings conflict with global settings' do
          let :settings do
            {
              global: {one: 1, two: {three: {four: 4}}},
              test: {one: 6, two: {three: {four: '7'}}}
            }
          end

          it 'gives priority to current environment settings' do
            expect(subject.one).to eql 6
            expect(subject.two.three.four).to eql '7'
          end

          context 'and settings.local.yml file exists' do
            before do
              construct.directory('config') do |directory|
                directory.file 'settings.local.yml', local_settings.deep_stringify_keys.to_yaml
              end
            end
            let(:local_settings) { {} }

            context 'with global section' do
              let(:local_settings) { {global: {nine: 9}} }

              it 'reads local settings' do
                expect(subject.nine).to eq 9
              end

              context 'and it has a setting that conflicts with main setting' do
                let(:local_settings) { {global: {one: 10}} }

                it 'overrides main setting' do
                  expect(subject.one).to eql 10
                end
              end

              context 'and there is a section for current environment' do
                let(:local_settings) { {test: {ten: 10}} }

                it 'reads settings for current environment' do
                  expect(subject.ten).to eql 10
                end

                context 'and it conflicts with main file' do
                  let(:local_settings) { {global: {one: 11, two: {three: 3}}, test: {seven: 777}} }

                  it 'overrides main file' do
                    expect(subject.one).to eql 11
                    expect(subject.two.three).to eql 3
                    expect(subject.seven).to eql 777
                  end
                end
              end
            end
          end
        end
      end

      context 'when settings file contains ERB' do
        let :yaml_content do
          <<-YAML
            global:
              one: <%= 12 %>
          YAML
        end

        it 'parses ERB' do
          expect(subject.one).to eql 12
        end
      end
    end

    context 'with current environment section' do
      let(:settings) { {test: {six: 6, seven: {eight: 8}}} }

      it 'reads environment section into settings' do
        expect(subject.six).to eql 6
        expect(subject.seven.eight).to eql 8
      end
    end

    context 'with some other top level section' do
      let(:settings) { {other: {something: '123'}} }

      it 'ignores it' do
        expect(subject).to_not have_key 'something'
        expect(subject).to_not have_key 'other'
      end
    end
  end
end
