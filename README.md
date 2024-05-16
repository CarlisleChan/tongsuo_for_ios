# Tongsuo for iOS

- [Tongsuo-8.4.0](https://github.com/Tongsuo-Project/Tongsuo/releases/tag/8.4.0)
- [Tongsuo-curl-v2023.1.6-SM](https://github.com/Tongsuo-Project/curl/releases/tag/v2023.1.6-SM)

## How to build

### For iOS

- Xcode info: Version 11.3.1 (11C504) (for reference only)
- Build dependencies: todo
- Build order: 1.build openssl, 2.build nghttp2, 3.build curl (curl depend openssl and nghttp2)
- only build static library(.a)
- build sh cmd: for example:

```shell
cd tools
sh build-ios-tongsuo-openssl.sh
sh build-ios-tongsuo-nghttp2.sh
sh build-ios-tongsuo-curl.sh
```

## How to use

### For iOS

Copy `lib/libcrypto.a` and `lib/libssl.a` and `lib/libcurl.a` to your project.

Copy `include/openssl` folder and `include/curl` folder to your project.

Add `libcrypto.a` and `libssl.a` and `libcurl.a` to `Frameworks` group and add them to `[Build Phases]  ====> [Link Binary With Libraries]`.

Add openssl include path and curl include path to your `[Build Settings] ====> [User Header Search Paths]`

## More Info

- https://tongsuo-project.github.io/docs/compilation/source-compilation
- https://tongsuo-project.github.io/docs/features/curl
- https://github.com/leenjewel/openssl_for_ios_and_android
- https://github.com/x2on/OpenSSL-for-iPhone