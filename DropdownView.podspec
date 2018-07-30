#
# Be sure to run `pod lib lint DropdownView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DropdownView'
  s.version          = '0.1.0'
  s.summary          = 'DropdownView is a generic dropdown control.'
  s.swift_version    = '3.2'

  s.description      = <<-DESC
    DropdownView is a generic dropdown control that you can use and adapt
    to your needs. It contains the basic use case of a dropdown, allowing you to feed the data by using data source and delegate as you would with a UITableView.
                       DESC

  s.homepage         = 'https://github.com/Prismik/DropdownView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Prismik' => 'francis.beauchampsc@gmail.com' }
  s.source           = { :git => 'https://github.com/Prismik/DropdownView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DropdownView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DropdownView' => ['DropdownView/Assets/*.png']
  # }
end
