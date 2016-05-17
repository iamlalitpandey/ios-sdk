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
 
 **Entity**
 
 Returned by the AlchemyLanguage & AlchemyDataNews services.
 
 */
extension AlchemyLanguageV1 {
    public struct Entity: JSONDecodable {
        /** how often this entity is seen */
        public let count: Int?
        /** disambiguation information for the detected entity (sent only if disambiguation occurred) */
        public let disambiguated: DisambiguatedLinks?
        /** see **KnowledgeGraph** */
        public let knowledgeGraph: KnowledgeGraph?
        /** example usage of our keyword */
        public let quotations: [Quotation]?
        /** relevance to content */
        public let relevance: Double?
        /** sentiment concerning keyword */
        public let sentiment: Sentiment?
        /** surrounding text */
        public let text: String?
        /** Classification */
        public let type: String?
        
        public init(json: JSON) throws {
            count = try Int(json.string("count"))
            disambiguated = try json.decode("disambiguated", type: DisambiguatedLinks.init)
            knowledgeGraph = try json.decode("knowledgeGraph", type: KnowledgeGraph.init)
            quotations = try json.arrayOf("quotations", type: Quotation.init)
            relevance = try Double(json.string("relevance"))
            sentiment = try json.decode("sentiment", type: Sentiment.init)
            text = try json.string("text")
            type = try json.string("type")
        }
    }
}
