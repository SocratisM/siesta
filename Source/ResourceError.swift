//
//  ResourceError.swift
//  Siesta
//
//  Created by Paul on 2015/6/26.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//

/**
  Information about a failed resource request.
  
  Siesta can encounter errors from many possible sources, including:
  
  - client-side parse issues,
  - network connectivity problems,
  - transport layer issues (e.g. certificate problems),
  - server errors (404, 500, etc.), and
  - client-side parsing and data validation failures.
  
  `ResourceError` presents all these errors in a uniform structure. Several properties preserve diagnostic information,
  which you can use to intercept specific known errors, but these diagnostic properties are all optional.
  The one ironclad guarantee that `ResourceError` makes is the presence of a `userMessage`.
*/
public struct ResourceError
    {
    /**
      A description of this error suitable for showing to the user. Typically messages are brief and in plain language,
      e.g. “Not found,” “Invalid username or password,” or “The internet connection is offline.”
    */
    public var userMessage: String

    /// The HTTP status code (e.g. 404) if this error came from an HTTP response.
    public var httpStatusCode: Int?
    
    /// The response body if this error came from an HTTP response. Its meaning is API-specific.
    public var data: ResourceData?
    
    /// Diagnostic information if the error originated or was reported locally.
    public var nsError: NSError?
    
    /// The time at which the error occurred.
    public let timestamp: NSTimeInterval = now()
    
    /**
      Initializes the error using a network response.

      If the `userMessage` parameter is nil, this initializer uses `error` or the response’s status code to generate
      a user message. That failing, it gives a generic failure message.
    */
    public init(
            _ response: NSHTTPURLResponse?,
            _ payload: AnyObject?,
            _ error: NSError?,
            userMessage: String? = nil)
        {
        self.httpStatusCode = response?.statusCode
        self.nsError = error
        
        if let payload = payload
            { self.data = ResourceData(response, payload) }
        
        if let message = userMessage
            { self.userMessage = message }
        else if let message = error?.localizedDescription
            { self.userMessage = message }
        else if let code = self.httpStatusCode
            { self.userMessage = NSHTTPURLResponse.localizedStringForStatusCode(code).capitalizedFirstCharacter }
        else
            { self.userMessage = "Request failed" }   // Is this reachable?
        }
    
    /**
        Initializes the error using an `NSError`.
    */
    public init(
            userMessage: String,
            error: NSError? = nil,
            data: ResourceData? = nil)
        {
        self.userMessage = userMessage
        self.nsError = error
        self.data = data
        }

    /**
        Convenience to create a custom error with an user & debug messages. The `debugMessage` parameter is
        wrapped in the `nsError` property.
    */
    public init(
            userMessage: String,
            debugMessage: String,
            data: ResourceData? = nil)
        {
        let nserror = NSError(domain: "Siesta", code: -1, userInfo: [NSLocalizedDescriptionKey: debugMessage])
        self.init(userMessage: userMessage, error: nserror, data: data)
        }
    }