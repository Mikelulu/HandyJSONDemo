//
//  TestController.swift
//  HandyJSONDemo
//
//  Created by admin on 2017/5/22.
//  Copyright © 2017年 LK. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON
import Foundation

public class TestController: UIViewController {


    deinit {
        print((NSStringFromClass(type(of: self)) + "释放"))
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        /// 
        let button = UIButton()
        view.addSubview(button);
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        button.center = view.center
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("dissMiss", for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)


        // MARK: - 用法介绍

        test1()
        test2()
        test3()
        test4()


        test7()
        test8()
        test9()

        test10()
        test11()


        getData()
    }

    @objc public func back()  {

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - 用法一： 反序列化与序列化
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

// MARK: - 用法二： 支持struct
struct BaseModel: HandyJSON {

    var name: String!
    var mathScore: CGFloat!
    var englishScore: CGFloat!
}
extension TestController {

    fileprivate func test3() {

        let jsonString = "{\"name\":\"Mike\",\"mathScore\":98,\"englishScore\":80}"
        guard BaseModel.deserialize(from: jsonString) != nil else {return}

    }
}

// MARK: - 用法二： 支持值类型的enum
enum AnimalType: String, HandyJSONEnum {
    case Cat = "cat"
    case Dog = "dog"
    case Bird = "bird"
}
struct Animal: HandyJSON {
    var name: String?
    var type: AnimalType?
}
extension TestController {
    fileprivate func test4() {

        let jsonString = "{\"type\":\"cat\",\"name\":\"Tom\"}"

        if let animal = Animal.deserialize(from: jsonString) {
            print(animal.type?.rawValue ?? "")
        }
    }
}
// MARK: - 用法三： 支持这些非基础类型，包括嵌套结构
class BasicTypes: HandyJSON {
    var bool: Bool = true
    var intOptional: Int?
    var doubleImplicitlyUnwrapped: Double!
    var anyObjectOptional: Any?

    var arrayInt: Array<Int> = []
    var arrayStringOptional: Array<String>?
    var setInt: Set<Int>?
    var dictAnyObject: Dictionary<String, Any> = [:]

    var nsNumber = 2
    var nsString: NSString?

    required init() {}
}
extension TestController {

    fileprivate func test5() {
        let object = BasicTypes()
        object.intOptional = 1
        object.doubleImplicitlyUnwrapped = 1.1
        object.anyObjectOptional = "StringValue"
        object.arrayInt = [1, 2]
        object.arrayStringOptional = ["a", "b"]
        object.setInt = [1, 2]
        object.dictAnyObject = ["key1": 1, "key2": "stringValue"]
        object.nsNumber = 2
        object.nsString = "nsStringValue"

        let jsonString = object.toJSONString()!
        
        if let object = BasicTypes.deserialize(from: jsonString) {
            // ...
        }
    }
}
// MARK: - 用法四： 可以指定解析路径
class Cat: HandyJSON {
    var id: Int64!
    var name: String!

    required init() {}
}
extension TestController {

    fileprivate func test6() {

        let jsonString = "{\"code\":200,\"msg\":\"success\",\"data\":{\"cat\":{\"id\":12345,\"name\":\"Kitty\"}}}"

        if let cat = Cat.deserialize(from: jsonString, designatedPath: "data.cat") {
            print(cat.name)
        }
    }
}
// MARK: - 用法五： 组合对象
// 注意，如果Model的属性不是基本类型或集合类型，那么它必须是一个服从HandyJSON协议的类型。

//如果是泛型集合类型，那么要求泛型实参是基本类型或者服从HandyJSON协议的类型。
class Component: HandyJSON {
    var aInt: Int?
    var aString: String?

    required init() {}
}

class Composition: HandyJSON {
    var aInt: Int?
    var comp1: Component?
    var comp2: Component?

    required init() {}
}
extension TestController {

    fileprivate func test7() {

        let jsonString = "{\"num\":12345,\"comp1\":{\"aInt\":1,\"aString\":\"aaaaa\"},\"comp2\":{\"aInt\":2,\"aString\":\"bbbbb\"}}"

        if let composition = Composition.deserialize(from: jsonString) {
            print(composition.comp1!.aInt!)
            print(composition.comp2!.aString!)
        }
    }
}
// MARK: - 用法六： 如果子类要支持反序列化，那么要求父类也服从HandyJSON协议。
class Animal1: HandyJSON {
    var id: Int?
    var color: String?

    required init() {}
}

class Cat1: Animal1 {
    var name: String?

    required init() {}
}
extension TestController {

    fileprivate func test8() {

        let jsonString = "{\"id\":12345,\"color\":\"black\",\"name\":\"cat\"}"

        if let cat = Cat1.deserialize(from: jsonString) {
            print(cat)
        }
    }
}
// MARK: - 用法七： 如果JSON的第一层表达的是数组，可以转化它到一个Model数组
class Cat2: HandyJSON {

    var name: String?
    var id: String?

    public required init() {}
}
extension TestController {

    fileprivate func test9() {

        let jsonArrString: String = "[{\"name\":\"Bob\",\"id\":\"1\"}, {\"name\":\"Lily\",\"id\":\"2\"}, {\"name\":\"Lucy\",\"id\":\"3\"}]"

        guard let cats = [Cat2].deserialize(from: jsonArrString) else { return }

        cats.forEach { (cat) in
            print(cat!.name!)
            print(cat!.id!)
        }
    }
}
// MARK: - 用法八： HandyJSON支持自定义映射关系，或者自定义解析过程
class Cat3: HandyJSON {

    var id: Int64!
    var name: String!
    var parent: (String, String)? // 元祖类型

    required init() {}

    /// 实现一个可选的mapping函数，在里边实现NSString值(HandyJSON会把对应的JSON字段转换为NSString)转换为你需要的字段类型

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
// MARK: - 用法九： 排除指定属性
//如果在Model中存在因为某些原因不能实现HandyJSON协议的非基本字段，或者不能实现HandyJSONEnum协议的枚举字段，又或者说不希望反序列化影响某个字段，可以在mapping函数中将它排除。如果不这么做，可能会出现未定义的行为。
class NotHandyJSONType {
    var dummy: String?
}

class Cat4: HandyJSON {
    var id: Int64!
    var name: String!
    var notHandyJSONTypeProperty: NotHandyJSONType?
    var basicTypeButNotWantedProperty: String?

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper >>> self.notHandyJSONTypeProperty
        mapper >>> self.basicTypeButNotWantedProperty
    }
}
extension TestController {

    fileprivate func test11() {

        let jsonString = "{\"name\":\"cat\",\"id\":\"12345\"}"

        if let cat = Cat4.deserialize(from: jsonString) {
            print(cat)
        }
    }
}
// MARK: - 与Alamofire结合使用

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
