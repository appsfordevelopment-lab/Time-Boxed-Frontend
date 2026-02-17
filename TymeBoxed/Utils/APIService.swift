import Foundation

struct APIService {
  //static let baseURL = "http://localhost:3000/api"
  static let baseURL = "https://time-boxed.onrender.com/api"
  enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
      switch self {
      case .invalidURL:
        return "Invalid API URL"
      case .invalidResponse:
        return "Invalid response from server"
      case .httpError(let code):
        return "Server error: \(code)"
      case .decodingError:
        return "Failed to decode response"
      case .networkError(let error):
        return error.localizedDescription
      }
    }
  }
  
  struct SendOTPRequest: Codable {
    let email: String?
    let phone: String?
    
    init(email: String? = nil, phone: String? = nil) {
      self.email = email
      self.phone = phone
    }
  }
  
  struct SendOTPResponse: Codable {
    let success: Bool
    let message: String?
    let expiresIn: Int? // OTP expiration time in seconds
  }
  
  struct VerifyOTPRequest: Codable {
    let email: String?
    let phone: String?
    let otp: String
    
    init(email: String? = nil, phone: String? = nil, otp: String) {
      self.email = email
      self.phone = phone
      self.otp = otp
    }
  }
  
  struct VerifyOTPResponse: Codable {
    let success: Bool
    let message: String?
    let token: String?
  }

  // NFC (tags are pre-saved in DB; user only verifies scanned tag)
  struct VerifyNFCRequest: Codable { let tagId: String }
  struct VerifyNFCResponse: Codable {
    let success: Bool
    let valid: Bool
    let message: String?
  }

  static func sendOTP(email: String? = nil, phone: String? = nil) async throws -> SendOTPResponse {
    guard let url = URL(string: "\(baseURL)/auth/send-otp") else {
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = SendOTPRequest(email: email, phone: phone)
    request.httpBody = try JSONEncoder().encode(body)
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
      }
      
      guard (200...299).contains(httpResponse.statusCode) else {
        throw APIError.httpError(httpResponse.statusCode)
      }
      
      let decoder = JSONDecoder()
      return try decoder.decode(SendOTPResponse.self, from: data)
    } catch let error as APIError {
      throw error
    } catch {
      throw APIError.networkError(error)
    }
  }
  
  static func verifyOTP(email: String? = nil, phone: String? = nil, otp: String) async throws -> VerifyOTPResponse {
    guard let url = URL(string: "\(baseURL)/auth/verify-otp") else {
      throw APIError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = VerifyOTPRequest(email: email, phone: phone, otp: otp)
    request.httpBody = try JSONEncoder().encode(body)
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
      }
      
      guard (200...299).contains(httpResponse.statusCode) else {
        throw APIError.httpError(httpResponse.statusCode)
      }
      
      let decoder = JSONDecoder()
      return try decoder.decode(VerifyOTPResponse.self, from: data)
    } catch let error as APIError {
      throw error
    } catch {
      throw APIError.networkError(error)
    }
  }

  static func verifyNFCTag(tagId: String, token: String? = nil) async throws -> VerifyNFCResponse {
    guard let url = URL(string: "\(baseURL)/nfc/verify") else { throw APIError.invalidURL }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = token {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.httpBody = try JSONEncoder().encode(VerifyNFCRequest(tagId: tagId))
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
    guard (200...299).contains(httpResponse.statusCode) else { throw APIError.httpError(httpResponse.statusCode) }
    return try JSONDecoder().decode(VerifyNFCResponse.self, from: data)
  }
}
