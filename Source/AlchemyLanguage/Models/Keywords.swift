/**
 * Copyright IBM Corporation 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import Freddy

/**
 
 **Keywords**
 
 Returned by the AlchemyLanguage service.
 
 */
extension AlchemyLanguageV1 {
    public struct Keywords: JSONDecodable {
        public let totalTransactions: Int?
        public let language: String?
        public let url: String?
        public let keywords: [Keyword]?
        public let text: String?
        
        public init(json: JSON) throws {
            totalTransactions = try Int(json.string("totalTransactions"))
            language = try json.string("language")
            url = try json.string("url")
            keywords = try json.arrayOf("keywords", type: Keyword.init)
            text = try json.string("text")
        }
    }
}
