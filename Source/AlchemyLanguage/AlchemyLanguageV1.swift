/**
 * Copyright IBM Corporation 2016
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
import Alamofire
import Freddy

public class AlchemyLanguageV1 {
    
    private let apiKey: String
    
    private let serviceUrl = "https://gateway-a.watsonplatform.net/calls"
    private let errorDomain = "com.watsonplatform.alchemyLanguage"
 
    let unreservedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz" +
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "1234567890-._~")
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func dataToError(data: NSData) -> NSError? {
        do {
            let json = try JSON(data: data)
            let status = try json.string("status")
            let statusInfo = try json.string("statusInfo")
            let userInfo = [
                NSLocalizedFailureReasonErrorKey: status,
                NSLocalizedDescriptionKey: statusInfo
            ]
            return NSError(domain: errorDomain, code: 400, userInfo: userInfo)
        } catch {
            return nil
        }
    }
    
    private func shouldHaveField(field: Bool) -> String {
        if(field == true) {
           return "1"
        } else {
           return "0"
        }
    }
    
    private func buildBody(document: NSURL, html: Bool) throws -> NSData {
        guard let docAsString = try? String(contentsOfURL: document)
            .stringByAddingPercentEncodingWithAllowedCharacters(unreservedCharacters) else {
                let failureReason = "Profile could not be escaped."
                let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                let error = NSError(domain: errorDomain, code: 0, userInfo: userInfo)
                throw error
        }
        let type: String
        if html == true {
            type = "html"
        } else {
            type = "text"
        }
        guard let body = "\(type)=\(docAsString!)".dataUsingEncoding(NSUTF8StringEncoding) else {
            let failureReason = "Profile could not be encoded."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: errorDomain, code: 0, userInfo: userInfo)
            throw error
        }
        return body
    }
    
    public func getAuthorsURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: DocumentAuthors -> Void)
    {
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetAuthors",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentAuthors, NSError>) in
                switch response.result {
                case .Success(let authors): success(authors)
                case .Failure(let error): failure?(error)
                }
        }
        
    }
    
    public func getAuthorsHtml(
        html: NSURL,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: DocumentAuthors -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetAuthors",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentAuthors, NSError>) in
                switch response.result {
                case .Success(let authors): success(authors)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedConceptsURL(
        url: String,
        knowledgeGraph: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: ConceptResponse -> Void)
    {
        let graph = shouldHaveField(knowledgeGraph!)
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRankedConcepts",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json"),
                NSURLQueryItem(name: "linkedData", value: "1"),
                NSURLQueryItem(name: "knowledgeGraph", value: graph)
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<ConceptResponse, NSError>) in
                switch response.result {
                case .Success(let concepts): success(concepts)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedConceptsHtml(
        html: NSURL,
        url: String? = nil,
        knowledgeGraph: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: ConceptResponse -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        queryParams.append(NSURLQueryItem(name: "linkedData", value: "1"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let myGraph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph",
                value: shouldHaveField(myGraph)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRankedConcepts",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<ConceptResponse, NSError>) in
                switch response.result {
                case .Success(let concepts): success(concepts)
                case .Failure(let error): failure?(error)
                }
        }
        
    }
    
    public func getRankedConceptsText(
        text: NSURL,
        knowledgeGraph: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: ConceptResponse -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        queryParams.append(NSURLQueryItem(name: "linkedData", value: "1"))
        if let myGraph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph",
                value: shouldHaveField(myGraph)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetRankedConcepts",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<ConceptResponse, NSError>) in
                switch response.result {
                case .Success(let concepts): success(concepts)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    // TODO: Review this. I don't like how large the signature is
    // TODO: What is 'structuredEntities'? I don't understand what that parameter actually does
    public func getRankedNamedEntitiesURL(
        url: String,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        quotations: Bool? = false,
        structuredEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Entities -> Void)
    {
        let graph = shouldHaveField(knowledgeGraph!)
        let disambiguate = shouldHaveField(disambiguateEntities!)
        let linked = shouldHaveField(linkedData!)
        let coref = shouldHaveField(coreference!)
        let senti = shouldHaveField(sentiment!)
        let quotes = shouldHaveField(quotations!)
        let structEnts = shouldHaveField(structuredEntities!)
        
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRankedNamedEntities",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json"),
                NSURLQueryItem(name: "knowledgeGraph", value: graph),
                NSURLQueryItem(name: "disambiguate", value: disambiguate),
                NSURLQueryItem(name: "linkedData", value: linked),
                NSURLQueryItem(name: "coreference", value: coref),
                NSURLQueryItem(name: "quotations", value: quotes),
                NSURLQueryItem(name: "sentiment", value: senti),
                NSURLQueryItem(name: "structuredEntities", value: structEnts)
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Entities, NSError>) in
                switch response.result {
                case .Success(let entities): success(entities)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedNamedEntitiesHtml(
        html: NSURL,
        url: String?,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        quotations: Bool? = false,
        structuredEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Entities -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let myGraph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph",
                value: shouldHaveField(myGraph)))
        }
        if let disambiguate = disambiguateEntities {
            queryParams.append(NSURLQueryItem(name: "disambiguatedEntities",
                value: shouldHaveField(disambiguate)))
        }
        if let linked = linkedData {
            queryParams.append(NSURLQueryItem(name: "linkedData", value: shouldHaveField(linked)))
        }
        if let coref = coreference {
            queryParams.append(NSURLQueryItem(name: "coreference", value: shouldHaveField(coref)))
        }
        if let quotes = quotations {
            queryParams.append(NSURLQueryItem(name: "quotations", value: shouldHaveField(quotes)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let structEnts = structuredEntities {
            queryParams.append(NSURLQueryItem(name: "structuredEntities",
                value: shouldHaveField(structEnts)))
        }
        
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRankedNamedEntities",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Entities, NSError>) in
                switch response.result {
                case .Success(let entities): success(entities)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedNamedEntitiesHtml(
        text: NSURL,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        quotations: Bool? = false,
        structuredEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Entities -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myGraph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph",
                value: shouldHaveField(myGraph)))
        }
        if let disambiguate = disambiguateEntities {
            queryParams.append(NSURLQueryItem(name: "disambiguatedEntities",
                value: shouldHaveField(disambiguate)))
        }
        if let linked = linkedData {
            queryParams.append(NSURLQueryItem(name: "linkedData", value: shouldHaveField(linked)))
        }
        if let coref = coreference {
            queryParams.append(NSURLQueryItem(name: "coreference", value: shouldHaveField(coref)))
        }
        if let quotes = quotations {
            queryParams.append(NSURLQueryItem(name: "quotations", value: shouldHaveField(quotes)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let structEnts = structuredEntities {
            queryParams.append(NSURLQueryItem(name: "structuredEntities",
                value: shouldHaveField(structEnts)))
        }
        
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetRankedNamedEntities",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Entities, NSError>) in
                switch response.result {
                case .Success(let entities): success(entities)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedKeywordsURL(
        url: String,
        knowledgeGraph: Bool? = false,
        strictMode: Bool? = false,
        sentiment: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Keywords -> Void)
    {
        let graph = shouldHaveField(knowledgeGraph!)
        let senti = shouldHaveField(sentiment!)
        let keywordExtractMode: String
        if strictMode! == true {
            keywordExtractMode = "strict"
        } else {
            keywordExtractMode = "normal"
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRankedKeywords",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json"),
                NSURLQueryItem(name: "knowledgeGraph", value: graph),
                NSURLQueryItem(name: "sentiment", value: senti),
                NSURLQueryItem(name: "keywordExtractMode", value: keywordExtractMode)
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Keywords, NSError>) in
                switch response.result {
                case .Success(let keywords): success(keywords)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedKeywordsHtml(
        html: NSURL,
        url: String? = nil,
        knowledgeGraph: Bool? = false,
        strictMode: Bool? = false,
        sentiment: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Keywords -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let graph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph", value: shouldHaveField(graph)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let keywordExtractMode = strictMode {
            let mode: String
            if keywordExtractMode == true {
                mode = "strict"
            } else {
                mode = "normal"
            }
            queryParams.append(NSURLQueryItem(name: "keywordExtractMode", value: mode))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRankedKeywords",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Keywords, NSError>) in
                switch response.result {
                case .Success(let keywords): success(keywords)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedKeywordsText(
        text: NSURL,
        knowledgeGraph: Bool? = false,
        strictMode: Bool? = false,
        sentiment: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: Keywords -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let graph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph", value: shouldHaveField(graph)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let keywordExtractMode = strictMode {
            let mode: String
            if keywordExtractMode == true {
                mode = "strict"
            } else {
                mode = "normal"
            }
            queryParams.append(NSURLQueryItem(name: "keywordExtractMode", value: mode))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetRankedKeywords",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Keywords, NSError>) in
                switch response.result {
                case .Success(let keywords): success(keywords)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getLanguageURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: Language -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetLanguage",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Language, NSError>) in
                switch response.result {
                case .Success(let language): success(language)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getLanguageText(
        text: NSURL,
        failure: (NSError -> Void)? = nil,
        success: Language -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetLanguage",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Language, NSError>) in
                switch response.result {
                case .Success(let language): success(language)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getMicroformatDataURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: Microformats -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetMicroformatData",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Microformats, NSError>) in
                switch response.result {
                case .Success(let microformats): success(microformats)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    // The fact URL is required here is a bug.
    public func getMicroformatDataHtml(
        html: NSURL,
        url: String? = " ",
        failure: (NSError -> Void)? = nil,
        success: Microformats -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetMicroformatData",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Microformats, NSError>) in
                switch response.result {
                case .Success(let microformats): success(microformats)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getPubDateURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: PublicationResponse -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetPubDate",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<PublicationResponse, NSError>) in
                switch response.result {
                case .Success(let pubResponse): success(pubResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getPubDateHtml(
        html: NSURL,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: PublicationResponse -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetPubDate",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<PublicationResponse, NSError>) in
                switch response.result {
                case .Success(let pubResponse): success(pubResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    // TODO: The HTML and TEXT methods for this
    // TODO: Discuss this. I'm not a huge fan of how huge the signature is
    public func getRelationsURL(
        url: String,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        keywords: Bool? = false,
        entities: Bool? = false,
        requireEntities: Bool? = false,
        sentimentExcludeEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: SAORelations -> Void)
    {
        let graph = shouldHaveField(knowledgeGraph!)
        let disambiguates = shouldHaveField(disambiguateEntities!)
        let linked = shouldHaveField(linkedData!)
        let coref = shouldHaveField(coreference!)
        let senti = shouldHaveField(sentiment!)
        let keyWords = shouldHaveField(keywords!)
        let ents = shouldHaveField(entities!)
        let requireEnts = shouldHaveField(requireEntities!)
        let sentiExEnts = shouldHaveField(sentimentExcludeEntities!)
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRelations",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json"),
                NSURLQueryItem(name: "knowledgeGraph", value: graph),
                NSURLQueryItem(name: "disambiguate", value: disambiguates),
                NSURLQueryItem(name: "linkedData", value: linked),
                NSURLQueryItem(name: "coreference", value: coref),
                NSURLQueryItem(name: "sentiment", value: senti),
                NSURLQueryItem(name: "keywords", value: keyWords),
                NSURLQueryItem(name: "entities", value: ents),
                NSURLQueryItem(name: "requireEntities", value: requireEnts),
                NSURLQueryItem(name: "sentimentExcludeEntities", value: sentiExEnts)
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SAORelations, NSError>) in
                switch response.result {
                case .Success(let relations): success(relations)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRelationsHtml(
        html: NSURL,
        url: String? = nil,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        keywords: Bool? = false,
        entities: Bool? = false,
        requireEntities: Bool? = false,
        sentimentExcludeEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: SAORelations -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let graph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph", value: shouldHaveField(graph)))
        }
        if let disEnts = disambiguateEntities {
            queryParams.append(NSURLQueryItem(name: "disambiguate", value: shouldHaveField(disEnts)))
        }
        if let link = linkedData {
            queryParams.append(NSURLQueryItem(name: "linkedData", value: shouldHaveField(link)))
        }
        if let coref = coreference {
            queryParams.append(NSURLQueryItem(name: "coreference", value: shouldHaveField(coref)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let keyWords = keywords {
            queryParams.append(NSURLQueryItem(name: "keywords", value: shouldHaveField(keyWords)))
        }
        if let ents = entities {
            queryParams.append(NSURLQueryItem(name: "entities", value: shouldHaveField(ents)))
        }
        if let reqEnts = requireEntities {
            queryParams.append(NSURLQueryItem(name: "requireEntities",
                value: shouldHaveField(reqEnts)))
        }
        if let sentiExEnts = sentimentExcludeEntities {
            queryParams.append(NSURLQueryItem(name: "sentimentExcludeEntities",
                value: shouldHaveField(sentiExEnts)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRelations",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SAORelations, NSError>) in
                switch response.result {
                case .Success(let relations): success(relations)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRelationsText(
        text: NSURL,
        knowledgeGraph: Bool? = false,
        disambiguateEntities: Bool? = false,
        linkedData: Bool? = false,
        coreference: Bool? = false,
        sentiment: Bool? = false,
        keywords: Bool? = false,
        entities: Bool? = false,
        requireEntities: Bool? = false,
        sentimentExcludeEntities: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: SAORelations -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let graph = knowledgeGraph {
            queryParams.append(NSURLQueryItem(name: "knowledgeGraph", value: shouldHaveField(graph)))
        }
        if let disEnts = disambiguateEntities {
            queryParams.append(NSURLQueryItem(name: "disambiguate", value: shouldHaveField(disEnts)))
        }
        if let link = linkedData {
            queryParams.append(NSURLQueryItem(name: "linkedData", value: shouldHaveField(link)))
        }
        if let coref = coreference {
            queryParams.append(NSURLQueryItem(name: "coreference", value: shouldHaveField(coref)))
        }
        if let senti = sentiment {
            queryParams.append(NSURLQueryItem(name: "sentiment", value: shouldHaveField(senti)))
        }
        if let keyWords = keywords {
            queryParams.append(NSURLQueryItem(name: "keywords", value: shouldHaveField(keyWords)))
        }
        if let ents = entities {
            queryParams.append(NSURLQueryItem(name: "entities", value: shouldHaveField(ents)))
        }
        if let reqEnts = requireEntities {
            queryParams.append(NSURLQueryItem(name: "requireEntities",
                value: shouldHaveField(reqEnts)))
        }
        if let sentiExEnts = sentimentExcludeEntities {
            queryParams.append(NSURLQueryItem(name: "sentimentExcludeEntities",
                value: shouldHaveField(sentiExEnts)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetRelations",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SAORelations, NSError>) in
                switch response.result {
                case .Success(let relations): success(relations)
                case .Failure(let error): failure?(error)
                }
        }
    }

    
    public func getTextSentimentURL(
    url: String,
    failure: (NSError -> Void)? = nil,
    success: SentimentResponse -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetTextSentiment",
            acceptType: "application/json",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTextSentimentHtml(
        html: NSURL,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: SentimentResponse -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetTextSentiment",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTextSentimentText(
        text: NSURL,
        failure: (NSError -> Void)? = nil,
        success: SentimentResponse -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetTextSentiment",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTargetedSentimentURL(
        target: String,
        url: String,
        failure: (NSError -> Void)? = nil,
        success: SentimentResponse -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetTargetedSentiment",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "target", value: target),
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTargetedSentimentHtml(
        html: NSURL,
        target: String,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: SentimentResponse -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        queryParams.append(NSURLQueryItem(name: "target", value: target))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetTargetedSentiment",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTargetedSentimentText(
        text: NSURL,
        target: String,
        failure: (NSError -> Void)? = nil,
        success: SentimentResponse -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        queryParams.append(NSURLQueryItem(name: "target", value: target))
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetTargetedSentiment",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<SentimentResponse, NSError>) in
                switch response.result {
                case .Success(let sentimentResponse): success(sentimentResponse)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedTaxonomyURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: Taxonomies -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRankedTaxonomy",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Taxonomies, NSError>) in
                switch response.result {
                case .Success(let taxonomies): success(taxonomies)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedTaxonomyHtml(
        html: NSURL,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: Taxonomies -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRankedTaxonomy",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Taxonomies, NSError>) in
                switch response.result {
                case .Success(let taxonomies): success(taxonomies)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRankedTaxonomyText(
        text: NSURL,
        failure: (NSError -> Void)? = nil,
        success: Taxonomies -> Void)
    {
        // construct body
        let body = try? buildBody(text, html: false)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/text/TextGetRankedTaxonomy",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Taxonomies, NSError>) in
                switch response.result {
                case .Success(let taxonomies): success(taxonomies)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRawTextURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: DocumentText -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetRawText",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentText, NSError>) in
                switch response.result {
                case .Success(let docText): success(docText)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getRawTextHtml(
        html: NSURL,
        url: String? = nil,
        failure: (NSError -> Void)? = nil,
        success: DocumentText -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetRawText",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentText, NSError>) in
                switch response.result {
                case .Success(let docText): success(docText)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTextURL(
        url: String,
        useMetadata: Bool? = false,
        extractLinks: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: DocumentText -> Void)
    {
        let metadata = shouldHaveField(useMetadata!)
        let links = shouldHaveField(extractLinks!)
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetText",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json"),
                NSURLQueryItem(name: "useMetadata", value: metadata),
                NSURLQueryItem(name: "extractLinks", value: links)
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentText, NSError>) in
                switch response.result {
                case .Success(let docText): success(docText)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTextHtml(
        html: NSURL,
        url: String? = nil,
        useMetadata: Bool? = false,
        extractLinks: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: DocumentText -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let metadata = useMetadata {
            queryParams.append(NSURLQueryItem(name: "useMetadata", value: shouldHaveField(metadata)))
        }
        if let extract = extractLinks {
            queryParams.append(NSURLQueryItem(name: "extractLinks", value: shouldHaveField(extract)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetText",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentText, NSError>) in
                switch response.result {
                case .Success(let docText): success(docText)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTitleURL(
        url: String,
        useMetadata: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: DocumentTitle -> Void)
    {
        
        let metadata = shouldHaveField(useMetadata!)
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetTitle",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "useMetadata", value: metadata),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentTitle, NSError>) in
                switch response.result {
                case .Success(let docTitle): success(docTitle)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getTitleHtml(
        html: NSURL,
        url: String? = nil,
        useMetadata: Bool? = false,
        failure: (NSError -> Void)? = nil,
        success: DocumentTitle -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        if let metadata = useMetadata {
            queryParams.append(NSURLQueryItem(name: "useMetadata", value: shouldHaveField(metadata)))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetTitle",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<DocumentTitle, NSError>) in
                switch response.result {
                case .Success(let docTitle): success(docTitle)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    public func getFeedLinksURL(
        url: String,
        failure: (NSError -> Void)? = nil,
        success: Feeds -> Void)
    {
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/url/URLGetFeedLinks",
            contentType: "application/x-www-form-urlencoded",
            queryParameters: [
                NSURLQueryItem(name: "url", value: url),
                NSURLQueryItem(name: "apikey", value: apiKey),
                NSURLQueryItem(name: "outputMode", value: "json")
            ]
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Feeds, NSError>) in
                switch response.result {
                case .Success(let feeds): success(feeds)
                case .Failure(let error): failure?(error)
                }
        }
    }
    
    // Again, ther required URL parameter is a bug
    public func getFeedLinksHtml(
        html: NSURL,
        url: String? = " ",
        failure: (NSError -> Void)? = nil,
        success: Feeds -> Void)
    {
        // construct body
        let body = try? buildBody(html, html: true)
        
        // construct query paramerters
        var queryParams = [NSURLQueryItem]()
        
        queryParams.append(NSURLQueryItem(name: "apikey", value: apiKey))
        queryParams.append(NSURLQueryItem(name: "outputMode", value: "json"))
        if let myUrl = url {
            queryParams.append(NSURLQueryItem(name: "url", value: myUrl))
        }
        
        // construct request
        let request = RestRequest(
            method: .POST,
            url: serviceUrl + "/html/HTMLGetFeedLinks",
            contentType: "application/x-www-form-urlencoded",
            messageBody: body,
            queryParameters: queryParams
        )
        
        // execute request
        Alamofire.request(request)
            .responseObject(dataToError: dataToError) {
                (response: Response<Feeds, NSError>) in
                switch response.result {
                case .Success(let feeds): success(feeds)
                case .Failure(let error): failure?(error)
                }
        }
    }
 

}
