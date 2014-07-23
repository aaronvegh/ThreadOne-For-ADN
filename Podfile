# ignore all warnings from all pods
inhibit_all_warnings!

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=0']
        end
    end
end

pod 'AFNetworking', '~>1.0'
pod 'SSKeychain'
pod 'InflectorKit'
pod 'TransformerKit'
pod 'ADNKit'
pod 'SocketRocket'
pod 'OpenSSL'