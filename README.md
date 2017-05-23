-  ***HandyJSON介绍***

首先说一下比较流行的`SwiftyJSON`库，主要是基于对iOS原生`JSONSerialization`类的封装。虽然用起来也比较顺手，但它不支持json和model转换，并且还需要一层一层的进行取值（json["akey"]["bkey"]["ckey"].stringValue），所以很容易出现由于key写错了而产生的一系列bug。与`SwiftyJSON`相比`HandyJson`更贴近于实战。

 `HandyJson` 是阿里巴巴开源的一个用于Swift语言中的JSON序列化/反序列化库，可以很方便进行json与model的转换，以及常用的字典与模型的互相转换。

- ***HandyJSON特点***

它支持纯swift类，使用也简单。它反序列化时(把JSON转换为Model)不要求Model从`NSObject`继承(因为它不是基于`KVC`机制)，也不要求你为Model定义一个`Mapping`函数。只要你定义好Model类，声明它服从`HandyJSON`协议，`HandyJSON`就能自行以各个属性的属性名为Key，从JSON串中解析值。
[HandyJSON设计原理](http://www.cocoachina.com/swift/20161109/18010.html)

- ***HandyJSON用法***

1.与Alamofire结合使用
```
/// 结构体model 来接收得到的jsonString
struct responseModel: HandyJSON {

    var data:[TagModel]?
    var error: Int!
}
struct TagModel: HandyJSON {

    var nickname: String?
    var vertical_src: String?
    var ranktype: String?
    var room_src: String?
    var cate_id: Int?
}
extension TestController {

    fileprivate func getData() {

        let recommend_collectionurl = "http://capi.douyucdn.cn/api/v1/getbigDataRoom?aid=ios&client_sys=ios&time=1468636740&token=30890623_1b036814902f6451&auth=7d7026a323e09dd55c71ca215fc9d4b2"

        Alamofire.request(recommend_collectionurl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in

            if response.result.isSuccess {

                if let jsonString = response.result.value {

                    /// json转model
                    /// 写法一：responseModel.deserialize(from: jsonString)
                    /// 写法二：用JSONDeserializer<T>
                    if let responseModel = JSONDeserializer<responseModel>.deserializeFrom(json: jsonString) {

                        /// model转json 为了方便在控制台查看
                        print(responseModel.toJSONString(prettyPrint: true)!)

                        /// 遍历responseModel.data
                        responseModel.data?.forEach({ (model) in
                            print(model.nickname!);
                        })
                        
                    }
                }
            }
        }
    }
}
```
2.反序列化与序列化
```
class TestModel: HandyJSON {

    var age: Int?
    var name: String!
    var sex: String?

    required init(){}
}
extension TestController {

    /// 反序列化
    fileprivate func test1() {

        let jsonString = "{\"age\":24,\"name\":\"Micheal\",\"sex\":\"男\"}"
        guard let model = TestModel.deserialize(from: jsonString) else {return}

        print(model.name)/// Micheal
        print(model.age!)/// 24
        print(model.sex!)/// 男
    }

    /// 序列化
    fileprivate func test2() {

        let model = TestModel()
        model.name = "Mike"
        model.age = 24
        model.sex = "男"

        print(model.toJSON()!)/// 输出格式为 ["age": Optional(24), "name": Mike, "sex": Optional("男")]
        print(model.toJSONString()!)/// 输出格式为 {"age":24,"name":"Mike","sex":"男"}
        print(model.toJSONString(prettyPrint: true)!)
        // 输出格式为
        /*
        {
            "age" : 24,
            "name" : "Mike",
            "sex" : "男"
        }
         */
    }
}
```
3.支持自定义映射关系，或者自定义解析过程
```
class Cat3: HandyJSON {

    var id: Int64!
    var name: String!
    var parent: (String, String)? // 元祖类型

    required init() {}

    /// 实现一个可选的mapping函数，在里边实现NSString值(HandyJSON会把对应的JSON字段转
     换为NSString)转换为你需要的字段类型

    public func mapping(mapper: HelpingMapper) {

        // 将json中的cat_id这个key 转换为id 属性

        // 写法一 mapper <<< self.id <-- "cat_id"
        // 写法二
        mapper.specify(property: &id, name: "cat_id")

        mapper <<<
            self.parent <-- TransformOf<(String, String), String>.init(fromJSON: { (rawString) -> (String, String)? in
                if let parentNames = rawString?.characters.split(separator: "/").map(String.init) {
                    return (parentNames[0], parentNames[1])
                }
                return nil
            }, toJSON: { (tuple) -> String? in
                if let _tuple = tuple {
                    return "\(_tuple.0)/\(_tuple.1)"
                }
                return nil
            })
    }
}
extension TestController {

    fileprivate func test10() {

        let jsonString = "{\"cat_id\":12345,\"name\":\"Kitty\",\"parent\":\"Tom/Lily\"}"
        if let cat = Cat3.deserialize(from: jsonString) {
            print(cat.id)
            print(cat.parent!)
        }
    }
}
```
通过自定义映射可以将服务器返回的key随意换成自己想用的属性。比如例子中服务端返回的`cat_id`通过映射就成功转换成了`id`。
**更多用法**请下载[demo](https://github.com/Mikelulu/HandyJSONDemo)查看
