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
import RestKit

/**
 This is an example to test the new target within our Xcode project.
 */
public class Conversation {

    /// A WorkspaceID uniquely identifies a Workspace in your Conversation application.
    public typealias WorkspaceID = String
    
    private let username: String
    private let password: String
    
    private let domain = "com.ibm.watson.developer-cloud.WatsonDeveloperCloud"
    private let serviceURL = "https://gateway.watsonplatform.net/conversation-experimental/api"
    
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    private func dataToError(data: NSData) -> NSError? {
        do {
            let json = try JSON(data: data)
            let error = try json.string("error")
            let code = try json.int("code")
            let userInfo = [NSLocalizedFailureReasonErrorKey: error]
            return NSError(domain: domain, code: code, userInfo: userInfo)
        } catch {
            return nil
        }
    }
    
    /**
     Start a new conversation or obtain a response for a submitted input message.
     
     - parameter message:     The user input message to send for processing.
     - parameter context:     A dictionary that holds state, or context, for the conversation.
     - parameter workspaceID: The conversation identifier. This is necessary.
     - parameter failure:     A function executed if an error occurs.
     - parameter success:     A function executed with the conversation application's response.
     */
    public func sendText(
        workspaceID: WorkspaceID,
        message:     String!,
        context:     [String : JSON]? = nil,
        failure:     (NSError -> Void)? = nil,
        success:     MessageResponse -> Void)
    {
        
        let messageRequest = MessageRequest(message: message, context: context)
        guard let body = try? messageRequest.toJSON().serialize() else {
            let failureReason = "Profile could not be serialized to JSON."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        // construct REST request
        let request = RestRequest(
            method: .POST,
            url: serviceURL + "/v1/workspaces/\(workspaceID)/message",
            acceptType: "application/json",
            contentType: "application/json",
            messageBody: body
        )
        
        // execute REST request
        Alamofire.request(request)
            .authenticate(user: username, password: password)
            .responseObject(dataToError: dataToError) {
                (response: Response<MessageResponse, NSError>) in
                switch response.result {
                    case .Success(let response): success(response)
                    case .Failure(let error): failure?(error)
                }
            }
    }
}
