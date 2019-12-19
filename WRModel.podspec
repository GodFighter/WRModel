Pod::Spec.new do |s|
    s.name         = 'WRModel'
    s.version      = "0.0.7"
    s.summary      = 'JSON转模型，模型保存工具类'
    s.description  = 'JSON转模型，模型转JSON，模型保存'
    s.homepage     = 'https://github.com/GodFighter/WRModel'
    s.license      = 'MIT'
    s.author       = { 'Leo Xiang' => 'xianghui_ios@163.com' }
    s.source       = { :git => 'https://github.com/GodFighter/WRModel.git', :tag => s.version, :submodules => true }
    s.ios.deployment_target = '9.0'
    s.frameworks   = 'UIKit','Foundation'
    s.social_media_url = 'http://weibo.com/huigedang/home?wvr=5&lf=reg'
    s.requires_arc = true
    s.ios.deployment_target = '9.0'
    s.swift_version = '5.0'

    s.subspec 'WRModel' do |ss|
        ss.source_files = 'WRModel/*.swift'
    end

    s.dependency 'FMDB'
    s.dependency 'KakaJSON', '1.1.1'

end
