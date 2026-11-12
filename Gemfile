source "https://rubygems.org"

gem "fastlane", ">= 2.240.0"
gem 'jazzy', '0.15.5'
# The project no longer uses CocoaPods, but jazzy depends on it as a library.
# The floor keeps that dependency at a release without known vulnerabilities.
gem 'cocoapods', '>= 1.17.0'
# rdoc 8.x is dual-licensed GPL-2.0-only, which fails the Snyk license check
gem 'rdoc', '< 8'
