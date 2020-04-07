
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:youwallet/global.dart';

class Http{
  static Http instance;
  static String token;
  static Dio _dio;
  BaseOptions _options;

  static Http getInstance(){
    if(instance == null){
      instance  = new Http();
    }
    return instance;
  }

  // http类的构造函数
  // 初始化 Options
  Http(){
     _options =new BaseOptions(
        baseUrl: Global.getBaseUrl(),
//        connectTimeout: _config.connectTimeout,
//        receiveTimeout: _config.receiveTimeout,
        headers: {'Content-Type':'application/json','User-Agent':'youwallet'},
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
  // url还必须有一个默认值
  // 这个跟以太坊进行交互，所有请求的url都是固定的
  // 但是也不能保证后期不会有其他的url进来
  post({url = "", options, cancelToken, params = null}) async {
//    print('post请求::body: $params');
    Response response;
//    params.add('latest');
    print('请求开始======');
    Map data = {
      'jsonrpc': '2.0',
      'method': 'eth_call',
      'id': DateTime.now().millisecondsSinceEpoch,
      'params': [params,'latest']
    };
    print('发送数据准备完毕');
    print(data);
    try{
      response = await _dio.post(
          url,
          data: data,
          cancelToken:cancelToken
      );
      print(response);
      print('请求结束======');
    }on DioError catch(e){
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('post请求发生错误：$e');
      }
    }
    return response.data;
  }
}
