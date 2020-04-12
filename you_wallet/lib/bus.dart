
//全局事件总线
//对于简单的app，事件总线已经足够满足需求，引入全局状态管理会增加负担

//事件总线通常实现了订阅者模式，订阅者模式包含发布者和订阅者两种角色，可以通过事件总线来触发事件和监听事件，

//Dart中实现单例模式的标准做法就是使用static变量+工厂构造函数的方式，这样就可以保证new EventBus()始终返回都是同一个实例，读者应该理解并掌握这种方法。

import 'package:event_bus/event_bus.dart';
/// 创建EventBus
EventBus eventBus = EventBus();


class EventAddToken {
  Map token = null;
  EventAddToken(this.token);
}

class WalletChangeEvent{
  String address = null;
  WalletChangeEvent(this.address);
}

/// tab页面切换通知
class TabChangeEvent{
  int index = 0;
  TabChangeEvent(this.index);
}

/// 交易历史记录操作结果通知
class TransferDoneEvent{
  String res = '';
  TransferDoneEvent(this.res);
}

/// tab切换时候的事件通知
class CustomTabChangeEvent{
  String res = '';
  CustomTabChangeEvent(this.res);
}

/// 挂单成功通知
class OrderSuccessEvent{
  OrderSuccessEvent();
}

/// 交易深度列表刷新通知
class UpdateTeadeDeepEvent{
  UpdateTeadeDeepEvent();
}

/// 交易历史列表刷新事件
class UpdateOrderListEvent{
  UpdateOrderListEvent();
}

/// 事件钩子，订单列表准备刷新
class TransferUpdateStartEvent{
  TransferUpdateStartEvent();
}

/// 事件钩子，订单列表准备刷新
//class Event{
//  TransferUpdateStartEvent();
//}