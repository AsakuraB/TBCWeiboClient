TBCweiboClient
==============

Selfmade weibo client app

注：因新浪App审核需要提供应用商店的下载链接（这个暂时还没有），暂时还无法通过，不能大范围推广使用。so提供测试账号一枚：

账号：tbcweiboclienttest@163.com

密码：asdfghjkl;'

密码即“滑动解锁”，键盘从"A"滑动到回车键即可。

0.9.1 版本更新内容：

Bug fixed.

简介：

1.OAuth2.0认证登录

  1.1 NSUserDefaults保存登录数据
  
  1.2 MBProgressHUD实现提示框
  
2.微博主页显示

  2.1 自定义TableViewCell内容
  
    2.1.1 TQRichTextView实现微博内容图文混排，包含表情、链接、“@XXX”、“#XX#”话题的富文本显示
    
    2.1.2 MJPhotoBrowser实现图片浏览（包括.jpg,.gif等多格式图片显示）
    
    2.1.3 所有图片均采用GCD异步加载数据
    
  2.2 动态调整TableViewCell高度
  
  2.3 MJRefresh实现下拉刷新，上拉加载
  
3.发送、转发微博功能实现

  3.1 WeiboSDK实现发送文字微博，图文微博
  
  3.2 WeiboSDK实现转发微博
  
4.“@我的”消息页面显示

5.“关于作者”页面


以上！
-----------------------------------
SinaWeibo:@IcyJade_White

A growing programmer.
Need for a job opportunity.
Contact me by Weibo or larrylmx@gmail.com.
