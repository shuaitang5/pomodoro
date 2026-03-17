# App Store Publishing Notes

## Short Answer

Yes, in the normal case you need a paid Apple Developer Program membership to publish an app on the App Store, even if the app itself is free.

Apple currently lists the Apple Developer Program at `99 USD/year`, with possible regional pricing differences. Some nonprofits, accredited educational institutions, and government entities may qualify for a fee waiver.

Official sources:

- https://developer.apple.com/programs/
- https://developer.apple.com/programs/enroll/
- https://developer.apple.com/help/account/membership/program-enrollment
- https://developer.apple.com/support/fee-waiver/

## What This Means For This Project

This Pomodoro app can be shared outside the App Store today as a local `.app`.

If you want it on the Mac App Store, the practical path is:

1. Join the Apple Developer Program
2. Install full Xcode
3. Convert this project into a standard Xcode macOS app target
4. Add App Store requirements like sandboxing and signing
5. Create the app record in App Store Connect
6. Upload a build
7. Fill in store metadata
8. Submit for review

## Concrete Steps

## 1. Join Apple Developer Program

You need an Apple Developer Program membership to distribute on the App Store.

Notes:

- Individual enrollment shows your personal legal name as the seller
- Organization enrollment shows the organization legal name as the seller
- Organization enrollment typically requires a D-U-N-S number

Official sources:

- https://developer.apple.com/programs/
- https://developer.apple.com/programs/enroll/
- https://developer.apple.com/support/compare-memberships/

## 2. Install Full Xcode

For this repo, full Xcode is the right tool for App Store shipping.

Why:

- signing is easier
- sandbox capabilities are managed in the app target
- archiving and upload are built in
- App Store builds are much easier to validate from Xcode than from a plain Swift package flow

## 3. Convert This Repo Into An App Store Ready Xcode Project

Current state:

- this project builds as a Swift package
- it packages a local `.app`
- that is great for local use, but not the ideal App Store submission shape

What we would do next:

- create a proper macOS app target in Xcode
- keep bundle ID `com.pomodorotimer.app`
- set marketing version and build number
- keep the menu bar app behavior
- verify the in-dropdown settings flow still works

## 4. Enable App Sandbox

Mac App Store apps are expected to use App Sandbox.

For this app, sandboxing should be manageable because it is a lightweight menu bar timer and does not need broad file access.

Official sources:

- https://developer.apple.com/documentation/security/app_sandbox
- https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox

## 5. Set Up Signing

Inside Xcode, you would:

- sign in with your Apple developer account
- choose your team
- enable automatic signing
- confirm the app target uses the correct bundle identifier

This is the step that turns the app from a local build into a distributable Apple-signed build candidate.

## 6. Create The App Record In App Store Connect

Before uploading the build, create the app in App Store Connect.

You will need:

- app name
- platform: macOS
- primary language
- bundle ID
- SKU

Official source:

- https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/

## 7. Prepare App Store Metadata

You will need store-facing information such as:

- app description
- keywords
- support URL
- privacy policy URL
- screenshots
- age rating
- app privacy answers

Even for a simple free app, this step is required.

Official sources:

- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-information/
- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/
- https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots

## 8. Upload A Build

Recommended path:

- archive from Xcode
- upload from Xcode to App Store Connect

Apple also supports Transporter and some command-line upload paths, but Xcode is the simplest place to start.

Official source:

- https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds

## 9. Test Before Submission

Strong recommendation:

- upload a build
- validate it in App Store Connect
- test it before final review

This helps catch:

- signing mistakes
- sandbox issues
- metadata mismatches
- menu bar app behavior differences in the release build

## 10. Submit For Review

Once the build and metadata are ready:

- select the build in App Store Connect
- complete review information
- set pricing to `Free`
- submit the app for review

Official sources:

- https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app
- https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/set-a-price-for-an-app

## Project Specific Checklist

Before this Pomodoro app is App Store ready, we should do these project tasks:

- move from Swift package only to an Xcode macOS app target
- confirm menu bar app behavior under App Sandbox
- verify popup-window and sound behavior work correctly in the sandboxed app
- set version/build numbers
- prepare production screenshots
- write support URL and privacy policy URL
- archive and upload a first signed build

## Cost Notes

## Developer Program

Usually yes, you pay even if the app is free.

Apple's current official pricing says the Apple Developer Program is `99 USD per membership year`, unless you qualify for a fee waiver.

Official sources:

- https://developer.apple.com/programs/
- https://developer.apple.com/help/account/membership/program-enrollment
- https://developer.apple.com/support/fee-waiver/

## App Price

Your app can still be listed on the App Store as free.

That means:

- users pay `0`
- you still generally pay the annual developer membership

## Note About Other Fees

For a simple free macOS Pomodoro app, the main thing to expect is the Apple Developer Program membership.

Apple has other fee structures in some situations, but they are not the main concern for this project right now.
