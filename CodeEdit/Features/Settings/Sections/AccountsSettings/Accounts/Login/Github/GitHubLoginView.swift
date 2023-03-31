//
//  GitHubLoginView.swift
//  CodeEditModules/Settings
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct GitHubLoginView: View {

    @State var accountName = ""
    @State var accountToken = ""

    @Environment(\.openURL) var createToken

    private let keychain = CodeEditKeychain()

    @Binding var dismissDialog: Bool
    @Binding var dismissParentDialog: Bool

    @StateObject
    private var prefs: SettingsModel = .shared

    var body: some View {
        VStack {
            Text("Sign in to your GitHub account")

            VStack(alignment: .trailing) {
                HStack {
                    Text("Account:")
                    TextField("Enter your username", text: $accountName)
                        .frame(width: 300)
                }
                HStack {
                    Text("Token:")
                    SecureField(
                        "Enter your Personal Access Token",
                        text: $accountToken
                    )
                    .frame(width: 300)
                }
            }

            VStack {
                Text("GitHub personal access tokens must have these scopes set:")
                    .fontWeight(.bold)
                    .font(.system(size: 11))

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("admin:public _key")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("write:discussion")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("repo")
                            .font(.system(size: 10))
                    }
                    HStack {
                        Image(systemName: "checkmark")
                        Text("user")
                            .font(.system(size: 10))
                    }
                }.padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
            .padding(.top, 10)

            HStack {
                HStack {
                    Button("Create a Token on GitHub") {
                        createToken(URL(string: "https://github.com/settings/tokens/new")!)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Button("Cancel") {
                        dismissDialog.toggle()
                    }
                    if accountToken.isEmpty {
                        Button("Sign In") {}
                        .disabled(true)
                    } else {
                        Button("Sign In") {
                            loginGitHub(gitAccountName: accountName)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 10)
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(width: 485, height: 280)
    }

    private func loginGitHub(gitAccountName: String) {
        let gitAccounts = prefs.settings.accounts.sourceControlAccounts.gitAccount

        let config = GitHubTokenConfiguration(accountToken)

        let providerLink = "https://github.com"
        GitHubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(
                    where: {
                        $0.gitProviderLink == providerLink &&
                        $0.gitAccountName.lowercased() == gitAccountName.lowercased()
                    }
                ) {
                    print("Account with the username and provider already exists!")
                } else {
                    print(user)
                    prefs.settings.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(
                            id: "\(providerLink)_\(gitAccountName.lowercased())",
                            gitProvider: "GitHub",
                            gitProviderLink: providerLink,
                            gitProviderDescription: "GitHub",
                            gitAccountName: gitAccountName,
                            gitCloningProtocol: true,
                            gitSSHKey: "",
                            isTokenValid: true
                        )
                    )
                    keychain.set(accountToken, forKey: "github_\(accountName)")
                    dismissDialog.toggle()
                    dismissParentDialog.toggle()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}