import Foundation
import ObjectMapper

enum JobState : Int
{
case Nonexistent = 0
case Queuing = 1
case Working = 2
case Done = 3
case Failed = 4
case Timeout = 5

}


