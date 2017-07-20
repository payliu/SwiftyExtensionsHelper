Pod::Spec.new do |s|
  s.name     = 'SwiftyExtensionsHelper'
  s.version  = '0.0.1'
  s.license  = 'MIT License'
  s.summary  = 'A Extensions Library of Swift'
  s.description  = <<-DESC
                   SwiftyExtensionsHelper is a Library contain many helpful Extensions.
                   To Exned Cocoa Framework or some popular Framework.
                   Jusy use specified extensions you need.

                   DESC
  s.homepage = 'https://github.com/payliu/SwiftyExtensionsHelper'
  s.author   = { 'Pay Liu'           => 'payliu@gmail.com',
                 'Josh'              => 'josh@octalord.com' }

  s.source   = { :git => 'https://github.com/payliu/SwiftyExtensionsHelper.git', :tag => '0.0.1' }

  s.ios.deployment_target   = '10.0'

  # https://guides.cocoapods.org/syntax/podspec.html#frameworks
  # s.frameworks = 'Foundation'

  # extensions group
  s.subspec 'Extensions' do |extensions|
    extensions.source_files = 'src/Extensions'

    # sub group of extensions group.
    extensions.subspec 'UISplitViewController' do |uisplitviewcontroller|
      uisplitviewcontroller.dependency 'SwiftyExtensionsHelper/UISplitViewController+ToggleMasterView'
    end

  end


  # individual extension
  # Definition

  #UISplitViewController
  s.subspec 'UISplitViewController+ToggleMasterView' do |uisplitviewcontroller_togglemasterview|
    uisplitviewcontroller_togglemasterview.source_files = 'src/Extensions/UISplitViewController/UISplitViewController+ToggleMasterView'
  end

end
