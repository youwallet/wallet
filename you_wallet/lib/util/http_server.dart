
import 'package:dio/dio.dart';
import 'package:youwallet/global.dart';

class Http{
  static Http instance;
  static String token;
  static Dio _dio;
  BaseOptions _options;

  static Http getInstance(){
    print("getInstance");
    if(instance == null){
      instance  = new Http();
    }
  }

  // http类的构造函数
  Http(){

    // 初始化 Options
     _options =new BaseOptions(
        baseUrl: Global.getBaseUrl(),
//        connectTimeout: _config.connectTimeout,
//        receiveTimeout: _config.receiveTimeout,
        headers: {}
    );

    _dio = new Dio(_options);

    _dio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) async {
          // Do something before request is sent
          return options; //continue
          // If you want to resolve the request with some custom data，
          // you can return a `Response` object or return `dio.resolve(data)`.
          // If you want to reject the request with a error message,
          // you can return a `DioError` object or return `dio.reject(errMsg)`
        },
        onResponse:(Response response) async {
          // Do something with response data
          return response; // continue
        },
        onError: (DioError e) async {
          // Do something with response error
          return  e;//continue
        }
    ));

  }



  // get 请求封装
  get(url,{ options, cancelToken}) async {
    print('get:::url：$url ');
    Response response;
    try{
      response = await _dio.get(
          url,
          cancelToken:cancelToken
      );
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return response.data;
  }

  // post请求封装
  post(url,{ options, cancelToken, data=null}) async {
    print('post请求::: url：$url ,body: $data');
    Response response;

    try{
      response = await _dio.post(
          url,
          data:data !=null ? data : {},
          cancelToken:cancelToken
      );
      print(response);
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return response.data;
  }
}
