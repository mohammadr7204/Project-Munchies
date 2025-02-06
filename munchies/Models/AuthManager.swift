//
//  AuthManager.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/28/25.
//

// AuthManager.swift
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        // Start as logged out
        self.isAuthenticated = false
        self.currentUser = nil
        
        // Only set up the listener for subsequent changes
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if firebaseUser == nil {
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    private func loadUserData(firebaseUser: FirebaseAuth.User, completion: @escaping (Bool) -> Void = { _ in }) {
        let db = Firestore.firestore()
        db.collection("users").document(firebaseUser.uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                completion(false)
                return
            }
            
            if let data = snapshot?.data() {
                self?.currentUser = User(
                    id: firebaseUser.uid,
                    username: data["username"] as? String ?? "",
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    birthday: (data["birthday"] as? Timestamp)?.dateValue() ?? Date(),
                    email: firebaseUser.email ?? "",
                    profileImageUrl: data["profileImageUrl"] as? String,
                    bookmarkedRestaurants: data["bookmarkedRestaurants"] as? [String] ?? [],
                    wantToVisit: data["wantToVisit"] as? [String] ?? [],
                    reviewCount: data["reviewCount"] as? Int ?? 0,
                    preferences: data["preferences"] as? [String] ?? []
                )
                completion(true)
            } else {
                // Create a new user document if it doesn't exist
                let newUser = User(
                    id: firebaseUser.uid,
                    username: "",
                    firstName: "",  // Added
                    lastName: "",   // Added
                    birthday: Date(),  // Added with default current date
                    email: firebaseUser.email ?? "",
                    profileImageUrl: nil,
                    bookmarkedRestaurants: [],
                    wantToVisit: [],
                    reviewCount: 0,
                    preferences: []
                )
                
                // Save the new user to Firestore
                db.collection("users").document(firebaseUser.uid).setData([
                    "username": "",
                    "firstName": "",
                    "lastName": "",
                    "birthday": Date(),
                    "email": firebaseUser.email ?? "",
                    "profileImageUrl": "",
                    "bookmarkedRestaurants": [],
                    "wantToVisit": [],
                    "reviewCount": 0,
                    "preferences": []
                ])
                
                self?.currentUser = newUser
                completion(true)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = result?.user {
                self?.loadUserData(firebaseUser: firebaseUser) { success in
                    if success {
                        self?.isAuthenticated = true  // Only set to true after successful sign in
                        if let currentUser = self?.currentUser {
                            completion(.success(currentUser))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load user data"])))
                    }
                }
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        username: String,
        firstName: String,
        lastName: String,
        birthday: Date,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = result?.user {
                let newUser = User(
                    id: firebaseUser.uid,
                    username: username,
                    firstName: firstName,
                    lastName: lastName,
                    birthday: birthday,
                    email: email,
                    profileImageUrl: nil,
                    bookmarkedRestaurants: [],
                    wantToVisit: [],
                    reviewCount: 0,
                    preferences: []
                )
                
                // Save user data to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).setData([
                    "username": username,
                    "firstName": firstName,
                    "lastName": lastName,
                    "birthday": birthday, // Firestore automatically handles Date objects
                    "email": email,
                    "profileImageUrl": "",
                    "bookmarkedRestaurants": [],
                    "wantToVisit": [],
                    "reviewCount": 0,
                    "preferences": []
                ])
                
                self?.currentUser = newUser
                self?.isAuthenticated = true
                completion(.success(newUser))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateUserProfile(firstName: String? = nil, lastName: String? = nil, username: String? = nil, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            return
        }
        
        var updateData: [String: Any] = [:]
        if let firstName = firstName {
            updateData["firstName"] = firstName
        }
        if let lastName = lastName {
            updateData["lastName"] = lastName
        }
        if let username = username {
            updateData["username"] = username
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(updateData) { error in
            if let error = error {
                completion(error)
            } else {
                // Update local user data
                if let firstName = firstName {
                    self.currentUser?.firstName = firstName
                }
                if let lastName = lastName {
                    self.currentUser?.lastName = lastName
                }
                if let username = username {
                    self.currentUser?.username = username
                }
                completion(nil)
            }
        }
    }
}
