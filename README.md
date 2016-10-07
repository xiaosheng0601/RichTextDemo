>前言:最近帮公司的一名程序员搞一个项目的收尾工作,差一个富文本编辑器功能未实现,时间紧迫,调研了下网上的解决方法均较为繁琐. 不得已找了个别门来实现该问题,且看下文

* 需要实现的效果

![需要实现的效果](http://upload-images.jianshu.io/upload_images/1694866-a5e800a1bf59e39b.gif?imageMogr2/auto-orient/strip)


* 解决思路
>采用webview加载一个本地html文件,该html内部编写好js方法用于与oc相互调用 最终输出该富文本字符串传输给服务器

* 为什么选择这样的方式
> 服务端要求我最终返回的数据格式为:
```html
{
	@"Id":"当时新建模板这个不传，更新模板必须传",
	@"title":"模板标题",
	@"text":"<p dir="ltr">测试文字</p>
![](http://pic.baikemy.net/apps/kanghubang/486/3486/1457968280769.jpg)<p>![](http://pic.baikemy.net/apps/kanghubang/486/3486/1457968327238.amr@type=1@duration=1852)<p>",
	@"sendstr":"22372447516929 如果模板要保存同时发送给患者，这个值必须传，可以多个患者发送患者id以逗号隔开"
	@"1457968280769.jpg":
	@"文件名":"BACES64 数据 这个是多个图片或语音一起上传"
}
```
其中text字段即为富文本字段.
同时又需要编辑已有文本等功能.倘若用原生代码写较为复杂,最终选择了使用本地html代码实现

------------
* 解决步骤
新建一个richTextEditor.html文件
1.页面设计

```html
/*界面不要太简单 一个简单的输入框*/
 <style>
    img 
    {
      display: block;
      width: 100%;
      margin-top: 10px;
      margin-bottom: 10px;
      }
    [contenteditable=true]:empty:before
    {
      content: attr(placeholder);
      color: #a6a6a6;
    }
    #content 
    {
      padding: 10px 0;
      font-family:Helvetica;
      -webkit-tap-highlight-color: rgba(0,0,0,0);
      min-height:100px;
     }
  
<div id="content" contenteditable="true" onmouseup="saveSelection();" onkeyup="saveSelection();" onfocus="restoreSelection();" placeholder="轻触屏幕开始编辑正文" ></div>
```
 
2.js方法设计
* 插入图片

```

 function insertImage(imageName, imagePath)
  {
    restoreSelection();
    var imageElement = document.createElement('img');
    var breakElement = document.createElement('div');
    imageElement.setAttribute('src', imagePath);
    imageElement.setAttribute('id', imageName);
    breakElement.innerHTML = "<br>";
    editableContent.appendChild(imageElement);
    editableContent.appendChild(breakElement);
  }

  function updateImageURL(imageName, imageURL) {
    var selectedElement = document.getElementById(imageName);
    selectedElement.setAttribute('src', imageURL);
  }
```
* 获取html代码

```

function placeHTMLToEditor(html)
{
    editableContent.innerHTML = html;
}
```

4.oc与js相互调用
* oc端实例一个webview加载该html和一个按钮用于添加图片

```
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64+50, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - 50)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *indexFileURL = [bundle URLForResource:@"richTextEditor" withExtension:@"html"];

    [self.webView setKeyboardDisplayRequiresUserAction:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
```
* 添加完图片后与html对接

```
  //以时间戳重命名图片
    NSString *imageName = [NSString stringWithFormat:@"iOS%@.jpg", [self stringFromDate:[NSDate date]]];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSInteger userid = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]] integerValue];
    NSString *url = [NSString stringWithFormat:@"http://pic.baikemy.net/apps/kanghubang/%@/%@/%@",[NSString stringWithFormat:@"%ld",userid%1000],[NSString stringWithFormat:@"%ld",(long)userid ],imageName];
    
    NSString *script = [NSString stringWithFormat:@"window.insertImage('%@', '%@')", url, imagePath];
    NSDictionary *dic = @{@"url":url,@"image":image,@"name":imageName};
    [_imageArr addObject:dic];//全局数组用于保存加上的图片
    [self.webView stringByEvaluatingJavaScriptFromString:script];
```
* 编辑完成后拿出html代码

```
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').innerHTML"];
```

* 编辑服务器中的富文本

```
      NSString *place = [NSString stringWithFormat:@"window.placeHTMLToEditor('%@')",self.inHtmlString];
      [webView stringByEvaluatingJavaScriptFromString:place];
```

5.与服务端对接
此时我们取出的富文本如下:

```
企鹅的时候要[站外图片上传中……(4)]<div>阿空间里发红包啦？我</div>[站外图片上传中……(5)]<div><br></div>
```
其中id部分为我处理的特殊部分 

处理方法如下
```
-(NSString *)changeString:(NSString *)str
{    
    NSMutableArray * marr = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@"\""]];
    
    for (int i = 0; i < marr.count; i++)
    {
        NSString * subStr = marr[i];
        if ([subStr hasPrefix:@"/var"] || [subStr hasPrefix:@" id="])
        {
            [marr removeObject:subStr];
            i --;
        }
    }
    NSString * newStr = [marr componentsJoinedByString:@"\""];
    return newStr;
}

```
至此可实现一个富文本编辑器的新增与编辑.
* Demo --- 需要请留言
