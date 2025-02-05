//
//  EditProfileView.swift
//  munchies
//
//  Created by Mohammad Rahim on 2/3/25.
//
import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                // Name section
                Section(header: Text("Name")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                // Username section
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                }
                
                // Email section
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                // Password section
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                }
                
                Section {
                    Button(action: saveChanges) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        if let user = authManager.currentUser {
            username = user.username
            firstName = user.firstName
            lastName = user.lastName
            email = user.email
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        // Update profile information
        authManager.updateUserProfile(firstName: firstName, lastName: lastName, username: username) { error in
            if let error = error {
                alertMessage = "Error updating profile: \(error.localizedDescription)"
                showAlert = true
                isLoading = false
                return
            }
            
            // Update email if changed
            if email != authManager.currentUser?.email {
                Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { error in
                    if let error = error {
                        alertMessage = "Error sending verification email for email update: \(error.localizedDescription)"
                        showAlert = true
                        isLoading = false
                        return
                    } else {
                        alertMessage = "A verification email has been sent to your new email address. Please verify before the change takes effect."
                        showAlert = true
                        // Optionally, you can delay dismissing the view until the email is verified or guide the user accordingly.
                    }
                }
            }

            
            // Update password if provided
            if !newPassword.isEmpty {
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                
                Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                    if let error = error {
                        alertMessage = "Current password is incorrect: \(error.localizedDescription)"
                        showAlert = true
                        isLoading = false
                        return
                    }
                    
                    Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                        if let error = error {
                            alertMessage = "Error updating password: \(error.localizedDescription)"
                            showAlert = true
                        } else {
                            alertMessage = "Profile updated successfully"
                            showAlert = true
                            dismiss()
                        }
                        isLoading = false
                    }
                }
            } else {
                alertMessage = "Profile updated successfully"
                showAlert = true
                isLoading = false
                dismiss()
            }
        }
    }
}
