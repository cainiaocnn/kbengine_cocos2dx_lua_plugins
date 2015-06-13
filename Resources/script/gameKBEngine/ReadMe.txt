读取需要按照顺序读取
1:登陆LoginApp 
  1.1 首先和服务器IP地址握手
  1.2 然后请求Loginapp_hello
  1.3 返回Client_onHelloCB
  1.4 判断是不是导入客户端LoginApp
  1.5 请求导入Loginapp_importClientMessages
  1.6 导入协议完毕后允许LoginApp相关操作
 
2:登陆BaseApp
  2.1 
  2.2 
  2.3 
  2.4 
  2.5 
 