# API
说明:
1. 接口中标名 W 的，表示该操作会有写链操作,需要对交易进行签名，消耗一定的gas
2. 接口中标名 R 的，表示该操作不会有写链操作，不需要对交易进行签名，也不会消耗gas
## 结构体
### OrderSignature
```
/* 交易签名数据
 * config: 包含签名v和签名方法（各占以1个字节, 其它字节缺省）
 * r: 签名r
 * s: 签名s
 * */
struct OrderSignature {
    bytes32 config;
    bytes32 r;
    bytes32 s;
}
```
### OrderParam
```
/* 订单参数
 * trader: taker 地址
 * baseTokenAmount: 交易token的数量
 * quoteTokenAmount: 报价token的数量
 * gasTokenAmount: 交易费用token的数量，一般默认0
 * data: 交易参数的设置, 包含hydro版本号、交易买卖标志等, 生成方式参见接口getConfigData
 * signature: 交易签名数据, 包含签名的vrs, 以及签名方法, 生成方式参见接口 getConfigSignature
 */
struct OrderParam {
    address trader;
    uint256 baseTokenAmount;
    uint256 quoteTokenAmount;
    uint256 gasTokenAmount;
    bytes32 data;
    OrderSignature signature;
}
```
## takeOrder
```
/* 发起订单 - W
 * takerOrderParam: 订单参数
 * orderAddressSet: 订单地址集合
 * */
function takeOrder(OrderParam taker, OrderAddressSet orderAddressSet);

```
## getBQODHash
```
/* 获取订单相关hash值 - R
 * orderParam: 订单参数
 * orderAddressSet: 订单地址集合
 *
 * 返回值
 * bq_hash: base-token/quote-token buy  哈希值
 * sq_hash: base-token/quote-token sell 哈希值
 * od_hash: 订单哈希值
 *
 * M 20200328
 * */
function getBQODHash(OrderParam orderParam, OrderAddressSet orderAddressSet);
```