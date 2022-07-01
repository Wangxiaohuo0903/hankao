import Foundation
import ObjectMapper

class ZhuhaiInfo : Mappable
{
var NativeName : String?

var Age : String?

var SchoolGrade : String?

var SchoolName : String?

var Mentor : String?

var PhoneNumber : String?

var QQ : String?

var Area : String?

var Index : String?

var Avatar : [Byte]?

var AvatarUrl : String?

var AuditionSum : Int?

var Day21Info : String?

required init?(map: Map)
{
}

func setDefault(){
    self.NativeName = ""
    self.Age = ""
    self.SchoolGrade = ""
    self.SchoolName = ""
    self.Mentor = ""
    self.PhoneNumber = ""
    self.QQ = ""
    self.Area = ""
    self.Index = ""
    self.Avatar = []
    self.AvatarUrl = ""
    self.AuditionSum = 0
    self.Day21Info = ""
}

func mapping(map: Map)
{
NativeName <- map["nativeName"]
Age <- map["age"]
SchoolGrade <- map["schoolGrade"]
SchoolName <- map["schoolName"]
Mentor <- map["mentor"]
PhoneNumber <- map["phoneNumber"]
QQ <- map["qq"]
Area <- map["area"]
Index <- map["index"]
Avatar <- map["avatar"]
AvatarUrl <- map["avatarUrl"]
AuditionSum <- map["auditionSum"]
Day21Info <- map["day21Info"]
}
}

